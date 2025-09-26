// Nested parameter objects for better organization
param general object = {
  location: 'southeastasia'
  environment: 'dev'
}

param featureFlags object = {
  enablePrivateEndpoints: false
  enableVNetIntegration: false
  enableTestVM: false
  enableSqlServer: false
  enableKeyVault: false
  enableAppConfiguration: false
  enableStorageAccount: false
  enableCosmosDb: false
  enableFunctionApps: false
  enableServiceBus: false
  enableApplicationInsights: false
}

param networking object = {
  vnetName: 'PracticalMultipleResourceGroups-vnet'
  resourceGroup: 'practical-pe-networking-rg'
  privateDnsZones: {
    appConfig: 'privatelink.azconfig.io'
    blobStorage: 'privatelink.blob.core.windows.net'
    cosmos: 'privatelink.documents.azure.com'
    serviceBus: 'privatelink.servicebus.windows.net'
    appService: 'privatelink.azurewebsites.net'
    keyVault: 'privatelink.vaultcore.azure.net'
  }
}

param sql object = {
  serverName: 'PracticalMultipleResourceGroups'
  adminUsername: 'PracticalMultipleResourceGroups'
  databases: {
    customerDb: 'PracticalMultipleResourceGroups-CUSTOMER-DB'
    adminDb: 'PracticalMultipleResourceGroups-ADMIN-DB'
    videoDb: 'PracticalMultipleResourceGroups-VIDEO-DB'
    musicDb: 'PracticalMultipleResourceGroups-MUSIC-DB'
  }
}

param webApps object = {
  appServicePlanName: 'PracticalMultipleResourceGroups'
  apps: {
    customerPublic: 'PracticalMultipleResourceGroups-CUSTOMER-PUBLIC'
    customerSite: 'PracticalMultipleResourceGroups-CUSTOMER-SITE'
    adminPublic: 'PracticalMultipleResourceGroups-ADMIN-PUBLIC'
    adminSite: 'PracticalMultipleResourceGroups-ADMIN-SITE'
    videoApi: 'PracticalMultipleResourceGroups-VIDEO-API'
    musicApi: 'PracticalMultipleResourceGroups-MUSIC-API'
  }
}

param storage object = {
  mainAccount: {
    name: 'practicalmrgblob'
    type: 'Standard_LRS'
    containers: [
      'documents'
      'images'
      'backups'
      'logs'
    ]
  }
  functionApps: {
    name: 'practicalmrgfuncappsst'
    type: 'Standard_LRS'
  }
}

param cosmos object = {
  accountName: 'practicalmrg-cosmos-${uniqueString(resourceGroup().id)}'
  consistencyLevel: 'Session'
  enableAutomaticFailover: true
  databases: {
    adminDb: 'PracticalMultipleResourceGroups-ADMIN-COSMOS-DB'
    customerDb: 'PracticalMultipleResourceGroups-CUSTOMER-COSMOS-DB'
    musicDb: 'PracticalMultipleResourceGroups-MUSIC-COSMOS-DB'
    videoDb: 'PracticalMultipleResourceGroups-VIDEO-COSMOS-DB'
  }
}

param functions object = {
  apps: {
    admin: 'PracticalMultipleResourceGroups-ADMIN-FUNC'
    customer: 'PracticalMultipleResourceGroups-CUSTOMER-FUNC'
    music: 'PracticalMultipleResourceGroups-MUSIC-FUNC'
    video: 'PracticalMultipleResourceGroups-VIDEO-FUNC'
  }
}

param serviceBus object = {
  namespaceName: 'PracticalMultipleResourceGroups-sb-${uniqueString(resourceGroup().id)}'
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

param applicationInsights object = {
  workspaceName: 'PracticalMultipleResourceGroups-law'
  retentionInDays: 30
}

param testVm object = {
  adminUsername: 'testadmin'
}

param keyVault object = {
  name: 'practicalmrgkv'
}

param appConfiguration object = {
  name: 'PracticalMultipleResourceGroups-config'
}

// Secure parameters
@secure()
param adminPassword string = ''
@secure()
param vmAdminPassword string = ''

// Common tags variable based on environment
var commonTags = {
  Environment: general.environment
  Project: 'PracticalMultipleResourceGroups'
}

// Private DNS Zones Module
module privateDnsZonesModule 'modules/private-dns-zones/privateDNSZones.bicep' = {
  name: 'privateDnsZonesDeployment'
  params: {
    privateDnsZonesResourceGroup: networking.resourceGroup
    appConfigPrivateDnsZoneName: networking.privateDnsZones.appConfig
    blobStoragePrivateDnsZoneName: networking.privateDnsZones.blobStorage
    cosmosPrivateDnsZoneName: networking.privateDnsZones.cosmos
    serviceBusPrivateDnsZoneName: networking.privateDnsZones.serviceBus
    appServicePrivateDnsZoneName: networking.privateDnsZones.appService
    keyVaultPrivateDnsZoneName: networking.privateDnsZones.keyVault
  }
}

// Reference existing resources from networking-layer
@description('Resource group of the networking-layer deployment')
param networkingLayerResourceGroup string = networking.resourceGroup

// Virtual Network Module (reference existing from networking-layer)
module vnetModule 'modules/virtual-networks/virtualNetwork.bicep' = {
  name: 'virtualNetworkDeployment'
  params: {
    vnetResourceGroup: networkingLayerResourceGroup
    vnetName: networking.vnetName
  }
}

// SQL Server Module
module sqlServerModule 'modules/sql-servers/mySqlServer.bicep' = if (featureFlags.enableSqlServer) {
  name: 'sqlServerDeployment'
  params: {
    location: general.location
    sqlServerName: sql.serverName
    adminUsername: sql.adminUsername
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
    location: general.location
    sqlServerName: sql.serverName
    databaseName: sql.databases.customerDb
    tags: commonTags
  }
}

module adminDatabaseModule 'modules/sql-server-databases/adminDb.bicep' = if (featureFlags.enableSqlServer) {
  name: 'adminDatabaseDeployment'
  dependsOn: [
    sqlServerModule
  ]
  params: {
    location: general.location
    sqlServerName: sql.serverName
    databaseName: sql.databases.adminDb
    tags: commonTags
  }
}

module videoDatabaseModule 'modules/sql-server-databases/videoDb.bicep' = if (featureFlags.enableSqlServer) {
  name: 'videoDatabaseDeployment'
  dependsOn: [
    sqlServerModule
  ]
  params: {
    location: general.location
    sqlServerName: sql.serverName
    databaseName: sql.databases.videoDb
    tags: commonTags
  }
}

module musicDatabaseModule 'modules/sql-server-databases/musicDb.bicep' = if (featureFlags.enableSqlServer) {
  name: 'musicDatabaseDeployment'
  dependsOn: [
    sqlServerModule
  ]
  params: {
    location: general.location
    sqlServerName: sql.serverName
    databaseName: sql.databases.musicDb
    tags: commonTags
  }
}

// Key Vault Module
module keyVaultModule 'modules/key-vaults/keyVault.bicep' = if (featureFlags.enableKeyVault) {
  name: 'keyVaultDeployment'
  params: {
    location: general.location
    keyVaultName: keyVault.name
    allowedSubnets: featureFlags.enableVNetIntegration ? [vnetModule.outputs.vnetIntegrationSubnetId] : []
    createPrivateEndpoint: featureFlags.enablePrivateEndpoints
    privateEndpointSubnetId: featureFlags.enablePrivateEndpoints ? vnetModule.outputs.privateEndpointSubnetId : ''
    privateDnsZoneId: (featureFlags.enablePrivateEndpoints && featureFlags.enableKeyVault) ? privateDnsZonesModule.outputs.keyVaultPrivateDnsZoneId : ''
    // Consolidated Role Assignment Parameters for Key Vault access
    roleAssignments: featureFlags.enableKeyVault ? concat(
      // Web App Role Assignments (Key Vault Secrets User)
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
      ],
      // Function App Role Assignments (Key Vault Secrets User) - only when enabled
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
    ) : []
    tags: commonTags
  }
}

// App Configuration Module
module appConfigModule 'modules/app-configurations/myAppConfiguration.bicep' = if (featureFlags.enableAppConfiguration) {
  name: 'appConfigurationDeployment'
  params: {
    location: general.location
    appConfigName: appConfiguration.name
    createPrivateEndpoint: featureFlags.enablePrivateEndpoints
    privateEndpointSubnetId: featureFlags.enablePrivateEndpoints ? vnetModule.outputs.privateEndpointSubnetId : ''
    privateDnsZoneId: (featureFlags.enablePrivateEndpoints && featureFlags.enableAppConfiguration) ? privateDnsZonesModule.outputs.appConfigPrivateDnsZoneId : ''
    // Consolidated Role Assignment Parameters
    roleAssignments: featureFlags.enableAppConfiguration ? concat(
      // Web Apps - App Configuration Data Reader role
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
      // Function Apps - App Configuration Data Reader role (only when enabled)
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

// My Storage Account Module
module myStorageAccountModule 'modules/storage-accounts/myStorageAccount.bicep' = if (featureFlags.enableStorageAccount) {
  name: 'blobStorageDeployment'
  params: {
    location: general.location
    storageAccountName: storage.mainAccount.name
    storageAccountType: storage.mainAccount.type
    containerNames: storage.mainAccount.containers
    createPrivateEndpoint: featureFlags.enablePrivateEndpoints
    privateEndpointSubnetId: featureFlags.enablePrivateEndpoints ? vnetModule.outputs.privateEndpointSubnetId : ''
    privateDnsZoneIds: {
      blob: (featureFlags.enablePrivateEndpoints && featureFlags.enableStorageAccount) ? privateDnsZonesModule.outputs.blobStoragePrivateDnsZoneId : ''
      file: (featureFlags.enablePrivateEndpoints && featureFlags.enableStorageAccount) ? privateDnsZonesModule.outputs.fileStoragePrivateDnsZoneId : ''
      queue: (featureFlags.enablePrivateEndpoints && featureFlags.enableStorageAccount) ? privateDnsZonesModule.outputs.queueStoragePrivateDnsZoneId : ''
      table: (featureFlags.enablePrivateEndpoints && featureFlags.enableStorageAccount) ? privateDnsZonesModule.outputs.tableStoragePrivateDnsZoneId : ''
    }
    allowedSubnets: featureFlags.enableVNetIntegration ? [vnetModule.outputs.vnetIntegrationSubnetId] : []
    allowBlobPublicAccess: !featureFlags.enablePrivateEndpoints
    // Consolidated Role Assignment Parameters
    roleAssignments: featureFlags.enableStorageAccount ? concat(
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
    location: general.location
    cosmosAccountName: cosmos.accountName
    consistencyLevel: cosmos.consistencyLevel
    enableAutomaticFailover: cosmos.enableAutomaticFailover
    createPrivateEndpoint: featureFlags.enablePrivateEndpoints
    privateEndpointSubnetId: featureFlags.enablePrivateEndpoints ? vnetModule.outputs.privateEndpointSubnetId : ''
    privateDnsZoneId: (featureFlags.enablePrivateEndpoints && featureFlags.enableCosmosDb) ? privateDnsZonesModule.outputs.cosmosPrivateDnsZoneId : ''
    allowedSubnets: featureFlags.enableVNetIntegration ? [vnetModule.outputs.vnetIntegrationSubnetId] : []
    enablePublicNetworkAccess: !featureFlags.enablePrivateEndpoints
    tags: commonTags
    // Consolidated Role Assignment Parameters
    roleAssignments: featureFlags.enableCosmosDb ? concat(
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
    ) : []
    sqlRoleAssignments: featureFlags.enableCosmosDb ? concat(
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
    ) : []
  }
}

// Individual Cosmos Database Modules
module cosmosAdminDatabaseModule 'modules/cosmos-databases/adminDb.bicep' = if (featureFlags.enableCosmosDb) {
  name: 'cosmosAdminDatabaseDeployment'
  params: {
    cosmosAccountName: cosmos.accountName
    cosmosAdminDbName: cosmos.databases.adminDb
    tags: commonTags
  }
  dependsOn: [
    cosmosDbAccountModule
  ]
}

module cosmosCustomerDatabaseModule 'modules/cosmos-databases/customerDb.bicep' = if (featureFlags.enableCosmosDb) {
  name: 'cosmosCustomerDatabaseDeployment'
  params: {
    cosmosAccountName: cosmos.accountName
    cosmosCustomerDbName: cosmos.databases.customerDb
    tags: commonTags
  }
  dependsOn: [
    cosmosDbAccountModule
  ]
}

module cosmosMusicDatabaseModule 'modules/cosmos-databases/musicDb.bicep' = if (featureFlags.enableCosmosDb) {
  name: 'cosmosMusicDatabaseDeployment'
  params: {
    cosmosAccountName: cosmos.accountName
    cosmosMusicDbName: cosmos.databases.musicDb
    tags: commonTags
  }
  dependsOn: [
    cosmosDbAccountModule
  ]
}

module cosmosVideoDatabaseModule 'modules/cosmos-databases/videoDb.bicep' = if (featureFlags.enableCosmosDb) {
  name: 'cosmosVideoDatabaseDeployment'
  params: {
    cosmosAccountName: cosmos.accountName
    cosmosVideoDbName: cosmos.databases.videoDb
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
    location: general.location
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
    location: general.location
    workspaceName: applicationInsights.workspaceName
    retentionInDays: applicationInsights.retentionInDays
    tags: commonTags
  }
}

// Centralized Application Insights Module - All Apps
module applicationInsightsModule 'modules/application-insights/applicationInsights.bicep' = if (featureFlags.enableApplicationInsights) {
  name: 'applicationInsightsDeployment'
  params: {
    location: general.location
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceModule!.outputs.workspaceId
    // App Insights Names
    customerAppInsightsName: '${webApps.apps.customerSite}-ai'
    adminAppInsightsName: '${webApps.apps.adminSite}-ai'
    videoAppInsightsName: '${webApps.apps.videoApi}-ai'
    musicAppInsightsName: '${webApps.apps.musicApi}-ai'
    tags: commonTags
  }
}

// App Service Plan Module
module appServicePlanModule 'modules/app-service-plans/myAppServicePlan.bicep' = {
  name: 'appServicePlanDeployment'
  params: {
    location: general.location
    appServicePlanName: webApps.appServicePlanName
    tags: commonTags
  }
}

// Individual Web App Modules
module customerPublicWebAppModule 'modules/app-services/customerPublicWebApp.bicep' = {
  name: 'customerPublicWebAppDeployment'
  params: {
    location: general.location
    webAppName: webApps.apps.customerPublic
    appServicePlanId: appServicePlanModule.outputs.appServicePlanId
    enableVNetIntegration: featureFlags.enableVNetIntegration
    vnetIntegrationSubnetId: featureFlags.enableVNetIntegration ? vnetModule.outputs.vnetIntegrationSubnetId : ''
    tags: commonTags
  }
}

module customerSiteWebAppModule 'modules/app-services/customerSiteWebApp.bicep' = {
  name: 'customerSiteWebAppDeployment'
  params: {
    location: general.location
    webAppName: webApps.apps.customerSite
    appServicePlanId: appServicePlanModule.outputs.appServicePlanId
    createPrivateEndpoint: featureFlags.enablePrivateEndpoints
    privateEndpointSubnetId: featureFlags.enablePrivateEndpoints ? vnetModule.outputs.privateEndpointSubnetId : ''
    privateDnsZoneId: featureFlags.enablePrivateEndpoints ? privateDnsZonesModule.outputs.appServicePrivateDnsZoneId : ''
    enableVNetIntegration: featureFlags.enableVNetIntegration
    vnetIntegrationSubnetId: featureFlags.enableVNetIntegration ? vnetModule.outputs.vnetIntegrationSubnetId : ''
    tags: commonTags
  }
}

module adminPublicWebAppModule 'modules/app-services/adminPublicWebApp.bicep' = {
  name: 'adminPublicWebAppDeployment'
  params: {
    location: general.location
    webAppName: webApps.apps.adminPublic
    appServicePlanId: appServicePlanModule.outputs.appServicePlanId
    enableVNetIntegration: featureFlags.enableVNetIntegration
    vnetIntegrationSubnetId: featureFlags.enableVNetIntegration ? vnetModule.outputs.vnetIntegrationSubnetId : ''
    tags: commonTags
  }
}

module adminSiteWebAppModule 'modules/app-services/adminSiteWebApp.bicep' = {
  name: 'adminSiteWebAppDeployment'
  params: {
    location: general.location
    webAppName: webApps.apps.adminSite
    appServicePlanId: appServicePlanModule.outputs.appServicePlanId
    createPrivateEndpoint: featureFlags.enablePrivateEndpoints
    privateEndpointSubnetId: featureFlags.enablePrivateEndpoints ? vnetModule.outputs.privateEndpointSubnetId : ''
    privateDnsZoneId: featureFlags.enablePrivateEndpoints ? privateDnsZonesModule.outputs.appServicePrivateDnsZoneId : ''
    enableVNetIntegration: featureFlags.enableVNetIntegration
    vnetIntegrationSubnetId: featureFlags.enableVNetIntegration ? vnetModule.outputs.vnetIntegrationSubnetId : ''
    tags: commonTags
  }
}

module videoApiWebAppModule 'modules/app-services/videoApiWebApp.bicep' = {
  name: 'videoApiWebAppDeployment'
  params: {
    location: general.location
    webAppName: webApps.apps.videoApi
    appServicePlanId: appServicePlanModule.outputs.appServicePlanId
    createPrivateEndpoint: featureFlags.enablePrivateEndpoints
    privateEndpointSubnetId: featureFlags.enablePrivateEndpoints ? vnetModule.outputs.privateEndpointSubnetId : ''
    privateDnsZoneId: featureFlags.enablePrivateEndpoints ? privateDnsZonesModule.outputs.appServicePrivateDnsZoneId : ''
    enableVNetIntegration: featureFlags.enableVNetIntegration
    vnetIntegrationSubnetId: featureFlags.enableVNetIntegration ? vnetModule.outputs.vnetIntegrationSubnetId : ''
    tags: commonTags
  }
}

module musicApiWebAppModule 'modules/app-services/musicApiWebApp.bicep' = {
  name: 'musicApiWebAppDeployment'
  params: {
    location: general.location
    webAppName: webApps.apps.musicApi
    appServicePlanId: appServicePlanModule.outputs.appServicePlanId
    createPrivateEndpoint: featureFlags.enablePrivateEndpoints
    privateEndpointSubnetId: featureFlags.enablePrivateEndpoints ? vnetModule.outputs.privateEndpointSubnetId : ''
    privateDnsZoneId: featureFlags.enablePrivateEndpoints ? privateDnsZonesModule.outputs.appServicePrivateDnsZoneId : ''
    enableVNetIntegration: featureFlags.enableVNetIntegration
    vnetIntegrationSubnetId: featureFlags.enableVNetIntegration ? vnetModule.outputs.vnetIntegrationSubnetId : ''
    tags: commonTags
  }
}

// Individual Function App Modules
module adminFunctionAppModule 'modules/azure-functions/adminFunctionApp.bicep' = if (featureFlags.enableFunctionApps) {
  name: 'adminFunctionAppDeployment'
  params: {
    location: general.location
    functionAppName: functions.apps.admin
    appServicePlanId: appServicePlanModule.outputs.appServicePlanId
    storageAccountName: storage.functionApps.name
    createPrivateEndpoint: featureFlags.enablePrivateEndpoints
    privateEndpointSubnetId: featureFlags.enablePrivateEndpoints ? vnetModule.outputs.privateEndpointSubnetId : ''
    privateDnsZoneId: featureFlags.enablePrivateEndpoints ? privateDnsZonesModule.outputs.appServicePrivateDnsZoneId : ''
    enableVNetIntegration: featureFlags.enableVNetIntegration
    vnetIntegrationSubnetId: featureFlags.enableVNetIntegration ? vnetModule.outputs.vnetIntegrationSubnetId : ''
    applicationInsightsConnectionString: featureFlags.enableApplicationInsights ? applicationInsightsModule!.outputs.adminAppInsights.connectionString : ''
    tags: commonTags
  }
}

module customerFunctionAppModule 'modules/azure-functions/customerFunctionApp.bicep' = if (featureFlags.enableFunctionApps) {
  name: 'customerFunctionAppDeployment'
  params: {
    location: general.location
    functionAppName: functions.apps.customer
    appServicePlanId: appServicePlanModule.outputs.appServicePlanId
    storageAccountName: storage.functionApps.name
    createPrivateEndpoint: featureFlags.enablePrivateEndpoints
    privateEndpointSubnetId: featureFlags.enablePrivateEndpoints ? vnetModule.outputs.privateEndpointSubnetId : ''
    privateDnsZoneId: featureFlags.enablePrivateEndpoints ? privateDnsZonesModule.outputs.appServicePrivateDnsZoneId : ''
    enableVNetIntegration: featureFlags.enableVNetIntegration
    vnetIntegrationSubnetId: featureFlags.enableVNetIntegration ? vnetModule.outputs.vnetIntegrationSubnetId : ''
    applicationInsightsConnectionString: featureFlags.enableApplicationInsights ? applicationInsightsModule!.outputs.customerAppInsights.connectionString : ''
    tags: commonTags
  }
}

module musicFunctionAppModule 'modules/azure-functions/musicFunctionApp.bicep' = if (featureFlags.enableFunctionApps) {
  name: 'musicFunctionAppDeployment'
  params: {
    location: general.location
    functionAppName: functions.apps.music
    appServicePlanId: appServicePlanModule.outputs.appServicePlanId
    storageAccountName: storage.functionApps.name
    createPrivateEndpoint: featureFlags.enablePrivateEndpoints
    privateEndpointSubnetId: featureFlags.enablePrivateEndpoints ? vnetModule.outputs.privateEndpointSubnetId : ''
    privateDnsZoneId: featureFlags.enablePrivateEndpoints ? privateDnsZonesModule.outputs.appServicePrivateDnsZoneId : ''
    enableVNetIntegration: featureFlags.enableVNetIntegration
    vnetIntegrationSubnetId: featureFlags.enableVNetIntegration ? vnetModule.outputs.vnetIntegrationSubnetId : ''
    applicationInsightsConnectionString: featureFlags.enableApplicationInsights ? applicationInsightsModule!.outputs.musicAppInsights.connectionString : ''
    tags: commonTags
  }
}

module videoFunctionAppModule 'modules/azure-functions/videoFunctionApp.bicep' = if (featureFlags.enableFunctionApps) {
  name: 'videoFunctionAppDeployment'
  params: {
    location: general.location
    functionAppName: functions.apps.video
    appServicePlanId: appServicePlanModule.outputs.appServicePlanId
    storageAccountName: storage.functionApps.name
    createPrivateEndpoint: featureFlags.enablePrivateEndpoints
    privateEndpointSubnetId: featureFlags.enablePrivateEndpoints ? vnetModule.outputs.privateEndpointSubnetId : ''
    privateDnsZoneId: featureFlags.enablePrivateEndpoints ? privateDnsZonesModule.outputs.appServicePrivateDnsZoneId : ''
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
    location: general.location
    storageAccountName: storage.functionApps.name
    storageAccountType: storage.functionApps.type
    accessTier: 'Hot'
    allowBlobPublicAccess: !featureFlags.enablePrivateEndpoints
    minimumTlsVersion: 'TLS1_2'
    createPrivateEndpoint: featureFlags.enablePrivateEndpoints
    privateEndpointSubnetId: featureFlags.enablePrivateEndpoints ? vnetModule.outputs.privateEndpointSubnetId : ''
    privateDnsZoneIds: {
      blob: (featureFlags.enablePrivateEndpoints && featureFlags.enableFunctionApps) ? privateDnsZonesModule.outputs.blobStoragePrivateDnsZoneId : ''
      file: ''
      queue: ''
      table: ''
    }
    allowedIpRanges: []
    bypassAzureServices: true
    allowedSubnetIds: featureFlags.enableVNetIntegration ? [vnetModule.outputs.vnetIntegrationSubnetId] : []
    // No role assignments needed - function apps use connection strings for runtime storage
    roleAssignments: []
    tags: union(commonTags, {
      Purpose: 'FunctionAppsRuntimeStorage'
    })
  }
}

// Test VM Module
module testVMModule 'modules/virtual-machines/testVM.bicep' = if (featureFlags.enableTestVM) {
  name: 'testVMDeployment'
  params: {
    location: general.location
    vmName: 'test-vm'
    vmSize: 'Standard_B1s'
    adminUsername: testVm.adminUsername
    adminPassword: vmAdminPassword
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

// Output Web App URLs accessible through Application Gateway
output webAppUrls array = [
  {
    name: webApps.apps.customerPublic
    url: 'http://${webApps.apps.customerPublic}.azurewebsites.net'
  }
  {
    name: webApps.apps.customerSite
    url: 'http://${webApps.apps.customerSite}.azurewebsites.net'
  }
  {
    name: webApps.apps.adminPublic
    url: 'http://${webApps.apps.adminPublic}.azurewebsites.net'
  }
  {
    name: webApps.apps.adminSite
    url: 'http://${webApps.apps.adminSite}.azurewebsites.net'
  }
  {
    name: webApps.apps.videoApi
    url: 'http://${webApps.apps.videoApi}.azurewebsites.net'
  }
  {
    name: webApps.apps.musicApi
    url: 'http://${webApps.apps.musicApi}.azurewebsites.net'
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
output internalDnsNames array = []

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
  hasPrivateEndpoint: myStorageAccountModule!.outputs.hasPrivateEndpoint
  privateEndpoints: myStorageAccountModule!.outputs.privateEndpoints
} : {
  storageAccountId: ''
  storageAccountName: ''
  blobEndpoint: ''
  containerNames: []
  hasPrivateEndpoint: false
  privateEndpoints: []
}

// Function Apps Storage Account Information
output functionAppsStorageInfo object = featureFlags.enableFunctionApps ? {
  storageAccountId: functionAppsStorageModule!.outputs.storageAccountId
  storageAccountName: functionAppsStorageModule!.outputs.storageAccountName
  primaryEndpoints: functionAppsStorageModule!.outputs.primaryEndpoints
  hasPrivateEndpoint: functionAppsStorageModule!.outputs.hasPrivateEndpoints
  privateEndpoints: functionAppsStorageModule!.outputs.privateEndpoints
} : {
  storageAccountId: ''
  storageAccountName: ''
  primaryEndpoints: {}
  hasPrivateEndpoint: false
  privateEndpoints: []
}

// Cosmos DB Outputs
output cosmosDbInfo object = featureFlags.enableCosmosDb ? {
  cosmosAccountId: cosmosDbAccountModule!.outputs.cosmosAccountId
  cosmosAccountName: cosmosDbAccountModule!.outputs.cosmosAccountName
  cosmosAccountEndpoint: cosmosDbAccountModule!.outputs.cosmosAccountEndpoint
  databaseNames: [cosmos.databases.admin.name, cosmos.databases.customer.name, cosmos.databases.music.name, cosmos.databases.video.name]
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
  topicNames: serviceBus.topics
  queueNames: serviceBus.queues
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
