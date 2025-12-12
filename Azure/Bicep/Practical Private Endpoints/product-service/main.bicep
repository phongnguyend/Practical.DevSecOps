param location string = 'southeastasia'

// Feature Flags Object
param featureFlags object = {
  enablePrivateEndpoints: false
  enableVNetIntegration: true
  enableKeyVault: false
  enableCosmosDb: false
  enableSqlServer: false
  enableFunctionApp: false
  enableApiManagement: false
}

// Product Service Configuration
param productService object = {
  name: 'product'
  appServicePlanName: 'PracticalPrivateEndpoints-Product-ASP'
  webApp: {
    productApiWebAppName: 'PracticalPrivateEndpoints-PRODUCT-API'
  }
  azureFunction: {
    productFunctionAppName: 'PracticalPrivateEndpoints-PRODUCT-FUNC'
    storageAccountName: 'practicalpeproductfunc'
  }
}

// SQL Server Configuration
param sqlServer object = {
  serverName: 'PracticalPrivateEndpoints-Product'
  adminUsername: 'productadmin'
  database: {
    productDbName: 'PracticalPrivateEndpoints-PRODUCT-DB'
  }
}

@secure()
param adminPassword string

// Cosmos DB Configuration
param cosmosDb object = {
  accountName: 'practicalpe-product-cosmos'
  consistencyLevel: 'Session'
  enableAutomaticFailover: true
  enableAvailabilityZones: false
  database: {
    productCosmosDbName: 'PracticalPrivateEndpoints-PRODUCT-COSMOS-DB'
  }
}

// Key Vault Configuration
param keyVault object = {
  productKeyVaultName: 'practicalpe-product-kv'
}

// Base Services Configuration (references to base-services deployment)
param baseServices object = {
  vnetName: 'PracticalPrivateEndpoints-vnet'
  vnetResourceGroup: resourceGroup().name
  apiManagementName: 'PracticalPrivateEndpoints-apim'
}

// Reference to existing Virtual Network from base-services
resource existingVnet 'Microsoft.Network/virtualNetworks@2023-04-01' existing = {
  name: baseServices.vnetName
  scope: resourceGroup(baseServices.vnetResourceGroup)
}

// Common tags variable
var commonTags = {
  Environment: 'Development'
  Project: 'PracticalPrivateEndpoints'
  Service: 'Product'
}

// App Service Plan Module
module productAppServicePlanModule 'modules/app-service-plans/productAppServicePlan.bicep' = {
  name: 'productAppServicePlanDeployment'
  params: {
    location: location
    appServicePlanName: productService.appServicePlanName
    tags: commonTags
  }
}

// Product API Web App Module
module productApiWebAppModule 'modules/app-services/productApiWebApp.bicep' = {
  name: 'productApiWebAppDeployment'
  params: {
    location: location
    appServicePlanId: productAppServicePlanModule.outputs.appServicePlanId
    productApiWebAppName: productService.webApp.productApiWebAppName
    enablePrivateEndpoints: featureFlags.enablePrivateEndpoints
    privateEndpointSubnetId: featureFlags.enablePrivateEndpoints ? existingVnet.properties.subnets[2].id : '' // PrivateEndpointSubnet
    tags: commonTags
  }
}

// Product Function App Module (if enabled)
module productFunctionAppModule 'modules/azure-functions/productFunctionApp.bicep' = if (featureFlags.enableFunctionApp) {
  name: 'productFunctionAppDeployment'
  params: {
    location: location
    functionAppName: productService.azureFunction.productFunctionAppName
    appServicePlanId: productAppServicePlanModule.outputs.appServicePlanId
    storageAccountName: productService.azureFunction.storageAccountName
    createPrivateEndpoint: featureFlags.enablePrivateEndpoints
    privateEndpointSubnetId: featureFlags.enablePrivateEndpoints ? existingVnet.properties.subnets[2].id : '' // PrivateEndpointSubnet
    privateDnsZoneId: '' // Would need to be provided from base-services if using private endpoints
    enableVNetIntegration: false // Set based on your requirements
    vnetIntegrationSubnetId: '' // Would need VNet integration subnet if enabled
    applicationInsightsConnectionString: '' // Would need Application Insights if available
    tags: commonTags
  }
}

// Product API Management Integration Module (integrates with existing APIM from base-services)
module myExistingApiManagementModule 'modules/api-managements/my-existing-api-management/myExistingApiManagement.bicep' = if (featureFlags.enableApiManagement) {
  name: 'myExistingApiManagementDeployment'
  params: {
    apiManagementName: baseServices.apiManagementName
    productApiUrl: productApiWebAppModule.outputs.productApiWebAppUrl
    apiPath: 'products'
    protocols: ['https']
    subscriptionRequired: false
    backendProtocol: 'https'
  }
}

// Product Function Apps Storage Account Module (deployed after App Service Plan - for function runtime storage only)
module productFunctionStorageModule 'modules/storage-accounts/productFunctionsStorageAccount.bicep' = if (featureFlags.enableFunctionApp) {
  name: 'productFunctionStorageDeployment'
  params: {
    location: location
    storageAccountName: productService.azureFunction.storageAccountName
    storageAccountType: 'Standard_LRS'
    accessTier: 'Hot'
    minimumTlsVersion: 'TLS1_2'
    createPrivateEndpoint: featureFlags.enablePrivateEndpoints
    privateEndpointSubnetId: featureFlags.enablePrivateEndpoints ? existingVnet.properties.subnets[2].id : '' // PrivateEndpointSubnet
    privateDnsZoneIds: {
      blob: '' // No DNS zone available in product-service
      file: '' // No DNS zone available in product-service
      queue: '' // No DNS zone available in product-service
      table: '' // No DNS zone available in product-service
    }
    allowedIpRanges: []
    bypassAzureServices: true
    allowedSubnetIds: []
    allowBlobPublicAccess: !featureFlags.enablePrivateEndpoints
    roleAssignments: []
    tags: union(commonTags, {
      Purpose: 'FunctionAppRuntimeStorage'
    })
  }
}

// SQL Server Module
module productSqlServerModule 'modules/sql-servers/productSqlServer.bicep' = if (featureFlags.enableSqlServer) {
  name: 'productSqlServerDeployment'
  params: {
    location: location
    sqlServerName: sqlServer.serverName
    adminUsername: sqlServer.adminUsername
    adminPassword: adminPassword
    tags: commonTags
  }
}

// Product SQL Database Module (depends on SQL Server)
module productSqlDatabase 'modules/sql-server-databases/productDb.bicep' = if (featureFlags.enableSqlServer) {
  name: 'productSqlDatabaseDeployment'
  dependsOn: [
    productSqlServerModule
  ]
  params: {
    location: location
    sqlServerName: sqlServer.serverName
    productDbName: sqlServer.database.productDbName
    tags: commonTags
  }
}

// Key Vault Module
module productKeyVaultModule 'modules/key-vaults/productKeyVault.bicep' = if (featureFlags.enableKeyVault) {
  name: 'productKeyVaultDeployment'
  params: {
    location: location
    keyVaultName: keyVault.productKeyVaultName
    roleAssignments: concat(
      [
        // Product API Role Assignment
        {
          principalId: productApiWebAppModule.outputs.productApiWebAppPrincipalId
          roleDefinitionId: '4633458b-17de-408a-b874-0445c86b69e6' // Key Vault Secrets User
        }
      ],
      // Product Function App Role Assignment (if enabled)
      featureFlags.enableFunctionApp ? [
        {
          principalId: productFunctionAppModule!.outputs.principalId
          roleDefinitionId: '4633458b-17de-408a-b874-0445c86b69e6' // Key Vault Secrets User
        }
      ] : []
    )
    tags: commonTags
  }
}

// Cosmos DB Module
module productCosmosDbModule 'modules/cosmos-accounts/productCosmosAccount.bicep' = if (featureFlags.enableCosmosDb) {
  name: 'productCosmosDbDeployment'
  params: {
    location: location
    cosmosAccountName: cosmosDb.accountName
    consistencyLevel: cosmosDb.consistencyLevel
    enableAutomaticFailover: cosmosDb.enableAutomaticFailover
    enableAvailabilityZones: cosmosDb.enableAvailabilityZones
    createPrivateEndpoint: featureFlags.enablePrivateEndpoints
    privateEndpointSubnetId: featureFlags.enablePrivateEndpoints ? existingVnet.properties.subnets[2].id : '' // PrivateEndpointSubnet
    enablePublicNetworkAccess: !featureFlags.enablePrivateEndpoints
    // Generic Role Assignments (Azure RBAC)
    roleAssignments: concat(
      [
        {
          principalId: productApiWebAppModule.outputs.productApiWebAppPrincipalId
          roleDefinitionId: '5bd9cd88-fe45-4216-938b-f97437e15450' // Cosmos DB Data Contributor (Azure RBAC)
        }
      ],
      featureFlags.enableFunctionApp ? [
        {
          principalId: productFunctionAppModule!.outputs.principalId
          roleDefinitionId: '5bd9cd88-fe45-4216-938b-f97437e15450' // Cosmos DB Data Contributor (Azure RBAC)
        }
      ] : []
    )
    // SQL Role Assignments (Cosmos DB Built-in roles)
    sqlRoleAssignments: concat(
      [
        {
          principalId: productApiWebAppModule.outputs.productApiWebAppPrincipalId
          roleDefinitionId: '00000000-0000-0000-0000-000000000002' // Cosmos DB Built-in Data Contributor
        }
      ],
      featureFlags.enableFunctionApp ? [
        {
          principalId: productFunctionAppModule!.outputs.principalId
          roleDefinitionId: '00000000-0000-0000-0000-000000000002' // Cosmos DB Built-in Data Contributor
        }
      ] : []
    )
    tags: commonTags
  }
}

// Product Cosmos Database Module (depends on Cosmos Account)
module productCosmosDbDatabase 'modules/cosmos-databases/productDb.bicep' = if (featureFlags.enableCosmosDb) {
  name: 'productCosmosDatabaseDeployment'
  dependsOn: [
    productCosmosDbModule
  ]
  params: {
    cosmosAccountName: cosmosDb.accountName
    productCosmosDbName: cosmosDb.database.productCosmosDbName
    tags: commonTags
  }
}

// Outputs
output productServiceInfo object = {
  serviceName: productService.name
  appServicePlan: {
    id: productAppServicePlanModule.outputs.appServicePlanId
    name: productAppServicePlanModule.outputs.appServicePlanName
  }
  productApi: {
    id: productApiWebAppModule.outputs.productApiWebAppId
    name: productApiWebAppModule.outputs.productApiWebAppName
    url: productApiWebAppModule.outputs.productApiWebAppUrl
    principalId: productApiWebAppModule.outputs.productApiWebAppPrincipalId
  }
  productFunction: featureFlags.enableFunctionApp ? {
    id: productFunctionAppModule!.outputs.functionAppId
    name: productFunctionAppModule!.outputs.functionAppName
    url: productFunctionAppModule!.outputs.functionAppUrl
    principalId: productFunctionAppModule!.outputs.principalId
  } : {}
  sqlServer: featureFlags.enableSqlServer ? {
    id: productSqlServerModule!.outputs.sqlServerId
    name: productSqlServerModule!.outputs.sqlServerName
    fqdn: productSqlServerModule!.outputs.sqlServerFqdn
    databaseName: productSqlDatabase!.outputs.productDatabaseName
  } : {}
  cosmosDb: featureFlags.enableCosmosDb ? {
    id: productCosmosDbModule!.outputs.cosmosAccountId
    name: productCosmosDbModule!.outputs.cosmosAccountName
    endpoint: productCosmosDbModule!.outputs.cosmosAccountEndpoint
    databaseName: productCosmosDbDatabase!.outputs.productDatabaseName
  } : {}
  keyVault: featureFlags.enableKeyVault ? {
    id: productKeyVaultModule!.outputs.keyVaultId
    name: productKeyVaultModule!.outputs.keyVaultName
    uri: productKeyVaultModule!.outputs.keyVaultUri
  } : {}
  functionStorage: featureFlags.enableFunctionApp ? {
    id: productFunctionStorageModule!.outputs.storageAccountId
    name: productFunctionStorageModule!.outputs.storageAccountName
    primaryEndpoints: productFunctionStorageModule!.outputs.primaryEndpoints
  } : {}
}
