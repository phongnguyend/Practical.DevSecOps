param location string = 'southeastasia'

// Feature Flags
param enablePrivateEndpoints bool = false
param enableVNetIntegration bool = false
param enableApplicationGateway bool = false
param enableApiManagement bool = false
param enableTestVM bool = false
param enableSqlServer bool = false
param enableKeyVault bool = false
param enableAppConfiguration bool = false
param enableStorageAccount bool = false
param enableCosmosDb bool = false
param enableFunctionApps bool = false
param enableServiceBus bool = false
param enableApplicationInsights bool = false

param sqlServerName string = 'PracticalPrivateEndpoints'
param adminUsername string = 'PracticalPrivateEndpoints'
@secure()
param adminPassword string = 'sqladmin123!@#'
param appServicePlanName string = 'PracticalPrivateEndpoints'
param vnetName string = 'PracticalPrivateEndpoints-vnet'
param keyVaultName string = 'practicalendpointskv'
param appConfigName string = 'PracticalPrivateEndpoints-config'
param storageAccountName string = 'practicalendpointsblob'
param functionAppsStorageAccountName string = 'practicalfuncappsst'
param apiManagementName string = 'PracticalPrivateEndpoints-apim'
param publisherEmail string = 'admin@practical.devsecops'
param publisherName string = 'Practical DevSecOps'

// Individual Web App Name Parameters
param customerPublicWebAppName string = 'PracticalPrivateEndpoints-CUSTOMER-PUBLIC'
param customerSiteWebAppName string = 'PracticalPrivateEndpoints-CUSTOMER-SITE'
param adminPublicWebAppName string = 'PracticalPrivateEndpoints-ADMIN-PUBLIC'
param adminSiteWebAppName string = 'PracticalPrivateEndpoints-ADMIN-SITE'
param videoApiWebAppName string = 'PracticalPrivateEndpoints-VIDEO-API'
param musicApiWebAppName string = 'PracticalPrivateEndpoints-MUSIC-API'

// Individual Database Name Parameters
param customerDbName string = 'PracticalPrivateEndpoints-CUSTOMER-DB'
param adminDbName string = 'PracticalPrivateEndpoints-ADMIN-DB'
param videoDbName string = 'PracticalPrivateEndpoints-VIDEO-DB'
param musicDbName string = 'PracticalPrivateEndpoints-MUSIC-DB'

// Test VM parameters
param vmAdminUsername string = 'testadmin'
@secure()
param vmAdminPassword string = 'TestVM123!@#'

// API Management parameters
param apiManagementSku string = 'Premium'
param apiManagementCapacity int = 1

// Application Gateway WAF parameters
param enableWAF bool = true
param wafMode string = 'Prevention'
param wafRuleSetVersion string = '3.2'
param wafRequestBodyCheck bool = true
param wafMaxRequestBodySizeInKb int = 128
param wafFileUploadLimitInMb int = 100

// Blob Storage parameters
param storageAccountType string = 'Standard_LRS'
param blobContainerNames array = [
  'documents'
  'images'
  'backups'
  'logs'
]

// Cosmos DB parameters
param cosmosAccountName string = 'practicalpe-cosmos-${uniqueString(resourceGroup().id)}'
param cosmosConsistencyLevel string = 'Session'
param cosmosEnableAutomaticFailover bool = true

// Individual Cosmos Database Names
param cosmosAdminDbName string = 'PracticalPrivateEndpoints-ADMIN-COSMOS-DB'
param cosmosCustomerDbName string = 'PracticalPrivateEndpoints-CUSTOMER-COSMOS-DB'
param cosmosMusicDbName string = 'PracticalPrivateEndpoints-MUSIC-COSMOS-DB'
param cosmosVideoDbName string = 'PracticalPrivateEndpoints-VIDEO-COSMOS-DB'

// Function App parameters
param adminFunctionAppName string = 'PracticalPrivateEndpoints-ADMIN-FUNC'
param customerFunctionAppName string = 'PracticalPrivateEndpoints-CUSTOMER-FUNC'
param musicFunctionAppName string = 'PracticalPrivateEndpoints-MUSIC-FUNC'
param videoFunctionAppName string = 'PracticalPrivateEndpoints-VIDEO-FUNC'

// Application Insights parameters
param applicationInsightsWorkspaceName string = 'PracticalPrivateEndpoints-law'
param retentionInDays int = 30

// Service Bus parameters
param serviceBusNamespaceName string = 'PracticalPrivateEndpoints-sb-${uniqueString(resourceGroup().id)}'
param serviceBusSku string = 'Premium'
param serviceBusCapacity int = 1
param serviceBusTopicNames array = [
  'customer-events'
  'admin-events'
  'video-events'
  'music-events'
]
param serviceBusQueueNames array = [
  'customer-queue'
  'admin-queue'
  'video-queue'
  'music-queue'
]
param serviceBusSubscriptions array = [
  {
    topicName: 'customer-events'
    subscriptionName: 'customer-subscription'
  }
  {
    topicName: 'admin-events'
    subscriptionName: 'admin-subscription'
  }
  {
    topicName: 'video-events'
    subscriptionName: 'video-subscription'
  }
  {
    topicName: 'music-events'
    subscriptionName: 'music-subscription'
  }
]

// Common tags variable
var commonTags = {
  Environment: 'Development'
  Project: 'PracticalPrivateEndpoints'
}

// API Management NSG Module
module apiManagementNSGModule 'modules/network-security-groups/apiManagementNSG.bicep' = {
  name: 'apiManagementNSGDeployment'
  params: {
    location: location
    name: '${vnetName}-apim-nsg'
    tags: commonTags
  }
}

// Virtual Network Module
module vnetModule 'modules/virtual-networks/virtualNetwork.bicep' = {
  name: 'virtualNetworkDeployment'
  params: {
    location: location
    vnetName: vnetName
    vnetAddressPrefix: '10.0.0.0/16'
    apiManagementNSGId: apiManagementNSGModule.outputs.apiManagementNSGId
    tags: commonTags
  }
}

// SQL Server Module
module sqlServerModule 'modules/sql-servers/mySqlServer.bicep' = if (enableSqlServer) {
  name: 'sqlServerDeployment'
  params: {
    location: location
    sqlServerName: sqlServerName
    adminUsername: adminUsername
    adminPassword: adminPassword
    allowedSubnets: enableVNetIntegration ? [vnetModule.outputs.vnetIntegrationSubnetId] : []
    tags: commonTags
  }
}

// Individual Database Modules (depend on SQL Server)
module customerDatabaseModule 'modules/sql-server-databases/customerDb.bicep' = if (enableSqlServer) {
  name: 'customerDatabaseDeployment'
  dependsOn: [
    sqlServerModule
  ]
  params: {
    location: location
    sqlServerName: sqlServerName
    databaseName: customerDbName
    tags: commonTags
  }
}

module adminDatabaseModule 'modules/sql-server-databases/adminDb.bicep' = if (enableSqlServer) {
  name: 'adminDatabaseDeployment'
  dependsOn: [
    sqlServerModule
  ]
  params: {
    location: location
    sqlServerName: sqlServerName
    databaseName: adminDbName
    tags: commonTags
  }
}

module videoDatabaseModule 'modules/sql-server-databases/videoDb.bicep' = if (enableSqlServer) {
  name: 'videoDatabaseDeployment'
  dependsOn: [
    sqlServerModule
  ]
  params: {
    location: location
    sqlServerName: sqlServerName
    databaseName: videoDbName
    tags: commonTags
  }
}

module musicDatabaseModule 'modules/sql-server-databases/musicDb.bicep' = if (enableSqlServer) {
  name: 'musicDatabaseDeployment'
  dependsOn: [
    sqlServerModule
  ]
  params: {
    location: location
    sqlServerName: sqlServerName
    databaseName: musicDbName
    tags: commonTags
  }
}

// Key Vault Module
module keyVaultModule 'modules/key-vaults/keyVault.bicep' = if (enableKeyVault) {
  name: 'keyVaultDeployment'
  params: {
    location: location
    keyVaultName: keyVaultName
    allowedSubnets: enableVNetIntegration ? [vnetModule.outputs.vnetIntegrationSubnetId] : []
    createPrivateEndpoint: enablePrivateEndpoints
    privateEndpointSubnetId: enablePrivateEndpoints ? vnetModule.outputs.privateEndpointSubnetId : ''
    privateDnsZoneId: enablePrivateEndpoints ? privateDnsZonesModule!.outputs.keyVaultPrivateDnsZoneId : ''
    roleAssignments: flatten([
      [
        {
          principalId: customerPublicWebAppModule.outputs.principalId
          roleDefinitionId: '4633458b-17de-408a-b874-0445c86b69e6' // Key Vault Secrets User
        }
        {
          principalId: customerSiteWebAppModule.outputs.principalId
          roleDefinitionId: '4633458b-17de-408a-b874-0445c86b69e6' // Key Vault Secrets User
        }
        {
          principalId: adminPublicWebAppModule.outputs.principalId
          roleDefinitionId: '4633458b-17de-408a-b874-0445c86b69e6' // Key Vault Secrets User
        }
        {
          principalId: adminSiteWebAppModule.outputs.principalId
          roleDefinitionId: '4633458b-17de-408a-b874-0445c86b69e6' // Key Vault Secrets User
        }
        {
          principalId: videoApiWebAppModule.outputs.principalId
          roleDefinitionId: '4633458b-17de-408a-b874-0445c86b69e6' // Key Vault Secrets User
        }
        {
          principalId: musicApiWebAppModule.outputs.principalId
          roleDefinitionId: '4633458b-17de-408a-b874-0445c86b69e6' // Key Vault Secrets User
        }
      ]
      enableFunctionApps ? [
        {
          principalId: adminFunctionAppModule!.outputs.principalId
          roleDefinitionId: '4633458b-17de-408a-b874-0445c86b69e6' // Key Vault Secrets User
        }
        {
          principalId: customerFunctionAppModule!.outputs.principalId
          roleDefinitionId: '4633458b-17de-408a-b874-0445c86b69e6' // Key Vault Secrets User
        }
        {
          principalId: musicFunctionAppModule!.outputs.principalId
          roleDefinitionId: '4633458b-17de-408a-b874-0445c86b69e6' // Key Vault Secrets User
        }
        {
          principalId: videoFunctionAppModule!.outputs.principalId
          roleDefinitionId: '4633458b-17de-408a-b874-0445c86b69e6' // Key Vault Secrets User
        }
      ] : []
    ])
    tags: commonTags
  }
}

// Consolidated Private DNS Zones Module
module privateDnsZonesModule 'modules/private-dns-zones/privateDNSZones.bicep' = if (enablePrivateEndpoints) {
  name: 'privateDnsZonesDeployment'
  params: {
    enablePrivateEndpoints: enablePrivateEndpoints
    vnetId: vnetModule.outputs.vnetId
    vnetName: vnetName
    customerSiteWebAppName: customerSiteWebAppName
    adminSiteWebAppName: adminSiteWebAppName
    videoApiWebAppName: videoApiWebAppName
    musicApiWebAppName: musicApiWebAppName
    applicationGatewayPublicIP: enableApplicationGateway ? applicationGatewayModule!.outputs.publicIPAddress : '0.0.0.0'
    tags: commonTags
  }
}

// App Configuration Module
module appConfigModule 'modules/app-configurations/myAppConfiguration.bicep' = if (enableAppConfiguration) {
  name: 'appConfigurationDeployment'
  params: {
    location: location
    appConfigName: appConfigName
    createPrivateEndpoint: enablePrivateEndpoints
    privateEndpointSubnetId: enablePrivateEndpoints ? vnetModule.outputs.privateEndpointSubnetId : ''
    privateDnsZoneId: (enablePrivateEndpoints && enableAppConfiguration) ? privateDnsZonesModule!.outputs.appConfigPrivateDnsZoneId : ''
    // Consolidated Role Assignment Parameters
    roleAssignments: enableAppConfiguration ? concat(
      // Web Apps
      [
        {
          principalId: customerPublicWebAppModule.outputs.principalId
          roleDefinitionId: '516239f1-63e1-4d78-a4de-a74fb236a071' // App Configuration Data Reader
        }
        {
          principalId: customerSiteWebAppModule.outputs.principalId
          roleDefinitionId: '516239f1-63e1-4d78-a4de-a74fb236a071' // App Configuration Data Reader
        }
        {
          principalId: adminPublicWebAppModule.outputs.principalId
          roleDefinitionId: '516239f1-63e1-4d78-a4de-a74fb236a071' // App Configuration Data Reader
        }
        {
          principalId: adminSiteWebAppModule.outputs.principalId
          roleDefinitionId: '516239f1-63e1-4d78-a4de-a74fb236a071' // App Configuration Data Reader
        }
        {
          principalId: videoApiWebAppModule.outputs.principalId
          roleDefinitionId: '516239f1-63e1-4d78-a4de-a74fb236a071' // App Configuration Data Reader
        }
        {
          principalId: musicApiWebAppModule.outputs.principalId
          roleDefinitionId: '516239f1-63e1-4d78-a4de-a74fb236a071' // App Configuration Data Reader
        }
      ],
      // Function Apps (only when enabled)
      enableFunctionApps ? [
        {
          principalId: adminFunctionAppModule!.outputs.principalId
          roleDefinitionId: '516239f1-63e1-4d78-a4de-a74fb236a071' // App Configuration Data Reader
        }
        {
          principalId: customerFunctionAppModule!.outputs.principalId
          roleDefinitionId: '516239f1-63e1-4d78-a4de-a74fb236a071' // App Configuration Data Reader
        }
        {
          principalId: musicFunctionAppModule!.outputs.principalId
          roleDefinitionId: '516239f1-63e1-4d78-a4de-a74fb236a071' // App Configuration Data Reader
        }
        {
          principalId: videoFunctionAppModule!.outputs.principalId
          roleDefinitionId: '516239f1-63e1-4d78-a4de-a74fb236a071' // App Configuration Data Reader
        }
      ] : []
    ) : []
  }
}

// Blob Storage Module
module myStorageAccountModule 'modules/storage-accounts/myStorageAccount.bicep' = if (enableStorageAccount) {
  name: 'blobStorageDeployment'
  params: {
    location: location
    storageAccountName: storageAccountName
    storageAccountType: storageAccountType
    containerNames: blobContainerNames
    createPrivateEndpoint: enablePrivateEndpoints
    privateEndpointSubnetId: enablePrivateEndpoints ? vnetModule.outputs.privateEndpointSubnetId : ''
    privateDnsZoneIds: {
      blob: (enablePrivateEndpoints && enableStorageAccount) ? privateDnsZonesModule!.outputs.blobStoragePrivateDnsZoneId : ''
      file: (enablePrivateEndpoints && enableStorageAccount) ? privateDnsZonesModule!.outputs.fileStoragePrivateDnsZoneId : ''
      queue: (enablePrivateEndpoints && enableStorageAccount) ? privateDnsZonesModule!.outputs.queueStoragePrivateDnsZoneId : ''
      table: (enablePrivateEndpoints && enableStorageAccount) ? privateDnsZonesModule!.outputs.tableStoragePrivateDnsZoneId : ''
    }
    allowedSubnetIds: enableVNetIntegration ? [vnetModule.outputs.vnetIntegrationSubnetId] : []
    allowBlobPublicAccess: !enablePrivateEndpoints
    // Consolidated Role Assignment Parameters
    roleAssignments: enableStorageAccount ? concat(
      // Web App Role Assignments (Storage Blob Data Contributor)
      [
        {
          principalId: customerPublicWebAppModule.outputs.principalId
          roleDefinitionId: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
        }
        {
          principalId: customerSiteWebAppModule.outputs.principalId
          roleDefinitionId: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
        }
        {
          principalId: adminPublicWebAppModule.outputs.principalId
          roleDefinitionId: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
        }
        {
          principalId: adminSiteWebAppModule.outputs.principalId
          roleDefinitionId: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
        }
        {
          principalId: videoApiWebAppModule.outputs.principalId
          roleDefinitionId: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
        }
        {
          principalId: musicApiWebAppModule.outputs.principalId
          roleDefinitionId: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
        }
      ],
      // Function App Role Assignments (Storage Blob Data Contributor) - for application data access
      enableFunctionApps ? [
        {
          principalId: adminFunctionAppModule!.outputs.principalId
          roleDefinitionId: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
        }
        {
          principalId: customerFunctionAppModule!.outputs.principalId
          roleDefinitionId: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
        }
        {
          principalId: musicFunctionAppModule!.outputs.principalId
          roleDefinitionId: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
        }
        {
          principalId: videoFunctionAppModule!.outputs.principalId
          roleDefinitionId: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
        }
      ] : []
    ) : []
    tags: commonTags
  }
}

// Cosmos DB Module
module cosmosDbAccountModule 'modules/cosmos-accounts/myCosmosAccount.bicep' = if (enableCosmosDb) {
  name: 'cosmosDbAccountDeployment'
  params: {
    location: location
    cosmosAccountName: cosmosAccountName
    consistencyLevel: cosmosConsistencyLevel
    enableAutomaticFailover: cosmosEnableAutomaticFailover
    createPrivateEndpoint: enablePrivateEndpoints
    privateEndpointSubnetId: enablePrivateEndpoints ? vnetModule.outputs.privateEndpointSubnetId : ''
    privateDnsZoneId: (enablePrivateEndpoints && enableCosmosDb) ? privateDnsZonesModule!.outputs.cosmosPrivateDnsZoneId : ''
    allowedSubnets: enableVNetIntegration ? [vnetModule.outputs.vnetIntegrationSubnetId] : []
    enablePublicNetworkAccess: !enablePrivateEndpoints
    tags: commonTags
    // Consolidated Role Assignment Parameters
    roleAssignments: concat(
      // Web App Role Assignments (Cosmos DB Data Contributor)
      [
        {
          principalId: customerPublicWebAppModule.outputs.principalId
          roleDefinitionId: '5bd9cd88-fe45-4216-938b-f97437e15450'
        }
        {
          principalId: customerSiteWebAppModule.outputs.principalId
          roleDefinitionId: '5bd9cd88-fe45-4216-938b-f97437e15450'
        }
        {
          principalId: adminPublicWebAppModule.outputs.principalId
          roleDefinitionId: '5bd9cd88-fe45-4216-938b-f97437e15450'
        }
        {
          principalId: adminSiteWebAppModule.outputs.principalId
          roleDefinitionId: '5bd9cd88-fe45-4216-938b-f97437e15450'
        }
        {
          principalId: videoApiWebAppModule.outputs.principalId
          roleDefinitionId: '5bd9cd88-fe45-4216-938b-f97437e15450'
        }
        {
          principalId: musicApiWebAppModule.outputs.principalId
          roleDefinitionId: '5bd9cd88-fe45-4216-938b-f97437e15450'
        }
      ],
      // Function App Role Assignments (Cosmos DB Data Contributor) - only when enabled
      enableFunctionApps ? [
        {
          principalId: adminFunctionAppModule!.outputs.principalId
          roleDefinitionId: '5bd9cd88-fe45-4216-938b-f97437e15450'
        }
        {
          principalId: customerFunctionAppModule!.outputs.principalId
          roleDefinitionId: '5bd9cd88-fe45-4216-938b-f97437e15450'
        }
        {
          principalId: musicFunctionAppModule!.outputs.principalId
          roleDefinitionId: '5bd9cd88-fe45-4216-938b-f97437e15450'
        }
        {
          principalId: videoFunctionAppModule!.outputs.principalId
          roleDefinitionId: '5bd9cd88-fe45-4216-938b-f97437e15450'
        }
      ] : []
    )
    sqlRoleAssignments: concat(
      // Web App Role Assignments (Cosmos DB Built-in Data Contributor)
      [
        {
          principalId: customerPublicWebAppModule.outputs.principalId
          roleDefinitionId: '00000000-0000-0000-0000-000000000002' // Cosmos DB Built-in Data Contributor
        }
        {
          principalId: customerSiteWebAppModule.outputs.principalId
          roleDefinitionId: '00000000-0000-0000-0000-000000000002' // Cosmos DB Built-in Data Contributor
        }
        {
          principalId: adminPublicWebAppModule.outputs.principalId
          roleDefinitionId: '00000000-0000-0000-0000-000000000002' // Cosmos DB Built-in Data Contributor
        }
        {
          principalId: adminSiteWebAppModule.outputs.principalId
          roleDefinitionId: '00000000-0000-0000-0000-000000000002' // Cosmos DB Built-in Data Contributor
        }
        {
          principalId: videoApiWebAppModule.outputs.principalId
          roleDefinitionId: '00000000-0000-0000-0000-000000000002' // Cosmos DB Built-in Data Contributor
        }
        {
          principalId: musicApiWebAppModule.outputs.principalId
          roleDefinitionId: '00000000-0000-0000-0000-000000000002' // Cosmos DB Built-in Data Contributor
        }
      ],
      // Function App Role Assignments (Cosmos DB Built-in Data Contributor) - only when enabled
      enableFunctionApps ? [
        {
          principalId: adminFunctionAppModule!.outputs.principalId
          roleDefinitionId: '00000000-0000-0000-0000-000000000002' // Cosmos DB Built-in Data Contributor
        }
        {
          principalId: customerFunctionAppModule!.outputs.principalId
          roleDefinitionId: '00000000-0000-0000-0000-000000000002' // Cosmos DB Built-in Data Contributor
        }
        {
          principalId: musicFunctionAppModule!.outputs.principalId
          roleDefinitionId: '00000000-0000-0000-0000-000000000002' // Cosmos DB Built-in Data Contributor
        }
        {
          principalId: videoFunctionAppModule!.outputs.principalId
          roleDefinitionId: '00000000-0000-0000-0000-000000000002' // Cosmos DB Built-in Data Contributor
        }
      ] : []
    )
  }
}

// Individual Cosmos Database Modules
module cosmosAdminDatabaseModule 'modules/cosmos-databases/adminDb.bicep' = if (enableCosmosDb) {
  name: 'cosmosAdminDatabaseDeployment'
  params: {
    cosmosAccountName: cosmosAccountName
    cosmosAdminDbName: cosmosAdminDbName
    tags: commonTags
  }
  dependsOn: [
    cosmosDbAccountModule
  ]
}

module cosmosCustomerDatabaseModule 'modules/cosmos-databases/customerDb.bicep' = if (enableCosmosDb) {
  name: 'cosmosCustomerDatabaseDeployment'
  params: {
    cosmosAccountName: cosmosAccountName
    cosmosCustomerDbName: cosmosCustomerDbName
    tags: commonTags
  }
  dependsOn: [
    cosmosDbAccountModule
  ]
}

module cosmosMusicDatabaseModule 'modules/cosmos-databases/musicDb.bicep' = if (enableCosmosDb) {
  name: 'cosmosMusicDatabaseDeployment'
  params: {
    cosmosAccountName: cosmosAccountName
    cosmosMusicDbName: cosmosMusicDbName
    tags: commonTags
  }
  dependsOn: [
    cosmosDbAccountModule
  ]
}

module cosmosVideoDatabaseModule 'modules/cosmos-databases/videoDb.bicep' = if (enableCosmosDb) {
  name: 'cosmosVideoDatabaseDeployment'
  params: {
    cosmosAccountName: cosmosAccountName
    cosmosVideoDbName: cosmosVideoDbName
    tags: commonTags
  }
  dependsOn: [
    cosmosDbAccountModule
  ]
}

// Service Bus Namespace Module
module serviceBusNamespaceModule 'modules/service-bus-namespaces/myServiceBusNamespace.bicep' = if (enableServiceBus) {
  name: 'serviceBusNamespaceDeployment'
  params: {
    location: location
    namespaceName: serviceBusNamespaceName
    sku: serviceBusSku
    capacity: serviceBusCapacity
    zoneRedundant: serviceBusSku == 'Premium' ? true : false
    createPrivateEndpoint: enablePrivateEndpoints
    privateEndpointSubnetId: enablePrivateEndpoints ? vnetModule.outputs.privateEndpointSubnetId : ''
    privateDnsZoneId: (enablePrivateEndpoints && enableServiceBus) ? privateDnsZonesModule!.outputs.serviceBusPrivateDnsZoneId : ''
    allowedSubnetIds: enableVNetIntegration ? [vnetModule.outputs.vnetIntegrationSubnetId] : []
    allowedIpRanges: []
    topicNames: serviceBusTopicNames
    queueNames: serviceBusQueueNames
    subscriptions: serviceBusSubscriptions
    roleAssignments: concat(
      // App Services - Service Bus Data Contributor (can send and receive messages)
      [
        {
          principalId: customerPublicWebAppModule.outputs.principalId
          roleDefinitionId: '8d3b2e04-d1a1-4c5b-90ae-ff1c3a4de2f6' // Azure Service Bus Data Contributor
        }
        {
          principalId: customerSiteWebAppModule.outputs.principalId
          roleDefinitionId: '8d3b2e04-d1a1-4c5b-90ae-ff1c3a4de2f6' // Azure Service Bus Data Contributor
        }
        {
          principalId: adminPublicWebAppModule.outputs.principalId
          roleDefinitionId: '8d3b2e04-d1a1-4c5b-90ae-ff1c3a4de2f6' // Azure Service Bus Data Contributor
        }
        {
          principalId: adminSiteWebAppModule.outputs.principalId
          roleDefinitionId: '8d3b2e04-d1a1-4c5b-90ae-ff1c3a4de2f6' // Azure Service Bus Data Contributor
        }
        {
          principalId: videoApiWebAppModule.outputs.principalId
          roleDefinitionId: '8d3b2e04-d1a1-4c5b-90ae-ff1c3a4de2f6' // Azure Service Bus Data Contributor
        }
        {
          principalId: musicApiWebAppModule.outputs.principalId
          roleDefinitionId: '8d3b2e04-d1a1-4c5b-90ae-ff1c3a4de2f6' // Azure Service Bus Data Contributor
        }
      ],
      // Function Apps - Service Bus Data Contributor (only when enabled)
      enableFunctionApps ? [
        {
          principalId: adminFunctionAppModule!.outputs.principalId
          roleDefinitionId: '8d3b2e04-d1a1-4c5b-90ae-ff1c3a4de2f6' // Azure Service Bus Data Contributor
        }
        {
          principalId: customerFunctionAppModule!.outputs.principalId
          roleDefinitionId: '8d3b2e04-d1a1-4c5b-90ae-ff1c3a4de2f6' // Azure Service Bus Data Contributor
        }
        {
          principalId: musicFunctionAppModule!.outputs.principalId
          roleDefinitionId: '8d3b2e04-d1a1-4c5b-90ae-ff1c3a4de2f6' // Azure Service Bus Data Contributor
        }
        {
          principalId: videoFunctionAppModule!.outputs.principalId
          roleDefinitionId: '8d3b2e04-d1a1-4c5b-90ae-ff1c3a4de2f6' // Azure Service Bus Data Contributor
        }
      ] : []
    )
    tags: commonTags
  }
}

// Log Analytics Workspace Module (for Application Insights)
// NOTE: Application Insights resources are now embedded in individual web app and function app modules
module logAnalyticsWorkspaceModule 'modules/log-analytics-workspaces/logAnalyticsWorkspace.bicep' = if (enableApplicationInsights) {
  name: 'logAnalyticsWorkspaceDeployment'
  params: {
    location: location
    workspaceName: applicationInsightsWorkspaceName
    retentionInDays: retentionInDays
    tags: commonTags
  }
}

// Centralized Application Insights Module - All Apps
module applicationInsightsModule 'modules/application-insights/applicationInsights.bicep' = if (enableApplicationInsights) {
  name: 'applicationInsightsDeployment'
  params: {
    location: location
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceModule!.outputs.workspaceId
    // App Insights Names
    customerAppInsightsName: '${customerSiteWebAppName}-ai'
    adminAppInsightsName: '${adminSiteWebAppName}-ai'
    videoAppInsightsName: '${videoApiWebAppName}-ai'
    musicAppInsightsName: '${musicApiWebAppName}-ai'
    tags: commonTags
  }
}

// App Service Plan Module
module appServicePlanModule 'modules/app-service-plans/myAppServicePlan.bicep' = {
  name: 'appServicePlanDeployment'
  params: {
    location: location
    appServicePlanName: appServicePlanName
    tags: commonTags
  }
}

// Individual Web App Modules
module customerPublicWebAppModule 'modules/app-services/customerPublicWebApp.bicep' = {
  name: 'customerPublicWebAppDeployment'
  params: {
    location: location
    webAppName: customerPublicWebAppName
    appServicePlanId: appServicePlanModule.outputs.appServicePlanId
    enableVNetIntegration: enableVNetIntegration
    vnetIntegrationSubnetId: enableVNetIntegration ? vnetModule.outputs.vnetIntegrationSubnetId : ''
    tags: commonTags
  }
}

module customerSiteWebAppModule 'modules/app-services/customerSiteWebApp.bicep' = {
  name: 'customerSiteWebAppDeployment'
  params: {
    location: location
    webAppName: customerSiteWebAppName
    appServicePlanId: appServicePlanModule.outputs.appServicePlanId
    createPrivateEndpoint: enablePrivateEndpoints
    privateEndpointSubnetId: enablePrivateEndpoints ? vnetModule.outputs.privateEndpointSubnetId : ''
    privateDnsZoneId: enablePrivateEndpoints ? privateDnsZonesModule!.outputs.appServicePrivateDnsZoneId : ''
    enableVNetIntegration: enableVNetIntegration
    vnetIntegrationSubnetId: enableVNetIntegration ? vnetModule.outputs.vnetIntegrationSubnetId : ''
    tags: commonTags
  }
}

module adminPublicWebAppModule 'modules/app-services/adminPublicWebApp.bicep' = {
  name: 'adminPublicWebAppDeployment'
  params: {
    location: location
    webAppName: adminPublicWebAppName
    appServicePlanId: appServicePlanModule.outputs.appServicePlanId
    enableVNetIntegration: enableVNetIntegration
    vnetIntegrationSubnetId: enableVNetIntegration ? vnetModule.outputs.vnetIntegrationSubnetId : ''
    tags: commonTags
  }
}

module adminSiteWebAppModule 'modules/app-services/adminSiteWebApp.bicep' = {
  name: 'adminSiteWebAppDeployment'
  params: {
    location: location
    webAppName: adminSiteWebAppName
    appServicePlanId: appServicePlanModule.outputs.appServicePlanId
    createPrivateEndpoint: enablePrivateEndpoints
    privateEndpointSubnetId: enablePrivateEndpoints ? vnetModule.outputs.privateEndpointSubnetId : ''
    privateDnsZoneId: enablePrivateEndpoints ? privateDnsZonesModule!.outputs.appServicePrivateDnsZoneId : ''
    enableVNetIntegration: enableVNetIntegration
    vnetIntegrationSubnetId: enableVNetIntegration ? vnetModule.outputs.vnetIntegrationSubnetId : ''
    tags: commonTags
  }
}

module videoApiWebAppModule 'modules/app-services/videoApiWebApp.bicep' = {
  name: 'videoApiWebAppDeployment'
  params: {
    location: location
    webAppName: videoApiWebAppName
    appServicePlanId: appServicePlanModule.outputs.appServicePlanId
    createPrivateEndpoint: enablePrivateEndpoints
    privateEndpointSubnetId: enablePrivateEndpoints ? vnetModule.outputs.privateEndpointSubnetId : ''
    privateDnsZoneId: enablePrivateEndpoints ? privateDnsZonesModule!.outputs.appServicePrivateDnsZoneId : ''
    enableVNetIntegration: enableVNetIntegration
    vnetIntegrationSubnetId: enableVNetIntegration ? vnetModule.outputs.vnetIntegrationSubnetId : ''
    tags: commonTags
  }
}

module musicApiWebAppModule 'modules/app-services/musicApiWebApp.bicep' = {
  name: 'musicApiWebAppDeployment'
  params: {
    location: location
    webAppName: musicApiWebAppName
    appServicePlanId: appServicePlanModule.outputs.appServicePlanId
    createPrivateEndpoint: enablePrivateEndpoints
    privateEndpointSubnetId: enablePrivateEndpoints ? vnetModule.outputs.privateEndpointSubnetId : ''
    privateDnsZoneId: enablePrivateEndpoints ? privateDnsZonesModule!.outputs.appServicePrivateDnsZoneId : ''
    enableVNetIntegration: enableVNetIntegration
    vnetIntegrationSubnetId: enableVNetIntegration ? vnetModule.outputs.vnetIntegrationSubnetId : ''
    tags: commonTags
  }
}

// Individual Function App Modules
module adminFunctionAppModule 'modules/azure-functions/adminFunctionApp.bicep' = if (enableFunctionApps) {
  name: 'adminFunctionAppDeployment'
  params: {
    location: location
    functionAppName: adminFunctionAppName
    appServicePlanId: appServicePlanModule.outputs.appServicePlanId
    storageAccountName: functionAppsStorageAccountName
    createPrivateEndpoint: enablePrivateEndpoints
    privateEndpointSubnetId: enablePrivateEndpoints ? vnetModule.outputs.privateEndpointSubnetId : ''
    privateDnsZoneId: enablePrivateEndpoints ? privateDnsZonesModule!.outputs.appServicePrivateDnsZoneId : ''
    enableVNetIntegration: enableVNetIntegration
    vnetIntegrationSubnetId: enableVNetIntegration ? vnetModule.outputs.vnetIntegrationSubnetId : ''
    applicationInsightsConnectionString: enableApplicationInsights ? applicationInsightsModule!.outputs.adminAppInsights.connectionString : ''
    tags: commonTags
  }
}

module customerFunctionAppModule 'modules/azure-functions/customerFunctionApp.bicep' = if (enableFunctionApps) {
  name: 'customerFunctionAppDeployment'
  params: {
    location: location
    functionAppName: customerFunctionAppName
    appServicePlanId: appServicePlanModule.outputs.appServicePlanId
    storageAccountName: functionAppsStorageAccountName
    createPrivateEndpoint: enablePrivateEndpoints
    privateEndpointSubnetId: enablePrivateEndpoints ? vnetModule.outputs.privateEndpointSubnetId : ''
    privateDnsZoneId: enablePrivateEndpoints ? privateDnsZonesModule!.outputs.appServicePrivateDnsZoneId : ''
    enableVNetIntegration: enableVNetIntegration
    vnetIntegrationSubnetId: enableVNetIntegration ? vnetModule.outputs.vnetIntegrationSubnetId : ''
    applicationInsightsConnectionString: enableApplicationInsights ? applicationInsightsModule!.outputs.customerAppInsights.connectionString : ''
    tags: commonTags
  }
}

module musicFunctionAppModule 'modules/azure-functions/musicFunctionApp.bicep' = if (enableFunctionApps) {
  name: 'musicFunctionAppDeployment'
  params: {
    location: location
    functionAppName: musicFunctionAppName
    appServicePlanId: appServicePlanModule.outputs.appServicePlanId
    storageAccountName: functionAppsStorageAccountName
    createPrivateEndpoint: enablePrivateEndpoints
    privateEndpointSubnetId: enablePrivateEndpoints ? vnetModule.outputs.privateEndpointSubnetId : ''
    privateDnsZoneId: enablePrivateEndpoints ? privateDnsZonesModule!.outputs.appServicePrivateDnsZoneId : ''
    enableVNetIntegration: enableVNetIntegration
    vnetIntegrationSubnetId: enableVNetIntegration ? vnetModule.outputs.vnetIntegrationSubnetId : ''
    applicationInsightsConnectionString: enableApplicationInsights ? applicationInsightsModule!.outputs.musicAppInsights.connectionString : ''
    tags: commonTags
  }
}

module videoFunctionAppModule 'modules/azure-functions/videoFunctionApp.bicep' = if (enableFunctionApps) {
  name: 'videoFunctionAppDeployment'
  params: {
    location: location
    functionAppName: videoFunctionAppName
    appServicePlanId: appServicePlanModule.outputs.appServicePlanId
    storageAccountName: functionAppsStorageAccountName
    createPrivateEndpoint: enablePrivateEndpoints
    privateEndpointSubnetId: enablePrivateEndpoints ? vnetModule.outputs.privateEndpointSubnetId : ''
    privateDnsZoneId: enablePrivateEndpoints ? privateDnsZonesModule!.outputs.appServicePrivateDnsZoneId : ''
    enableVNetIntegration: enableVNetIntegration
    vnetIntegrationSubnetId: enableVNetIntegration ? vnetModule.outputs.vnetIntegrationSubnetId : ''
    applicationInsightsConnectionString: enableApplicationInsights ? applicationInsightsModule!.outputs.videoAppInsights.connectionString : ''
    tags: commonTags
  }
}

// Function Apps Storage Account Module (deployed after App Service Plan - for function runtime storage only)
module functionAppsStorageModule 'modules/storage-accounts/functionAppsStorageAccount.bicep' = if (enableFunctionApps) {
  name: 'functionAppsStorageDeployment'
  params: {
    location: location
    storageAccountName: functionAppsStorageAccountName
    storageAccountType: storageAccountType
    accessTier: 'Hot'
    minimumTlsVersion: 'TLS1_2'
    createPrivateEndpoint: enablePrivateEndpoints
    privateEndpointSubnetId: enablePrivateEndpoints ? vnetModule.outputs.privateEndpointSubnetId : ''
    privateDnsZoneIds: {
      blob: (enablePrivateEndpoints && enableFunctionApps) ? privateDnsZonesModule!.outputs.blobStoragePrivateDnsZoneId : ''
      file: (enablePrivateEndpoints && enableFunctionApps) ? privateDnsZonesModule!.outputs.fileStoragePrivateDnsZoneId : ''
      queue: (enablePrivateEndpoints && enableFunctionApps) ? privateDnsZonesModule!.outputs.queueStoragePrivateDnsZoneId : ''
      table: (enablePrivateEndpoints && enableFunctionApps) ? privateDnsZonesModule!.outputs.tableStoragePrivateDnsZoneId : ''
    }
    allowedIpRanges: []
    bypassAzureServices: true
    allowedSubnetIds: enableVNetIntegration ? [vnetModule.outputs.vnetIntegrationSubnetId] : []
    allowBlobPublicAccess: !enablePrivateEndpoints
    // No role assignments needed - function apps use connection strings for runtime storage
    roleAssignments: []
    tags: union(commonTags, {
      Purpose: 'FunctionAppsRuntimeStorage'
    })
  }
}

// Application Gateway Module
module applicationGatewayModule 'modules/application-gateways/my-gateway/applicationGateway.bicep' = if (enableApplicationGateway) {
  name: 'applicationGatewayDeployment'
  params: {
    location: location
    vnetName: vnetName
    appGatewaySubnetId: vnetModule.outputs.appGatewaySubnetId
    customerPublicWebAppName: customerPublicWebAppName
    customerSiteWebAppName: customerSiteWebAppName
    adminPublicWebAppName: adminPublicWebAppName
    adminSiteWebAppName: adminSiteWebAppName
    // WAF Configuration
    wafConfig: {
      enabled: enableWAF
      firewallMode: wafMode
      ruleSetType: 'OWASP'
      ruleSetVersion: wafRuleSetVersion
      disabledRuleGroups: []
      requestBodyCheck: wafRequestBodyCheck
      maxRequestBodySizeInKb: wafMaxRequestBodySizeInKb
      fileUploadLimitInMb: wafFileUploadLimitInMb
    }
    tags: commonTags
  }
}

// API Management Module
module apiManagementModule 'modules/api-managements/my-api-management/myApiManagement.bicep' = if (enableApiManagement) {
  name: 'apiManagementDeployment'
  params: {
    location: location
    apiManagementName: apiManagementName
    publisherEmail: publisherEmail
    publisherName: publisherName
    vnetId: vnetModule.outputs.vnetId
    apiManagementSubnetName: 'APIManagementSubnet'
    videoApiUrl: 'https://${videoApiWebAppName}.azurewebsites.net'
    musicApiUrl: 'https://${musicApiWebAppName}.azurewebsites.net'
    apiManagementSku: apiManagementSku
    apiManagementCapacity: apiManagementCapacity
    tags: commonTags
  }
}

// Test VM Module
module testVMModule 'modules/virtual-machines/testVM.bicep' = if (enableTestVM) {
  name: 'testVMDeployment'
  params: {
    location: location
    vmName: 'test-vm'
    vmSize: 'Standard_B1s'
    adminUsername: vmAdminUsername
    adminPassword: vmAdminPassword
    subnetId: vnetModule.outputs.testVMSubnetId
    includePublicIP: true
    tags: commonTags
  }
}

// Output SQL Server information for connection string creation
output sqlServerInfo object = enableSqlServer ? {
  serverName: sqlServerModule!.outputs.sqlServerName
  serverFqdn: sqlServerModule!.outputs.sqlServerFqdn
  databaseNames: [
    customerDatabaseModule!.outputs.databaseName
    adminDatabaseModule!.outputs.databaseName
    videoDatabaseModule!.outputs.databaseName
    musicDatabaseModule!.outputs.databaseName
  ]
} : {
  serverName: ''
  serverFqdn: ''
  databaseNames: []
}

// Output Application Gateway Public IP
output applicationGatewayPublicIP string = enableApplicationGateway ? applicationGatewayModule!.outputs.publicIPAddress : ''

// Output Application Gateway WAF Information
output applicationGatewayWAF object = enableApplicationGateway ? {
  wafEnabled: applicationGatewayModule!.outputs.wafEnabled
  wafPolicyId: applicationGatewayModule!.outputs.wafPolicyId
  wafPolicyName: applicationGatewayModule!.outputs.wafPolicyName
  wafMode: wafMode
  ruleSetVersion: wafRuleSetVersion
} : {
  wafEnabled: false
  wafPolicyId: ''
  wafPolicyName: ''
  wafMode: ''
  ruleSetVersion: ''
}

// Output Web App URLs accessible through Application Gateway
output webAppUrls array = [
  {
    name: customerPublicWebAppName
    url: 'http://${customerPublicWebAppName}.azurewebsites.net'
  }
  {
    name: customerSiteWebAppName
    url: 'http://${customerSiteWebAppName}.azurewebsites.net'
  }
  {
    name: adminPublicWebAppName
    url: 'http://${adminPublicWebAppName}.azurewebsites.net'
  }
  {
    name: adminSiteWebAppName
    url: 'http://${adminSiteWebAppName}.azurewebsites.net'
  }
  {
    name: videoApiWebAppName
    url: 'http://${videoApiWebAppName}.azurewebsites.net'
  }
  {
    name: musicApiWebAppName
    url: 'http://${musicApiWebAppName}.azurewebsites.net'
  }
]

// Output Test VM information for access
output testVMInfo object = enableTestVM ? {
  vmName: testVMModule!.outputs.vmName
  vmPrivateIP: testVMModule!.outputs.vmPrivateIP
  hasPublicIP: testVMModule!.outputs.hasPublicIP
  publicIPResourceId: testVMModule!.outputs.vmPublicIPResourceId
} : {
  vmName: ''
  vmPrivateIP: ''
  hasPublicIP: false
  publicIPResourceId: ''
}

// Output API Management Gateway URL
output apiManagementGatewayUrl string = enableApiManagement ? apiManagementModule!.outputs.apiManagementGatewayUrl : ''

// Output API Management Developer Portal URL
output apiManagementDeveloperPortalUrl string = enableApiManagement ? apiManagementModule!.outputs.apiManagementDeveloperPortalUrl : ''

// Output API Management Management URL
output apiManagementManagementUrl string = enableApiManagement ? apiManagementModule!.outputs.apiManagementManagementUrl : ''

// Output API Endpoints
output apiEndpoints array = enableApiManagement ? [
  {
    name: 'Video API'
    url: apiManagementModule!.outputs.videoApiUrl
    description: 'Video API through API Management'
  }
  {
    name: 'Music API'
    url: apiManagementModule!.outputs.musicApiUrl
    description: 'Music API through API Management'
  }
] : []

// Comprehensive Web Apps Information (reconstructed from individual modules)
output webAppsInfo array = [
  {
    index: 0
    name: customerPublicWebAppModule.outputs.webAppName
    id: customerPublicWebAppModule.outputs.webAppId
    defaultHostName: customerPublicWebAppModule.outputs.defaultHostName
    hasPrivateEndpoint: false
    privateEndpointId: ''
    privateDnsName: ''
    publicUrl: 'https://${customerPublicWebAppModule.outputs.defaultHostName}'
    isPublicAccessEnabled: true
  }
  {
    index: 1
    name: customerSiteWebAppModule.outputs.webAppName
    id: customerSiteWebAppModule.outputs.webAppId
    defaultHostName: customerSiteWebAppModule.outputs.defaultHostName
    hasPrivateEndpoint: customerSiteWebAppModule.outputs.hasPrivateEndpoint
    privateEndpointId: ''
    privateDnsName: '${customerSiteWebAppModule.outputs.webAppName}.privatelink.azurewebsites.net'
    publicUrl: 'https://${customerSiteWebAppModule.outputs.defaultHostName}'
    isPublicAccessEnabled: false
  }
  {
    index: 2
    name: adminPublicWebAppModule.outputs.webAppName
    id: adminPublicWebAppModule.outputs.webAppId
    defaultHostName: adminPublicWebAppModule.outputs.defaultHostName
    hasPrivateEndpoint: false
    privateEndpointId: ''
    privateDnsName: ''
    publicUrl: 'https://${adminPublicWebAppModule.outputs.defaultHostName}'
    isPublicAccessEnabled: true
  }
  {
    index: 3
    name: adminSiteWebAppModule.outputs.webAppName
    id: adminSiteWebAppModule.outputs.webAppId
    defaultHostName: adminSiteWebAppModule.outputs.defaultHostName
    hasPrivateEndpoint: adminSiteWebAppModule.outputs.hasPrivateEndpoint
    privateEndpointId: ''
    privateDnsName: '${adminSiteWebAppModule.outputs.webAppName}.privatelink.azurewebsites.net'
    publicUrl: 'https://${adminSiteWebAppModule.outputs.defaultHostName}'
    isPublicAccessEnabled: false
  }
  {
    index: 4
    name: videoApiWebAppModule.outputs.webAppName
    id: videoApiWebAppModule.outputs.webAppId
    defaultHostName: videoApiWebAppModule.outputs.defaultHostName
    hasPrivateEndpoint: videoApiWebAppModule.outputs.hasPrivateEndpoint
    privateEndpointId: ''
    privateDnsName: '${videoApiWebAppModule.outputs.webAppName}.privatelink.azurewebsites.net'
    publicUrl: 'https://${videoApiWebAppModule.outputs.defaultHostName}'
    isPublicAccessEnabled: false
  }
  {
    index: 5
    name: musicApiWebAppModule.outputs.webAppName
    id: musicApiWebAppModule.outputs.webAppId
    defaultHostName: musicApiWebAppModule.outputs.defaultHostName
    hasPrivateEndpoint: musicApiWebAppModule.outputs.hasPrivateEndpoint
    privateEndpointId: ''
    privateDnsName: '${musicApiWebAppModule.outputs.webAppName}.privatelink.azurewebsites.net'
    publicUrl: 'https://${musicApiWebAppModule.outputs.defaultHostName}'
    isPublicAccessEnabled: false
  }
]

// Internal DNS Names for Private Access (from consolidated private DNS zones module)
output internalDnsNames array = enablePrivateEndpoints ? privateDnsZonesModule!.outputs.internalDnsNames : []

// Key Vault Information
output keyVaultInfo object = enableKeyVault ? {
  keyVaultId: keyVaultModule!.outputs.keyVaultId
  keyVaultName: keyVaultModule!.outputs.keyVaultName
  keyVaultUri: keyVaultModule!.outputs.keyVaultUri
  resourceGroup: keyVaultModule!.outputs.keyVaultResourceGroup
} : {
  keyVaultId: ''
  keyVaultName: ''
  keyVaultUri: ''
  resourceGroup: ''
}

// App Configuration Information
output appConfigInfo object = enableAppConfiguration ? {
  appConfigId: appConfigModule!.outputs.appConfigId
  appConfigName: appConfigModule!.outputs.appConfigName
  endpoint: appConfigModule!.outputs.endpoint
  hasPrivateEndpoint: appConfigModule!.outputs.hasPrivateEndpoint
  privateEndpointId: appConfigModule!.outputs.privateEndpointId
  privateEndpointName: appConfigModule!.outputs.privateEndpointName
} : {
  appConfigId: ''
  appConfigName: ''
  endpoint: ''
  hasPrivateEndpoint: false
  privateEndpointId: ''
  privateEndpointName: ''
}

// Storage Account Information
output storageAccountInfo object = enableStorageAccount ? {
  storageAccountId: myStorageAccountModule!.outputs.storageAccountId
  storageAccountName: myStorageAccountModule!.outputs.storageAccountName
  blobEndpoint: myStorageAccountModule!.outputs.storageAccountPrimaryBlobEndpoint
  containerNames: myStorageAccountModule!.outputs.containerNames
  hasPrivateEndpoints: myStorageAccountModule!.outputs.hasPrivateEndpoints
  privateEndpoints: myStorageAccountModule!.outputs.privateEndpoints
} : {
  storageAccountId: ''
  storageAccountName: ''
  blobEndpoint: ''
  containerNames: []
  hasPrivateEndpoints: false
  privateEndpoints: []
}

// Function Apps Storage Account Information
output functionAppsStorageInfo object = enableFunctionApps ? {
  storageAccountId: functionAppsStorageModule!.outputs.storageAccountId
  storageAccountName: functionAppsStorageModule!.outputs.storageAccountName
  primaryEndpoints: functionAppsStorageModule!.outputs.primaryEndpoints
  hasPrivateEndpoints: functionAppsStorageModule!.outputs.hasPrivateEndpoints
  privateEndpoints: functionAppsStorageModule!.outputs.privateEndpoints
} : {
  storageAccountId: ''
  storageAccountName: ''
  primaryEndpoints: {}
  hasPrivateEndpoints: false
  privateEndpoints: []
}

// Cosmos DB Outputs
output cosmosDbInfo object = enableCosmosDb ? {
  cosmosAccountId: cosmosDbAccountModule!.outputs.cosmosAccountId
  cosmosAccountName: cosmosDbAccountModule!.outputs.cosmosAccountName
  cosmosAccountEndpoint: cosmosDbAccountModule!.outputs.cosmosAccountEndpoint
  databaseNames: [cosmosAdminDbName, cosmosCustomerDbName, cosmosMusicDbName, cosmosVideoDbName]
  adminDatabase: {
    databaseId: cosmosAdminDatabaseModule!.outputs.databaseId
    databaseName: cosmosAdminDatabaseModule!.outputs.databaseName
    containerNames: [cosmosAdminDatabaseModule!.outputs.adminContainerName]
  }
  customerDatabase: {
    databaseId: cosmosCustomerDatabaseModule!.outputs.databaseId
    databaseName: cosmosCustomerDatabaseModule!.outputs.databaseName
    containerNames: [cosmosCustomerDatabaseModule!.outputs.customerContainerName]
  }
  musicDatabase: {
    databaseId: cosmosMusicDatabaseModule!.outputs.databaseId
    databaseName: cosmosMusicDatabaseModule!.outputs.databaseName
    containerNames: [cosmosMusicDatabaseModule!.outputs.musicContainerName]
  }
  videoDatabase: {
    databaseId: cosmosVideoDatabaseModule!.outputs.databaseId
    databaseName: cosmosVideoDatabaseModule!.outputs.databaseName
    containerNames: [cosmosVideoDatabaseModule!.outputs.videoContainerName]
  }
  hasPrivateEndpoint: cosmosDbAccountModule!.outputs.hasPrivateEndpoint
  privateEndpointId: cosmosDbAccountModule!.outputs.privateEndpointId
  privateEndpointName: cosmosDbAccountModule!.outputs.privateEndpointName
} : {
  cosmosAccountId: ''
  cosmosAccountName: ''
  cosmosAccountEndpoint: ''
  databaseNames: []
  adminDatabase: {}
  customerDatabase: {}
  musicDatabase: {}
  videoDatabase: {}
  hasPrivateEndpoint: false
  privateEndpointId: ''
  privateEndpointName: ''
}

// Function Apps Outputs
output functionAppsInfo object = enableFunctionApps ? {
  adminFunctionApp: {
    functionAppId: adminFunctionAppModule!.outputs.functionAppId
    functionAppName: adminFunctionAppModule!.outputs.functionAppName
    functionAppUrl: adminFunctionAppModule!.outputs.functionAppUrl
    hasPrivateEndpoint: false
  }
  customerFunctionApp: {
    functionAppId: customerFunctionAppModule!.outputs.functionAppId
    functionAppName: customerFunctionAppModule!.outputs.functionAppName
    functionAppUrl: customerFunctionAppModule!.outputs.functionAppUrl
    hasPrivateEndpoint: false
  }
  musicFunctionApp: {
    functionAppId: musicFunctionAppModule!.outputs.functionAppId
    functionAppName: musicFunctionAppModule!.outputs.functionAppName
    functionAppUrl: musicFunctionAppModule!.outputs.functionAppUrl
    hasPrivateEndpoint: false
  }
  videoFunctionApp: {
    functionAppId: videoFunctionAppModule!.outputs.functionAppId
    functionAppName: videoFunctionAppModule!.outputs.functionAppName
    functionAppUrl: videoFunctionAppModule!.outputs.functionAppUrl
    hasPrivateEndpoint: false
  }
} : {
  adminFunctionApp: {}
  customerFunctionApp: {}
  musicFunctionApp: {}
  videoFunctionApp: {}
}

// Service Bus Outputs
output serviceBusInfo object = enableServiceBus ? {
  namespaceName: serviceBusNamespaceModule!.outputs.serviceBusNamespaceName
  namespaceId: serviceBusNamespaceModule!.outputs.serviceBusNamespaceId
  hostName: serviceBusNamespaceModule!.outputs.serviceBusNamespaceHostName
  hasPrivateEndpoint: serviceBusNamespaceModule!.outputs.hasPrivateEndpoint
  privateEndpointId: serviceBusNamespaceModule!.outputs.privateEndpointId
  privateEndpointName: serviceBusNamespaceModule!.outputs.privateEndpointName
  topicNames: serviceBusTopicNames
  queueNames: serviceBusQueueNames
  subscriptionNames: serviceBusSubscriptions
} : {
  namespaceName: ''
  namespaceId: ''
  hostName: ''
  hasPrivateEndpoint: false
  privateEndpointId: ''
  privateEndpointName: ''
  topicNames: []
  queueNames: []
  subscriptionNames: []
}

// Application Insights Outputs
output applicationInsightsInfo object = enableApplicationInsights ? {
  logAnalyticsWorkspaceId: logAnalyticsWorkspaceModule!.outputs.workspaceId
  logAnalyticsWorkspaceName: logAnalyticsWorkspaceModule!.outputs.workspaceName
  webApps: {
    customerSite: {
      appInsightsId: applicationInsightsModule!.outputs.customerAppInsights.applicationInsightsId
      appInsightsName: applicationInsightsModule!.outputs.customerAppInsights.applicationInsightsName
      connectionString: applicationInsightsModule!.outputs.customerAppInsights.connectionString
      instrumentationKey: applicationInsightsModule!.outputs.customerAppInsights.instrumentationKey
    }
    adminSite: {
      appInsightsId: applicationInsightsModule!.outputs.adminAppInsights.applicationInsightsId
      appInsightsName: applicationInsightsModule!.outputs.adminAppInsights.applicationInsightsName
      connectionString: applicationInsightsModule!.outputs.adminAppInsights.connectionString
      instrumentationKey: applicationInsightsModule!.outputs.adminAppInsights.instrumentationKey
    }
    videoApi: {
      appInsightsId: applicationInsightsModule!.outputs.videoAppInsights.applicationInsightsId
      appInsightsName: applicationInsightsModule!.outputs.videoAppInsights.applicationInsightsName
      connectionString: applicationInsightsModule!.outputs.videoAppInsights.connectionString
      instrumentationKey: applicationInsightsModule!.outputs.videoAppInsights.instrumentationKey
    }
    musicApi: {
      appInsightsId: applicationInsightsModule!.outputs.musicAppInsights.applicationInsightsId
      appInsightsName: applicationInsightsModule!.outputs.musicAppInsights.applicationInsightsName
      connectionString: applicationInsightsModule!.outputs.musicAppInsights.connectionString
      instrumentationKey: applicationInsightsModule!.outputs.musicAppInsights.instrumentationKey
    }
  }
} : {
  logAnalyticsWorkspaceId: ''
  logAnalyticsWorkspaceName: ''
  webApps: {}
}

// Network Security Group Outputs
output apiManagementNSGId string = apiManagementNSGModule.outputs.apiManagementNSGId
