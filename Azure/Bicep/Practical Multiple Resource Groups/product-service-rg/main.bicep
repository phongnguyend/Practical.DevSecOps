param location string = 'southeastasia'

// Feature Flags
param enablePrivateEndpoints bool = false
param enableVNetIntegration bool = false
param enableKeyVault bool = false
param enableCosmosDb bool = false
param enableSqlServer bool = false
param enableFunctionApp bool = false
param enableApiManagement bool = false

// Product Service Parameters
param productServiceName string = 'product'
param appServicePlanName string = 'PracticalMultipleResourceGroups-Product-ASP'
param productApiWebAppName string = 'PracticalMultipleResourceGroups-PRODUCT-API'
param productFunctionAppName string = 'PracticalMultipleResourceGroups-PRODUCT-FUNC'
param productKeyVaultName string = 'practicalmrg-product-kv'
param productFunctionStorageAccountName string = 'practicalmrgproductfunc'

// SQL Server Parameters
param sqlServerName string = 'PracticalMultipleResourceGroups-Product'
param adminUsername string = 'productadmin'
@secure()
param adminPassword string
param productDbName string = 'PracticalMultipleResourceGroups-PRODUCT-DB'

// Cosmos DB Parameters
param cosmosAccountName string = 'practicalmrg-product-cosmos-${uniqueString(resourceGroup().id)}'
param cosmosConsistencyLevel string = 'Session'
param cosmosEnableAutomaticFailover bool = true
param productCosmosDbName string = 'PracticalMultipleResourceGroups-PRODUCT-COSMOS-DB'

// Base Services Virtual Network Reference (from base-services deployment)
param baseVnetName string = 'PracticalMultipleResourceGroups-vnet'
param baseVnetResourceGroup string = resourceGroup().name

// API Management Parameters (from base-services)
param apiManagementName string = 'PracticalMultipleResourceGroups-apim'

// Application Insights Parameters (from base-services)
param applicationInsightsConnectionString string = ''

// Private DNS Zone ID for private endpoints (from base-services)
param privateDnsZoneId string = ''

// Reference to existing Virtual Network from base-services
resource existingVnet 'Microsoft.Network/virtualNetworks@2023-04-01' existing = {
  name: baseVnetName
  scope: resourceGroup(baseVnetResourceGroup)
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
    location: location
    appServicePlanName: appServicePlanName
    tags: commonTags
  }
}

// Product API Web App Module
module productApiWebAppModule 'modules/app-services/productApiWebApp.bicep' = {
  name: 'productApiWebAppDeployment'
  params: {
    location: location
    appServicePlanId: productAppServicePlanModule.outputs.appServicePlanId
    productApiWebAppName: productApiWebAppName
    enablePrivateEndpoints: enablePrivateEndpoints
    privateEndpointSubnetId: enablePrivateEndpoints ? existingVnet.properties.subnets[2].id : '' // PrivateEndpointSubnet
    tags: commonTags
  }
}

// Product Function App Module (if enabled)
module productFunctionAppModule 'modules/azure-functions/productFunctionApp.bicep' = if (enableFunctionApp) {
  name: 'productFunctionAppDeployment'
  params: {
    location: location
    functionAppName: productFunctionAppName
    appServicePlanId: productAppServicePlanModule.outputs.appServicePlanId
    storageAccountName: productFunctionStorageAccountName
    createPrivateEndpoint: enablePrivateEndpoints
    privateEndpointSubnetId: enablePrivateEndpoints ? existingVnet.properties.subnets[2].id : '' // PrivateEndpointSubnet
    privateDnsZoneId: enablePrivateEndpoints ? privateDnsZoneId : ''
    enableVNetIntegration: enableVNetIntegration
    vnetIntegrationSubnetId: enableVNetIntegration ? existingVnet.properties.subnets[1].id : '' // VNetIntegrationSubnet
    applicationInsightsConnectionString: applicationInsightsConnectionString
    tags: commonTags
  }
}

// Product API Management Integration Module (integrates with existing APIM from base-services)
module myExistingApiManagementModule 'modules/api-managements/my-existing-api-management/myExistingApiManagement.bicep' = if (enableApiManagement) {
  name: 'myExistingApiManagementDeployment'
  params: {
    apiManagementName: apiManagementName
    productApiUrl: productApiWebAppModule.outputs.productApiWebAppUrl
    apiPath: 'products'
    protocols: ['https']
    subscriptionRequired: false
    backendProtocol: 'https'
  }
}

// Product Function Apps Storage Account Module (deployed after App Service Plan - for function runtime storage only)
module productFunctionStorageModule 'modules/storage-accounts/productFunctionsStorageAccount.bicep' = if (enableFunctionApp) {
  name: 'productFunctionStorageDeployment'
  params: {
    location: location
    storageAccountName: productFunctionStorageAccountName
    createPrivateEndpoint: enablePrivateEndpoints
    privateEndpointSubnetId: enablePrivateEndpoints ? existingVnet.properties.subnets[2].id : '' // PrivateEndpointSubnet
    allowBlobPublicAccess: !enablePrivateEndpoints
    tags: union(commonTags, {
      Purpose: 'FunctionAppRuntimeStorage'
    })
  }
}

// SQL Server Module
module productSqlServerModule 'modules/sql-servers/productSqlServer.bicep' = if (enableSqlServer) {
  name: 'productSqlServerDeployment'
  params: {
    location: location
    sqlServerName: sqlServerName
    adminUsername: adminUsername
    adminPassword: adminPassword
    tags: commonTags
  }
}

// Product SQL Database Module (depends on SQL Server)
module productSqlDatabase 'modules/sql-server-databases/productDb.bicep' = if (enableSqlServer) {
  name: 'productSqlDatabaseDeployment'
  dependsOn: [
    productSqlServerModule
  ]
  params: {
    location: location
    sqlServerName: sqlServerName
    productDbName: productDbName
    tags: commonTags
  }
}

// Key Vault Module
module productKeyVaultModule 'modules/key-vaults/productKeyVault.bicep' = if (enableKeyVault) {
  name: 'productKeyVaultDeployment'
  params: {
    location: location
    keyVaultName: productKeyVaultName
    // Consolidated Role Assignment Parameters for Key Vault access
    roleAssignments: enableKeyVault ? concat(
      // Product API Web App Role Assignment (Key Vault Secrets User)
      [
        {
          principalId: productApiWebAppModule.outputs.productApiWebAppPrincipalId
          roleDefinitionId: '4633458b-17de-408a-b874-0445c86b69e6' // Key Vault Secrets User
        }
      ],
      // Product Function App Role Assignment (Key Vault Secrets User) - only when enabled
      enableFunctionApp ? [
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
module productCosmosDbModule 'modules/cosmos-accounts/productCosmosAccount.bicep' = if (enableCosmosDb) {
  name: 'productCosmosDbDeployment'
  params: {
    location: location
    cosmosAccountName: cosmosAccountName
    consistencyLevel: cosmosConsistencyLevel
    enableAutomaticFailover: cosmosEnableAutomaticFailover
    createPrivateEndpoint: enablePrivateEndpoints
    privateEndpointSubnetId: enablePrivateEndpoints ? existingVnet.properties.subnets[2].id : '' // PrivateEndpointSubnet
    enablePublicNetworkAccess: !enablePrivateEndpoints
    // Generic Role Assignments (Azure RBAC)
    roleAssignments: concat(
      [
        {
          principalId: productApiWebAppModule.outputs.productApiWebAppPrincipalId
          roleDefinitionId: '5bd9cd88-fe45-4216-938b-f97437e15450' // Cosmos DB Data Contributor (Azure RBAC)
        }
      ],
      enableFunctionApp ? [
        {
          principalId: productFunctionAppModule!.outputs.principalId
          roleDefinitionId: '5bd9cd88-fe45-4216-938b-f97437e15450' // Cosmos DB Data Contributor (Azure RBAC)
        }
      ] : []
    )
    // SQL Role Assignments (Cosmos DB Built-in roles)
    sqlRoleAssignments: enableCosmosDb ? concat(
      [
        {
          principalId: productApiWebAppModule.outputs.productApiWebAppPrincipalId
          roleDefinitionId: '00000000-0000-0000-0000-000000000002' // Cosmos DB Built-in Data Contributor
        }
      ],
      enableFunctionApp ? [
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
module productCosmosDbDatabase 'modules/cosmos-databases/productDb.bicep' = if (enableCosmosDb) {
  name: 'productCosmosDatabaseDeployment'
  dependsOn: [
    productCosmosDbModule
  ]
  params: {
    cosmosAccountName: cosmosAccountName
    productCosmosDbName: productCosmosDbName
    tags: commonTags
  }
}

// Outputs
output productServiceInfo object = {
  serviceName: productServiceName
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
  productFunction: enableFunctionApp ? {
    id: productFunctionAppModule!.outputs.functionAppId
    name: productFunctionAppModule!.outputs.functionAppName
    url: productFunctionAppModule!.outputs.functionAppUrl
    principalId: productFunctionAppModule!.outputs.principalId
  } : {}
  sqlServer: enableSqlServer ? {
    id: productSqlServerModule!.outputs.sqlServerId
    name: productSqlServerModule!.outputs.sqlServerName
    fqdn: productSqlServerModule!.outputs.sqlServerFqdn
    databaseName: productSqlDatabase!.outputs.productDatabaseName
  } : {}
  cosmosDb: enableCosmosDb ? {
    id: productCosmosDbModule!.outputs.cosmosAccountId
    name: productCosmosDbModule!.outputs.cosmosAccountName
    endpoint: productCosmosDbModule!.outputs.cosmosAccountEndpoint
    databaseName: productCosmosDbDatabase!.outputs.productDatabaseName
  } : {}
  keyVault: enableKeyVault ? {
    id: productKeyVaultModule!.outputs.keyVaultId
    name: productKeyVaultModule!.outputs.keyVaultName
    uri: productKeyVaultModule!.outputs.keyVaultUri
  } : {}
  functionStorage: enableFunctionApp ? {
    id: productFunctionStorageModule!.outputs.storageAccountId
    name: productFunctionStorageModule!.outputs.storageAccountName
    primaryEndpoints: productFunctionStorageModule!.outputs.primaryEndpoints
  } : {}
}
