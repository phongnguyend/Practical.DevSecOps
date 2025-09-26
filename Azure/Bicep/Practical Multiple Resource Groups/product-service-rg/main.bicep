// Nested parameter objects for better organization
param general object = {
  location: 'southeastasia'
}

param featureFlags object = {
  enablePrivateEndpoints: false
  enableVNetIntegration: false
  enableKeyVault: false
  enableCosmosDb: false
  enableSqlServer: false
  enableFunctionApp: false
  enableApiManagement: false
}

param productService object = {
  name: 'product'
}

param appServicePlan object = {
  name: 'PracticalMultipleResourceGroups-Product-ASP'
}

param webApp object = {
  productApiName: 'PracticalMultipleResourceGroups-PRODUCT-API'
}

param functionApp object = {
  name: 'PracticalMultipleResourceGroups-PRODUCT-FUNC'
  storageAccountName: 'practicalmrgproductfunc'
}

param keyVault object = {
  name: 'practicalmrg-product-kv'
}

param sql object = {
  serverName: 'PracticalMultipleResourceGroups-Product'
  adminUsername: 'productadmin'
  databases: {
    product: {
      name: 'PracticalMultipleResourceGroups-PRODUCT-DB'
    }
  }
}

param cosmos object = {
  accountName: 'practicalmrg-product-cosmos'
  consistencyLevel: 'Session'
  enableAutomaticFailover: true
  databases: {
    product: {
      name: 'PracticalMultipleResourceGroups-PRODUCT-COSMOS-DB'
    }
  }
}

param networking object = {
  baseVnetName: 'PracticalMultipleResourceGroups-vnet'
  baseVnetResourceGroup: 'resourceGroup().name'
}

param apiManagement object = {
  name: 'PracticalMultipleResourceGroups-apim'
}

// Storage Account Parameters
param storageAccountType string = 'Standard_LRS'

// Secure parameter for SQL password
@secure()
param adminPassword string

// Application Insights Parameters (from base-services)
param applicationInsightsConnectionString string = ''

// Private DNS Zone ID for private endpoints (from base-services)
param privateDnsZoneId string = ''

// Reference to existing Virtual Network from base-services
resource existingVnet 'Microsoft.Network/virtualNetworks@2023-04-01' existing = {
  name: networking.baseVnetName
  scope: resourceGroup(networking.baseVnetResourceGroup)
}

// Common tags variable
var commonTags = {
  Environment: 'Development'
  Project: 'PracticalMultipleResourceGroups'
  Service: 'Product'
}

// App Service Plan Module
module productAppServicePlanModule 'modules/app-service-plans/productAppServicePlan.bicep' = {
  name: 'productAppServicePlanDeployment'
  params: {
    location: general.location
    appServicePlanName: appServicePlan.name
    tags: commonTags
  }
}

// Product API Web App Module
module productApiWebAppModule 'modules/app-services/productApiWebApp.bicep' = {
  name: 'productApiWebAppDeployment'
  params: {
    location: general.location
    appServicePlanId: productAppServicePlanModule.outputs.appServicePlanId
    productApiWebAppName: webApp.productApiName
    enablePrivateEndpoints: featureFlags.enablePrivateEndpoints
    privateEndpointSubnetId: featureFlags.enablePrivateEndpoints ? existingVnet.properties.subnets[2].id : '' // PrivateEndpointSubnet
    tags: commonTags
  }
}

// Product Function App Module (if enabled)
module productFunctionAppModule 'modules/azure-functions/productFunctionApp.bicep' = if (featureFlags.enableFunctionApp) {
  name: 'productFunctionAppDeployment'
  params: {
    location: general.location
    functionAppName: functionApp.name
    appServicePlanId: productAppServicePlanModule.outputs.appServicePlanId
    storageAccountName: functionApp.storageAccountName
    createPrivateEndpoint: featureFlags.enablePrivateEndpoints
    privateEndpointSubnetId: featureFlags.enablePrivateEndpoints ? existingVnet.properties.subnets[2].id : '' // PrivateEndpointSubnet
    privateDnsZoneId: featureFlags.enablePrivateEndpoints ? privateDnsZoneId : ''
    enableVNetIntegration: featureFlags.enableVNetIntegration
    vnetIntegrationSubnetId: featureFlags.enableVNetIntegration ? existingVnet.properties.subnets[1].id : '' // VNetIntegrationSubnet
    applicationInsightsConnectionString: applicationInsightsConnectionString
    tags: commonTags
  }
}

// Product API Management Integration Module (integrates with existing APIM from base-services)
module myExistingApiManagementModule 'modules/api-managements/my-existing-api-management/myExistingApiManagement.bicep' = if (featureFlags.enableApiManagement) {
  name: 'myExistingApiManagementDeployment'
  params: {
    apiManagementName: apiManagement.name
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
    location: general.location
    storageAccountName: functionApp.storageAccountName
    storageAccountType: storageAccountType
    accessTier: 'Hot'
    allowBlobPublicAccess: !featureFlags.enablePrivateEndpoints
    minimumTlsVersion: 'TLS1_2'
    createPrivateEndpoint: featureFlags.enablePrivateEndpoints
    privateEndpointSubnetId: featureFlags.enablePrivateEndpoints ? existingVnet.properties.subnets[2].id : '' // PrivateEndpointSubnet
    privateDnsZoneIds: {
      blob: featureFlags.enablePrivateEndpoints ? privateDnsZoneId : ''
      file: ''
      queue: ''
      table: ''
    }
    allowedIpRanges: []
    bypassAzureServices: true
    allowedSubnetIds: featureFlags.enableVNetIntegration ? [existingVnet.properties.subnets[1].id] : [] // VNetIntegrationSubnet
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
    location: general.location
    sqlServerName: sql.serverName
    adminUsername: sql.adminUsername
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
    location: general.location
    sqlServerName: sql.serverName
    productDbName: sql.databases.product.name
    tags: commonTags
  }
}

// Key Vault Module
module productKeyVaultModule 'modules/key-vaults/productKeyVault.bicep' = if (featureFlags.enableKeyVault) {
  name: 'productKeyVaultDeployment'
  params: {
    location: general.location
    keyVaultName: keyVault.name
    // Consolidated Role Assignment Parameters for Key Vault access
    roleAssignments: featureFlags.enableKeyVault ? concat(
      // Product API Web App Role Assignment (Key Vault Secrets User)
      [
        {
          principalId: productApiWebAppModule.outputs.productApiWebAppPrincipalId
          roleDefinitionId: '4633458b-17de-408a-b874-0445c86b69e6' // Key Vault Secrets User
        }
      ],
      // Product Function App Role Assignment (Key Vault Secrets User) - only when enabled
      featureFlags.enableFunctionApp ? [
        {
          principalId: productFunctionAppModule!.outputs.principalId
          roleDefinitionId: '4633458b-17de-408a-b874-0445c86b69e6' // Key Vault Secrets User
        }
      ] : []
    ) : []
    tags: commonTags
  }
}

// Cosmos DB Module
module productCosmosDbModule 'modules/cosmos-accounts/productCosmosAccount.bicep' = if (featureFlags.enableCosmosDb) {
  name: 'productCosmosDbDeployment'
  params: {
    location: general.location
    cosmosAccountName: cosmos.accountName
    consistencyLevel: cosmos.consistencyLevel
    enableAutomaticFailover: cosmos.enableAutomaticFailover
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
    sqlRoleAssignments: featureFlags.enableCosmosDb ? concat(
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
    ) : []
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
    cosmosAccountName: cosmos.accountName
    productCosmosDbName: cosmos.databases.product.name
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
