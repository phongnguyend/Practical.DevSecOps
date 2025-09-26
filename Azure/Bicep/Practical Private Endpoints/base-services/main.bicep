param location string = 'southeastasia'

// Nested parameter objects to match new parameter file structure
param featureFlags object = {
  enablePrivateEndpoints: false
  enableVNetIntegration: false
  enableApplicationGateway: false
  enableApiManagement: false
  enableTestVM: false
  enableSqlServer: false
  enableKeyVault: false
  enableAppConfiguration: false
  enableBlobStorage: false
  enableCosmosDb: false
  enableFunctionApps: false
  enableServiceBus: false
  enableApplicationInsights: false
}

param networking object = {
  vnetName: 'PracticalPrivateEndpoints-vnet'
}

param applicationGateway object = {
  enableWAF: true
  wafMode: 'Prevention'
  wafRuleSetVersion: '3.2'
  wafRequestBodyCheck: true
  wafMaxRequestBodySizeInKb: 128
  wafFileUploadLimitInMb: 100
}

param sqlServer object = {
  serverName: 'PracticalPrivateEndpoints'
  adminUsername: 'PracticalPrivateEndpoints'
  databases: {
    customerDbName: 'PracticalPrivateEndpoints-CUSTOMER-DB'
    adminDbName: 'PracticalPrivateEndpoints-ADMIN-DB'
    videoDbName: 'PracticalPrivateEndpoints-VIDEO-DB'
    musicDbName: 'PracticalPrivateEndpoints-MUSIC-DB'
  }
}

param cosmosDb object = {
  accountName: 'practicalpe-cosmos-${uniqueString(resourceGroup().id)}'
  consistencyLevel: 'Session'
  enableAutomaticFailover: true
  databases: {
    adminDbName: 'PracticalPrivateEndpoints-ADMIN-COSMOS-DB'
    customerDbName: 'PracticalPrivateEndpoints-CUSTOMER-COSMOS-DB'
    musicDbName: 'PracticalPrivateEndpoints-MUSIC-COSMOS-DB'
    videoDbName: 'PracticalPrivateEndpoints-VIDEO-COSMOS-DB'
  }
}

param storage object = {
  accountName: 'practicalendpointsblob'
  functionAppsAccountName: 'practicalfuncappsst'
  accountType: 'Standard_LRS'
  blobContainerNames: [
    'documents'
    'images'
    'backups'
    'logs'
  ]
}

param keyVault object = {
  name: 'practicalendpointskv'
}

param appConfiguration object = {
  name: 'PracticalPrivateEndpoints-config'
}

param appService object = {
  planName: 'PracticalPrivateEndpoints'
  webApps: {
    customerPublicWebAppName: 'PracticalPrivateEndpoints-CUSTOMER-PUBLIC'
    customerSiteWebAppName: 'PracticalPrivateEndpoints-CUSTOMER-SITE'
    adminPublicWebAppName: 'PracticalPrivateEndpoints-ADMIN-PUBLIC'
    adminSiteWebAppName: 'PracticalPrivateEndpoints-ADMIN-SITE'
    videoApiWebAppName: 'PracticalPrivateEndpoints-VIDEO-API'
    musicApiWebAppName: 'PracticalPrivateEndpoints-MUSIC-API'
  }
}

param azureFunctions object = {
  adminFunctionAppName: 'PracticalPrivateEndpoints-ADMIN-FUNC'
  customerFunctionAppName: 'PracticalPrivateEndpoints-CUSTOMER-FUNC'
  musicFunctionAppName: 'PracticalPrivateEndpoints-MUSIC-FUNC'
  videoFunctionAppName: 'PracticalPrivateEndpoints-VIDEO-FUNC'
}

param apiManagement object = {
  name: 'PracticalPrivateEndpoints-apim'
  sku: 'Premium'
  capacity: 1
  publisherEmail: 'admin@practical.devsecops'
  publisherName: 'Practical DevSecOps'
}

param monitoring object = {
  workspaceName: 'PracticalPrivateEndpoints-law'
  retentionInDays: 30
}

param serviceBus object = {
  namespaceName: 'PracticalPrivateEndpoints-sb-${uniqueString(resourceGroup().id)}'
  sku: 'Premium'
  capacity: 1
  topicNames: [
    'customer-events'
    'admin-events'
    'video-events'
    'music-events'
  ]
  queueNames: [
    'customer-queue'
    'admin-queue'
    'video-queue'
    'music-queue'
  ]
  subscriptions: [
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
}

param virtualMachine object = {
  adminUsername: 'testadmin'
}

// Secure parameters (kept separate as they can't be in objects with defaults)
@secure()
param adminPassword string = 'sqladmin123!@#'
@secure()
param vmAdminPassword string = 'TestVM123!@#'

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
    name: '${networking.vnetName}-apim-nsg'
    tags: commonTags
  }
}

// Virtual Network Module
module vnetModule 'modules/virtual-networks/virtualNetwork.bicep' = {
  name: 'virtualNetworkDeployment'
  params: {
    location: location
    vnetName: networking.vnetName
    vnetAddressPrefix: '10.0.0.0/16'
    apiManagementNSGId: apiManagementNSGModule.outputs.apiManagementNSGId
    tags: commonTags
  }
}

// SQL Server Module
module sqlServerModule 'modules/sql-servers/mySqlServer.bicep' = if (featureFlags.enableSqlServer) {
  name: 'sqlServerDeployment'
  params: {
    location: location
    sqlServerName: sqlServer.serverName
    adminUsername: sqlServer.adminUsername
    adminPassword: adminPassword
    allowedSubnets: featureFlags.enableVNetIntegration ? [vnetModule.outputs.vnetIntegrationSubnetId] : []
    tags: commonTags
  }
}

// Individual Database Modules (depend on SQL Server)
module customerDatabaseModule 'modules/sql-server-databases/customerDb.bicep' = if (featureFlags.enableSqlServer) {
  name: 'customerDatabaseDeployment'
  dependsOn: [
    sqlServerModule
  ]
  params: {
    location: location
    sqlServerName: sqlServer.serverName
    databaseName: sqlServer.databases.customerDbName
    tags: commonTags
  }
}

module adminDatabaseModule 'modules/sql-server-databases/adminDb.bicep' = if (featureFlags.enableSqlServer) {
  name: 'adminDatabaseDeployment'
  dependsOn: [
    sqlServerModule
  ]
  params: {
    location: location
    sqlServerName: sqlServer.serverName
    databaseName: sqlServer.databases.adminDbName
    tags: commonTags
  }
}

module videoDatabaseModule 'modules/sql-server-databases/videoDb.bicep' = if (featureFlags.enableSqlServer) {
  name: 'videoDatabaseDeployment'
  dependsOn: [
    sqlServerModule
  ]
  params: {
    location: location
    sqlServerName: sqlServer.serverName
    databaseName: sqlServer.databases.videoDbName
    tags: commonTags
  }
}

module musicDatabaseModule 'modules/sql-server-databases/musicDb.bicep' = if (featureFlags.enableSqlServer) {
  name: 'musicDatabaseDeployment'
  dependsOn: [
    sqlServerModule
  ]
  params: {
    location: location
    sqlServerName: sqlServer.serverName
    databaseName: sqlServer.databases.musicDbName
    tags: commonTags
  }
}

// Key Vault Module
module keyVaultModule 'modules/key-vaults/keyVault.bicep' = if (featureFlags.enableKeyVault) {
  name: 'keyVaultDeployment'
  params: {
    location: location
    keyVaultName: keyVault.name
    allowedSubnets: featureFlags.enableVNetIntegration ? [vnetModule.outputs.vnetIntegrationSubnetId] : []
    createPrivateEndpoint: featureFlags.enablePrivateEndpoints
    privateEndpointSubnetId: featureFlags.enablePrivateEndpoints ? vnetModule.outputs.privateEndpointSubnetId : ''
    privateDnsZoneId: featureFlags.enablePrivateEndpoints ? privateDnsZonesModule!.outputs.keyVaultPrivateDnsZoneId : ''
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
      featureFlags.enableFunctionApps ? [
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
module privateDnsZonesModule 'modules/private-dns-zones/privateDNSZones.bicep' = if (featureFlags.enablePrivateEndpoints) {
  name: 'privateDnsZonesDeployment'
  params: {
    enablePrivateEndpoints: featureFlags.enablePrivateEndpoints
    vnetId: vnetModule.outputs.vnetId
    vnetName: networking.vnetName
    customerSiteWebAppName: appService.webApps.customerSiteWebAppName
    adminSiteWebAppName: appService.webApps.adminSiteWebAppName
    videoApiWebAppName: appService.webApps.videoApiWebAppName
    musicApiWebAppName: appService.webApps.musicApiWebAppName
    applicationGatewayPublicIP: featureFlags.enableApplicationGateway ? applicationGatewayModule!.outputs.publicIPAddress : '0.0.0.0'
    tags: commonTags
  }
}

// App Configuration Module
module appConfigModule 'modules/app-configurations/myAppConfiguration.bicep' = if (featureFlags.enableAppConfiguration) {
  name: 'appConfigurationDeployment'
  params: {
    location: location
    appConfigName: appConfiguration.name
    createPrivateEndpoint: featureFlags.enablePrivateEndpoints
    privateEndpointSubnetId: featureFlags.enablePrivateEndpoints ? vnetModule.outputs.privateEndpointSubnetId : ''
    privateDnsZoneId: (featureFlags.enablePrivateEndpoints && featureFlags.enableAppConfiguration) ? privateDnsZonesModule!.outputs.appConfigPrivateDnsZoneId : ''
    // Consolidated Role Assignment Parameters
    roleAssignments: featureFlags.enableAppConfiguration ? concat(
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
      featureFlags.enableFunctionApps ? [
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
module myStorageAccountModule 'modules/storage-accounts/myStorageAccount.bicep' = if (featureFlags.enableBlobStorage) {
  name: 'blobStorageDeployment'
  params: {
    location: location
    storageAccountName: storage.accountName
    storageAccountType: storage.accountType
    containerNames: storage.blobContainerNames
    createPrivateEndpoint: featureFlags.enablePrivateEndpoints
    privateEndpointSubnetId: featureFlags.enablePrivateEndpoints ? vnetModule.outputs.privateEndpointSubnetId : ''
    privateDnsZoneIds: {
      blob: (featureFlags.enablePrivateEndpoints && featureFlags.enableBlobStorage) ? privateDnsZonesModule!.outputs.blobStoragePrivateDnsZoneId : ''
      file: (featureFlags.enablePrivateEndpoints && featureFlags.enableBlobStorage) ? privateDnsZonesModule!.outputs.fileStoragePrivateDnsZoneId : ''
      queue: (featureFlags.enablePrivateEndpoints && featureFlags.enableBlobStorage) ? privateDnsZonesModule!.outputs.queueStoragePrivateDnsZoneId : ''
      table: (featureFlags.enablePrivateEndpoints && featureFlags.enableBlobStorage) ? privateDnsZonesModule!.outputs.tableStoragePrivateDnsZoneId : ''
    }
    allowedSubnetIds: featureFlags.enableVNetIntegration ? [vnetModule.outputs.vnetIntegrationSubnetId] : []
    allowBlobPublicAccess: !featureFlags.enablePrivateEndpoints
    // Consolidated Role Assignment Parameters
    roleAssignments: featureFlags.enableBlobStorage ? concat(
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
      featureFlags.enableFunctionApps ? [
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
module cosmosDbAccountModule 'modules/cosmos-accounts/myCosmosAccount.bicep' = if (featureFlags.enableCosmosDb) {
  name: 'cosmosDbAccountDeployment'
  params: {
    location: location
    cosmosAccountName: cosmosDb.accountName
    consistencyLevel: cosmosDb.consistencyLevel
    enableAutomaticFailover: cosmosDb.enableAutomaticFailover
    createPrivateEndpoint: featureFlags.enablePrivateEndpoints
    privateEndpointSubnetId: featureFlags.enablePrivateEndpoints ? vnetModule.outputs.privateEndpointSubnetId : ''
    privateDnsZoneId: (featureFlags.enablePrivateEndpoints && featureFlags.enableCosmosDb) ? privateDnsZonesModule!.outputs.cosmosPrivateDnsZoneId : ''
    allowedSubnets: featureFlags.enableVNetIntegration ? [vnetModule.outputs.vnetIntegrationSubnetId] : []
    enablePublicNetworkAccess: !featureFlags.enablePrivateEndpoints
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
      featureFlags.enableFunctionApps ? [
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
      featureFlags.enableFunctionApps ? [
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
module cosmosAdminDatabaseModule 'modules/cosmos-databases/adminDb.bicep' = if (featureFlags.enableCosmosDb) {
  name: 'cosmosAdminDatabaseDeployment'
  params: {
    cosmosAccountName: cosmosDb.accountName
    cosmosAdminDbName: cosmosDb.databases.adminDbName
    tags: commonTags
  }
  dependsOn: [
    cosmosDbAccountModule
  ]
}

module cosmosCustomerDatabaseModule 'modules/cosmos-databases/customerDb.bicep' = if (featureFlags.enableCosmosDb) {
  name: 'cosmosCustomerDatabaseDeployment'
  params: {
    cosmosAccountName: cosmosDb.accountName
    cosmosCustomerDbName: cosmosDb.databases.customerDbName
    tags: commonTags
  }
  dependsOn: [
    cosmosDbAccountModule
  ]
}

module cosmosMusicDatabaseModule 'modules/cosmos-databases/musicDb.bicep' = if (featureFlags.enableCosmosDb) {
  name: 'cosmosMusicDatabaseDeployment'
  params: {
    cosmosAccountName: cosmosDb.accountName
    cosmosMusicDbName: cosmosDb.databases.musicDbName
    tags: commonTags
  }
  dependsOn: [
    cosmosDbAccountModule
  ]
}

module cosmosVideoDatabaseModule 'modules/cosmos-databases/videoDb.bicep' = if (featureFlags.enableCosmosDb) {
  name: 'cosmosVideoDatabaseDeployment'
  params: {
    cosmosAccountName: cosmosDb.accountName
    cosmosVideoDbName: cosmosDb.databases.videoDbName
    tags: commonTags
  }
  dependsOn: [
    cosmosDbAccountModule
  ]
}

// Service Bus Namespace Module
module serviceBusNamespaceModule 'modules/service-bus-namespaces/myServiceBusNamespace.bicep' = if (featureFlags.enableServiceBus) {
  name: 'serviceBusNamespaceDeployment'
  params: {
    location: location
    namespaceName: serviceBus.namespaceName
    sku: serviceBus.sku
    capacity: serviceBus.capacity
    zoneRedundant: serviceBus.sku == 'Premium' ? true : false
    createPrivateEndpoint: featureFlags.enablePrivateEndpoints
    privateEndpointSubnetId: featureFlags.enablePrivateEndpoints ? vnetModule.outputs.privateEndpointSubnetId : ''
    privateDnsZoneId: (featureFlags.enablePrivateEndpoints && featureFlags.enableServiceBus) ? privateDnsZonesModule!.outputs.serviceBusPrivateDnsZoneId : ''
    allowedSubnetIds: featureFlags.enableVNetIntegration ? [vnetModule.outputs.vnetIntegrationSubnetId] : []
    allowedIpRanges: []
    topicNames: serviceBus.topicNames
    queueNames: serviceBus.queueNames
    subscriptions: serviceBus.subscriptions
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
      featureFlags.enableFunctionApps ? [
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
module logAnalyticsWorkspaceModule 'modules/log-analytics-workspaces/logAnalyticsWorkspace.bicep' = if (featureFlags.enableApplicationInsights) {
  name: 'logAnalyticsWorkspaceDeployment'
  params: {
    location: location
    workspaceName: monitoring.applicationInsights.workspaceName
    retentionInDays: monitoring.applicationInsights.retentionInDays
    tags: commonTags
  }
}

// Centralized Application Insights Module - All Apps
module applicationInsightsModule 'modules/application-insights/applicationInsights.bicep' = if (featureFlags.enableApplicationInsights) {
  name: 'applicationInsightsDeployment'
  params: {
    location: location
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceModule!.outputs.workspaceId
    // App Insights Names
    customerAppInsightsName: '${appService.webApps.customerSiteWebAppName}-ai'
    adminAppInsightsName: '${appService.webApps.adminSiteWebAppName}-ai'
    videoAppInsightsName: '${appService.webApps.videoApiWebAppName}-ai'
    musicAppInsightsName: '${appService.webApps.musicApiWebAppName}-ai'
    tags: commonTags
  }
}

// App Service Plan Module
module appServicePlanModule 'modules/app-service-plans/myAppServicePlan.bicep' = {
  name: 'appServicePlanDeployment'
  params: {
    location: location
    appServicePlanName: appService.planName
    tags: commonTags
  }
}

// Individual Web App Modules
module customerPublicWebAppModule 'modules/app-services/customerPublicWebApp.bicep' = {
  name: 'customerPublicWebAppDeployment'
  params: {
    location: location
    webAppName: appService.webApps.customerPublicWebAppName
    appServicePlanId: appServicePlanModule.outputs.appServicePlanId
    enableVNetIntegration: featureFlags.enableVNetIntegration
    vnetIntegrationSubnetId: featureFlags.enableVNetIntegration ? vnetModule.outputs.vnetIntegrationSubnetId : ''
    tags: commonTags
  }
}

module customerSiteWebAppModule 'modules/app-services/customerSiteWebApp.bicep' = {
  name: 'customerSiteWebAppDeployment'
  params: {
    location: location
    webAppName: appService.webApps.customerSiteWebAppName
    appServicePlanId: appServicePlanModule.outputs.appServicePlanId
    createPrivateEndpoint: featureFlags.enablePrivateEndpoints
    privateEndpointSubnetId: featureFlags.enablePrivateEndpoints ? vnetModule.outputs.privateEndpointSubnetId : ''
    privateDnsZoneId: featureFlags.enablePrivateEndpoints ? privateDnsZonesModule!.outputs.appServicePrivateDnsZoneId : ''
    enableVNetIntegration: featureFlags.enableVNetIntegration
    vnetIntegrationSubnetId: featureFlags.enableVNetIntegration ? vnetModule.outputs.vnetIntegrationSubnetId : ''
    tags: commonTags
  }
}

module adminPublicWebAppModule 'modules/app-services/adminPublicWebApp.bicep' = {
  name: 'adminPublicWebAppDeployment'
  params: {
    location: location
    webAppName: appService.webApps.adminPublicWebAppName
    appServicePlanId: appServicePlanModule.outputs.appServicePlanId
    enableVNetIntegration: featureFlags.enableVNetIntegration
    vnetIntegrationSubnetId: featureFlags.enableVNetIntegration ? vnetModule.outputs.vnetIntegrationSubnetId : ''
    tags: commonTags
  }
}

module adminSiteWebAppModule 'modules/app-services/adminSiteWebApp.bicep' = {
  name: 'adminSiteWebAppDeployment'
  params: {
    location: location
    webAppName: appService.webApps.adminSiteWebAppName
    appServicePlanId: appServicePlanModule.outputs.appServicePlanId
    createPrivateEndpoint: featureFlags.enablePrivateEndpoints
    privateEndpointSubnetId: featureFlags.enablePrivateEndpoints ? vnetModule.outputs.privateEndpointSubnetId : ''
    privateDnsZoneId: featureFlags.enablePrivateEndpoints ? privateDnsZonesModule!.outputs.appServicePrivateDnsZoneId : ''
    enableVNetIntegration: featureFlags.enableVNetIntegration
    vnetIntegrationSubnetId: featureFlags.enableVNetIntegration ? vnetModule.outputs.vnetIntegrationSubnetId : ''
    tags: commonTags
  }
}

module videoApiWebAppModule 'modules/app-services/videoApiWebApp.bicep' = {
  name: 'videoApiWebAppDeployment'
  params: {
    location: location
    webAppName: appService.webApps.videoApiWebAppName
    appServicePlanId: appServicePlanModule.outputs.appServicePlanId
    createPrivateEndpoint: featureFlags.enablePrivateEndpoints
    privateEndpointSubnetId: featureFlags.enablePrivateEndpoints ? vnetModule.outputs.privateEndpointSubnetId : ''
    privateDnsZoneId: featureFlags.enablePrivateEndpoints ? privateDnsZonesModule!.outputs.appServicePrivateDnsZoneId : ''
    enableVNetIntegration: featureFlags.enableVNetIntegration
    vnetIntegrationSubnetId: featureFlags.enableVNetIntegration ? vnetModule.outputs.vnetIntegrationSubnetId : ''
    tags: commonTags
  }
}

module musicApiWebAppModule 'modules/app-services/musicApiWebApp.bicep' = {
  name: 'musicApiWebAppDeployment'
  params: {
    location: location
    webAppName: appService.webApps.musicApiWebAppName
    appServicePlanId: appServicePlanModule.outputs.appServicePlanId
    createPrivateEndpoint: featureFlags.enablePrivateEndpoints
    privateEndpointSubnetId: featureFlags.enablePrivateEndpoints ? vnetModule.outputs.privateEndpointSubnetId : ''
    privateDnsZoneId: featureFlags.enablePrivateEndpoints ? privateDnsZonesModule!.outputs.appServicePrivateDnsZoneId : ''
    enableVNetIntegration: featureFlags.enableVNetIntegration
    vnetIntegrationSubnetId: featureFlags.enableVNetIntegration ? vnetModule.outputs.vnetIntegrationSubnetId : ''
    tags: commonTags
  }
}

// Individual Function App Modules
module adminFunctionAppModule 'modules/azure-functions/adminFunctionApp.bicep' = if (featureFlags.enableFunctionApps) {
  name: 'adminFunctionAppDeployment'
  params: {
    location: location
    functionAppName: azureFunctions.adminFunctionAppName
    appServicePlanId: appServicePlanModule.outputs.appServicePlanId
    storageAccountName: azureFunctions.storageAccountName
    createPrivateEndpoint: featureFlags.enablePrivateEndpoints
    privateEndpointSubnetId: featureFlags.enablePrivateEndpoints ? vnetModule.outputs.privateEndpointSubnetId : ''
    privateDnsZoneId: featureFlags.enablePrivateEndpoints ? privateDnsZonesModule!.outputs.appServicePrivateDnsZoneId : ''
    enableVNetIntegration: featureFlags.enableVNetIntegration
    vnetIntegrationSubnetId: featureFlags.enableVNetIntegration ? vnetModule.outputs.vnetIntegrationSubnetId : ''
    applicationInsightsConnectionString: featureFlags.enableApplicationInsights ? applicationInsightsModule!.outputs.adminAppInsights.connectionString : ''
    tags: commonTags
  }
}

module customerFunctionAppModule 'modules/azure-functions/customerFunctionApp.bicep' = if (featureFlags.enableFunctionApps) {
  name: 'customerFunctionAppDeployment'
  params: {
    location: location
    functionAppName: azureFunctions.customerFunctionAppName
    appServicePlanId: appServicePlanModule.outputs.appServicePlanId
    storageAccountName: azureFunctions.storageAccountName
    createPrivateEndpoint: featureFlags.enablePrivateEndpoints
    privateEndpointSubnetId: featureFlags.enablePrivateEndpoints ? vnetModule.outputs.privateEndpointSubnetId : ''
    privateDnsZoneId: featureFlags.enablePrivateEndpoints ? privateDnsZonesModule!.outputs.appServicePrivateDnsZoneId : ''
    enableVNetIntegration: featureFlags.enableVNetIntegration
    vnetIntegrationSubnetId: featureFlags.enableVNetIntegration ? vnetModule.outputs.vnetIntegrationSubnetId : ''
    applicationInsightsConnectionString: featureFlags.enableApplicationInsights ? applicationInsightsModule!.outputs.customerAppInsights.connectionString : ''
    tags: commonTags
  }
}

module musicFunctionAppModule 'modules/azure-functions/musicFunctionApp.bicep' = if (featureFlags.enableFunctionApps) {
  name: 'musicFunctionAppDeployment'
  params: {
    location: location
    functionAppName: azureFunctions.musicFunctionAppName
    appServicePlanId: appServicePlanModule.outputs.appServicePlanId
    storageAccountName: azureFunctions.storageAccountName
    createPrivateEndpoint: featureFlags.enablePrivateEndpoints
    privateEndpointSubnetId: featureFlags.enablePrivateEndpoints ? vnetModule.outputs.privateEndpointSubnetId : ''
    privateDnsZoneId: featureFlags.enablePrivateEndpoints ? privateDnsZonesModule!.outputs.appServicePrivateDnsZoneId : ''
    enableVNetIntegration: featureFlags.enableVNetIntegration
    vnetIntegrationSubnetId: featureFlags.enableVNetIntegration ? vnetModule.outputs.vnetIntegrationSubnetId : ''
    applicationInsightsConnectionString: featureFlags.enableApplicationInsights ? applicationInsightsModule!.outputs.musicAppInsights.connectionString : ''
    tags: commonTags
  }
}

module videoFunctionAppModule 'modules/azure-functions/videoFunctionApp.bicep' = if (featureFlags.enableFunctionApps) {
  name: 'videoFunctionAppDeployment'
  params: {
    location: location
    functionAppName: azureFunctions.videoFunctionAppName
    appServicePlanId: appServicePlanModule.outputs.appServicePlanId
    storageAccountName: azureFunctions.storageAccountName
    createPrivateEndpoint: featureFlags.enablePrivateEndpoints
    privateEndpointSubnetId: featureFlags.enablePrivateEndpoints ? vnetModule.outputs.privateEndpointSubnetId : ''
    privateDnsZoneId: featureFlags.enablePrivateEndpoints ? privateDnsZonesModule!.outputs.appServicePrivateDnsZoneId : ''
    enableVNetIntegration: featureFlags.enableVNetIntegration
    vnetIntegrationSubnetId: featureFlags.enableVNetIntegration ? vnetModule.outputs.vnetIntegrationSubnetId : ''
    applicationInsightsConnectionString: featureFlags.enableApplicationInsights ? applicationInsightsModule!.outputs.videoAppInsights.connectionString : ''
    tags: commonTags
  }
}

// Function Apps Storage Account Module (deployed after App Service Plan - for function runtime storage only)
module functionAppsStorageModule 'modules/storage-accounts/functionAppsStorageAccount.bicep' = if (featureFlags.enableFunctionApps) {
  name: 'functionAppsStorageDeployment'
  params: {
    location: location
    storageAccountName: azureFunctions.storageAccountName
    storageAccountType: storage.accountType
    accessTier: 'Hot'
    minimumTlsVersion: 'TLS1_2'
    createPrivateEndpoint: featureFlags.enablePrivateEndpoints
    privateEndpointSubnetId: featureFlags.enablePrivateEndpoints ? vnetModule.outputs.privateEndpointSubnetId : ''
    privateDnsZoneIds: {
      blob: (featureFlags.enablePrivateEndpoints && featureFlags.enableFunctionApps) ? privateDnsZonesModule!.outputs.blobStoragePrivateDnsZoneId : ''
      file: (featureFlags.enablePrivateEndpoints && featureFlags.enableFunctionApps) ? privateDnsZonesModule!.outputs.fileStoragePrivateDnsZoneId : ''
      queue: (featureFlags.enablePrivateEndpoints && featureFlags.enableFunctionApps) ? privateDnsZonesModule!.outputs.queueStoragePrivateDnsZoneId : ''
      table: (featureFlags.enablePrivateEndpoints && featureFlags.enableFunctionApps) ? privateDnsZonesModule!.outputs.tableStoragePrivateDnsZoneId : ''
    }
    allowedIpRanges: []
    bypassAzureServices: true
    allowedSubnetIds: featureFlags.enableVNetIntegration ? [vnetModule.outputs.vnetIntegrationSubnetId] : []
    allowBlobPublicAccess: !featureFlags.enablePrivateEndpoints
    // No role assignments needed - function apps use connection strings for runtime storage
    roleAssignments: []
    tags: union(commonTags, {
      Purpose: 'FunctionAppsRuntimeStorage'
    })
  }
}

// Application Gateway Module
module applicationGatewayModule 'modules/application-gateways/my-gateway/applicationGateway.bicep' = if (featureFlags.enableApplicationGateway) {
  name: 'applicationGatewayDeployment'
  params: {
    location: location
    vnetName: networking.vnetName
    appGatewaySubnetId: vnetModule.outputs.appGatewaySubnetId
    customerPublicWebAppName: appService.webApps.customerPublicWebAppName
    customerSiteWebAppName: appService.webApps.customerSiteWebAppName
    adminPublicWebAppName: appService.webApps.adminPublicWebAppName
    adminSiteWebAppName: appService.webApps.adminSiteWebAppName
    // WAF Configuration
    wafConfig: {
      enabled: applicationGateway.waf.enabled
      firewallMode: applicationGateway.waf.firewallMode
      ruleSetType: 'OWASP'
      ruleSetVersion: applicationGateway.waf.ruleSetVersion
      disabledRuleGroups: []
      requestBodyCheck: applicationGateway.waf.requestBodyCheck
      maxRequestBodySizeInKb: applicationGateway.waf.maxRequestBodySizeInKb
      fileUploadLimitInMb: applicationGateway.waf.fileUploadLimitInMb
    }
    tags: commonTags
  }
}

// API Management Module
module apiManagementModule 'modules/api-managements/my-api-management/myApiManagement.bicep' = if (featureFlags.enableApiManagement) {
  name: 'apiManagementDeployment'
  params: {
    location: location
    apiManagementName: apiManagement.serviceName
    publisherEmail: apiManagement.publisherEmail
    publisherName: apiManagement.publisherName
    vnetId: vnetModule.outputs.vnetId
    apiManagementSubnetName: 'APIManagementSubnet'
    videoApiUrl: 'https://${appService.webApps.videoApiWebAppName}.azurewebsites.net'
    musicApiUrl: 'https://${appService.webApps.musicApiWebAppName}.azurewebsites.net'
    apiManagementSku: apiManagement.sku
    apiManagementCapacity: apiManagement.capacity
    tags: commonTags
  }
}

// Test VM Module
module testVMModule 'modules/virtual-machines/testVM.bicep' = if (featureFlags.enableTestVM) {
  name: 'testVMDeployment'
  params: {
    location: location
    vmName: 'test-vm'
    vmSize: 'Standard_B1s'
    adminUsername: virtualMachine.adminUsername
    adminPassword: virtualMachine.adminPassword
    subnetId: vnetModule.outputs.testVMSubnetId
    includePublicIP: true
    tags: commonTags
  }
}

// Output SQL Server information for connection string creation
output sqlServerInfo object = featureFlags.enableSqlServer ? {
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
output applicationGatewayPublicIP string = featureFlags.enableApplicationGateway ? applicationGatewayModule!.outputs.publicIPAddress : ''

// Output Application Gateway WAF Information
output applicationGatewayWAF object = featureFlags.enableApplicationGateway ? {
  wafEnabled: applicationGatewayModule!.outputs.wafEnabled
  wafPolicyId: applicationGatewayModule!.outputs.wafPolicyId
  wafPolicyName: applicationGatewayModule!.outputs.wafPolicyName
  wafMode: applicationGateway.waf.firewallMode
  ruleSetVersion: applicationGateway.waf.ruleSetVersion
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
    name: appService.webApps.customerPublicWebAppName
    url: 'http://${appService.webApps.customerPublicWebAppName}.azurewebsites.net'
  }
  {
    name: appService.webApps.customerSiteWebAppName
    url: 'http://${appService.webApps.customerSiteWebAppName}.azurewebsites.net'
  }
  {
    name: appService.webApps.adminPublicWebAppName
    url: 'http://${appService.webApps.adminPublicWebAppName}.azurewebsites.net'
  }
  {
    name: appService.webApps.adminSiteWebAppName
    url: 'http://${appService.webApps.adminSiteWebAppName}.azurewebsites.net'
  }
  {
    name: appService.webApps.videoApiWebAppName
    url: 'http://${appService.webApps.videoApiWebAppName}.azurewebsites.net'
  }
  {
    name: appService.webApps.musicApiWebAppName
    url: 'http://${appService.webApps.musicApiWebAppName}.azurewebsites.net'
  }
]

// Output Test VM information for access
output testVMInfo object = featureFlags.enableTestVM ? {
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
output apiManagementGatewayUrl string = featureFlags.enableApiManagement ? apiManagementModule!.outputs.apiManagementGatewayUrl : ''

// Output API Management Developer Portal URL
output apiManagementDeveloperPortalUrl string = featureFlags.enableApiManagement ? apiManagementModule!.outputs.apiManagementDeveloperPortalUrl : ''

// Output API Management Management URL
output apiManagementManagementUrl string = featureFlags.enableApiManagement ? apiManagementModule!.outputs.apiManagementManagementUrl : ''

// Output API Endpoints
output apiEndpoints array = featureFlags.enableApiManagement ? [
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
output internalDnsNames array = featureFlags.enablePrivateEndpoints ? privateDnsZonesModule!.outputs.internalDnsNames : []

// Key Vault Information
output keyVaultInfo object = featureFlags.enableKeyVault ? {
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
output appConfigInfo object = featureFlags.enableAppConfiguration ? {
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
output storageAccountInfo object = featureFlags.enableStorageAccount ? {
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
output functionAppsStorageInfo object = featureFlags.enableFunctionApps ? {
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
output cosmosDbInfo object = featureFlags.enableCosmosDb ? {
  cosmosAccountId: cosmosDbAccountModule!.outputs.cosmosAccountId
  cosmosAccountName: cosmosDbAccountModule!.outputs.cosmosAccountName
  cosmosAccountEndpoint: cosmosDbAccountModule!.outputs.cosmosAccountEndpoint
  databaseNames: [cosmosDb.databases.adminDbName, cosmosDb.databases.customerDbName, cosmosDb.databases.musicDbName, cosmosDb.databases.videoDbName]
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
output functionAppsInfo object = featureFlags.enableFunctionApps ? {
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
output serviceBusInfo object = featureFlags.enableServiceBus ? {
  namespaceName: serviceBusNamespaceModule!.outputs.serviceBusNamespaceName
  namespaceId: serviceBusNamespaceModule!.outputs.serviceBusNamespaceId
  hostName: serviceBusNamespaceModule!.outputs.serviceBusNamespaceHostName
  hasPrivateEndpoint: serviceBusNamespaceModule!.outputs.hasPrivateEndpoint
  privateEndpointId: serviceBusNamespaceModule!.outputs.privateEndpointId
  privateEndpointName: serviceBusNamespaceModule!.outputs.privateEndpointName
  topicNames: serviceBus.topicNames
  queueNames: serviceBus.queueNames
  subscriptionNames: serviceBus.subscriptions
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
output applicationInsightsInfo object = featureFlags.enableApplicationInsights ? {
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
