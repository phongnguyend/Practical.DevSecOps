param location string = 'southeastasia'

// Feature Flags
param enablePrivateEndpoints bool = false
param enableVNetIntegration bool = false
param enableTestVM bool = false
param enableSqlServer bool = false
param enableKeyVault bool = false
param enableAppConfiguration bool = false
param enableBlobStorage bool = false
param enableCosmosDb bool = false
param enableFunctionApps bool = false
param enableServiceBus bool = false
param enableApplicationInsights bool = false

param sqlServerName string = 'PracticalMultipleResourceGroups'
param adminUsername string = 'PracticalMultipleResourceGroups'
@secure()
param adminPassword string = ''
param appServicePlanName string = 'PracticalMultipleResourceGroups'
param vnetName string = 'PracticalMultipleResourceGroups-vnet'
param keyVaultName string = 'practicalmrgkv'
param appConfigName string = 'PracticalMultipleResourceGroups-config'
param storageAccountName string = 'practicalmrgblob'
param functionAppsStorageAccountName string = 'practicalmrgfuncappsst'

// Individual Web App Name Parameters
param customerPublicWebAppName string = 'PracticalMultipleResourceGroups-CUSTOMER-PUBLIC'
param customerSiteWebAppName string = 'PracticalMultipleResourceGroups-CUSTOMER-SITE'
param adminPublicWebAppName string = 'PracticalMultipleResourceGroups-ADMIN-PUBLIC'
param adminSiteWebAppName string = 'PracticalMultipleResourceGroups-ADMIN-SITE'
param videoApiWebAppName string = 'PracticalMultipleResourceGroups-VIDEO-API'
param musicApiWebAppName string = 'PracticalMultipleResourceGroups-MUSIC-API'

// Individual Database Name Parameters
param customerDbName string = 'PracticalMultipleResourceGroups-CUSTOMER-DB'
param adminDbName string = 'PracticalMultipleResourceGroups-ADMIN-DB'
param videoDbName string = 'PracticalMultipleResourceGroups-VIDEO-DB'
param musicDbName string = 'PracticalMultipleResourceGroups-MUSIC-DB'

// Test VM parameters
param vmAdminUsername string = 'testadmin'
@secure()
param vmAdminPassword string = ''

// Blob Storage parameters
param storageAccountType string = 'Standard_LRS'
param blobContainerNames array = [
  'documents'
  'images'
  'backups'
  'logs'
]

// Cosmos DB parameters
param cosmosAccountName string = 'practicalmrg-cosmos-${uniqueString(resourceGroup().id)}'
param cosmosConsistencyLevel string = 'Session'
param cosmosEnableAutomaticFailover bool = true

// Individual Cosmos Database Names
param cosmosAdminDbName string = 'PracticalMultipleResourceGroups-ADMIN-COSMOS-DB'
param cosmosCustomerDbName string = 'PracticalMultipleResourceGroups-CUSTOMER-COSMOS-DB'
param cosmosMusicDbName string = 'PracticalMultipleResourceGroups-MUSIC-COSMOS-DB'
param cosmosVideoDbName string = 'PracticalMultipleResourceGroups-VIDEO-COSMOS-DB'

// Function App parameters
param adminFunctionAppName string = 'PracticalMultipleResourceGroups-ADMIN-FUNC'
param customerFunctionAppName string = 'PracticalMultipleResourceGroups-CUSTOMER-FUNC'
param musicFunctionAppName string = 'PracticalMultipleResourceGroups-MUSIC-FUNC'
param videoFunctionAppName string = 'PracticalMultipleResourceGroups-VIDEO-FUNC'

// Application Insights parameters
param applicationInsightsWorkspaceName string = 'PracticalMultipleResourceGroups-law'
param retentionInDays int = 30

// Service Bus parameters
param serviceBusNamespaceName string = 'PracticalMultipleResourceGroups-sb-${uniqueString(resourceGroup().id)}'
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

// Private DNS Zone Names from networking layer
@description('Private DNS Zone Name for App Configuration')
param appConfigPrivateDnsZoneName string = 'privatelink.azconfig.io'

@description('Private DNS Zone Name for Blob Storage')
param blobStoragePrivateDnsZoneName string = 'privatelink.blob.${environment().suffixes.storage}'

@description('Private DNS Zone Name for Cosmos DB')
param cosmosPrivateDnsZoneName string = 'privatelink.documents.azure.com'

@description('Private DNS Zone Name for Service Bus')
param serviceBusPrivateDnsZoneName string = 'privatelink.servicebus.windows.net'

@description('Private DNS Zone Name for App Service')
param appServicePrivateDnsZoneName string = 'privatelink.azurewebsites.net'

// Common tags variable
var commonTags = {
  Environment: 'Development'
  Project: 'PracticalMultipleResourceGroups'
}

// Private DNS Zones Module
module privateDnsZonesModule 'modules/private-dns-zones/privateDNSZones.bicep' = {
  name: 'privateDnsZonesDeployment'
  params: {
    networkingLayerResourceGroup: networkingLayerResourceGroup
    appConfigPrivateDnsZoneName: appConfigPrivateDnsZoneName
    blobStoragePrivateDnsZoneName: blobStoragePrivateDnsZoneName
    cosmosPrivateDnsZoneName: cosmosPrivateDnsZoneName
    serviceBusPrivateDnsZoneName: serviceBusPrivateDnsZoneName
    appServicePrivateDnsZoneName: appServicePrivateDnsZoneName
  }
}

// Reference existing resources from networking-layer
@description('Resource group of the networking-layer deployment')
param networkingLayerResourceGroup string

// Virtual Network Module (reference existing from networking-layer)
module vnetModule 'modules/virtual-networks/virtualNetwork.bicep' = {
  name: 'virtualNetworkDeployment'
  params: {
    vnetResourceGroup: networkingLayerResourceGroup
    vnetName: vnetName
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
    // Consolidated Role Assignment Parameters for Key Vault access
    roleAssignments: enableKeyVault ? concat(
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
    ) : []
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
    privateDnsZoneId: (enablePrivateEndpoints && enableAppConfiguration) ? privateDnsZonesModule.outputs.appConfigPrivateDnsZoneId : ''
    // Consolidated Role Assignment Parameters
    roleAssignments: enableAppConfiguration ? concat(
      // Web Apps
      [
        {
          id: customerPublicWebAppModule.outputs.webAppId
          principalId: customerPublicWebAppModule.outputs.principalId
        }
        {
          id: customerSiteWebAppModule.outputs.webAppId
          principalId: customerSiteWebAppModule.outputs.principalId
        }
        {
          id: adminPublicWebAppModule.outputs.webAppId
          principalId: adminPublicWebAppModule.outputs.principalId
        }
        {
          id: adminSiteWebAppModule.outputs.webAppId
          principalId: adminSiteWebAppModule.outputs.principalId
        }
        {
          id: videoApiWebAppModule.outputs.webAppId
          principalId: videoApiWebAppModule.outputs.principalId
        }
        {
          id: musicApiWebAppModule.outputs.webAppId
          principalId: musicApiWebAppModule.outputs.principalId
        }
      ],
      // Function Apps (only when enabled)
      enableFunctionApps ? [
        {
          id: adminFunctionAppModule!.outputs.functionAppId
          principalId: adminFunctionAppModule!.outputs.principalId
        }
        {
          id: customerFunctionAppModule!.outputs.functionAppId
          principalId: customerFunctionAppModule!.outputs.principalId
        }
        {
          id: musicFunctionAppModule!.outputs.functionAppId
          principalId: musicFunctionAppModule!.outputs.principalId
        }
        {
          id: videoFunctionAppModule!.outputs.functionAppId
          principalId: videoFunctionAppModule!.outputs.principalId
        }
      ] : []
    ) : []
  }
}

// Blob Storage Module
module blobStorageModule 'modules/storage-accounts/myStorageAccount.bicep' = if (enableBlobStorage) {
  name: 'blobStorageDeployment'
  params: {
    location: location
    storageAccountName: storageAccountName
    storageAccountType: storageAccountType
    containerNames: blobContainerNames
    createPrivateEndpoint: enablePrivateEndpoints
    privateEndpointSubnetId: enablePrivateEndpoints ? vnetModule.outputs.privateEndpointSubnetId : ''
    privateDnsZoneId: (enablePrivateEndpoints && enableBlobStorage) ? privateDnsZonesModule.outputs.blobStoragePrivateDnsZoneId : ''
    allowedSubnets: enableVNetIntegration ? [vnetModule.outputs.vnetIntegrationSubnetId] : []
    allowBlobPublicAccess: !enablePrivateEndpoints
    // Consolidated Role Assignment Parameters
    roleAssignments: enableBlobStorage ? concat(
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
    privateDnsZoneId: (enablePrivateEndpoints && enableCosmosDb) ? privateDnsZonesModule.outputs.cosmosPrivateDnsZoneId : ''
    allowedSubnets: enableVNetIntegration ? [vnetModule.outputs.vnetIntegrationSubnetId] : []
    enablePublicNetworkAccess: !enablePrivateEndpoints
    tags: commonTags
    // Consolidated Role Assignment Parameters
    roleAssignments: enableCosmosDb ? concat(
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
    ) : []
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
    privateDnsZoneId: enablePrivateEndpoints ? privateDnsZonesModule.outputs.appServicePrivateDnsZoneId : ''
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
    privateDnsZoneId: enablePrivateEndpoints ? privateDnsZonesModule.outputs.appServicePrivateDnsZoneId : ''
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
    privateDnsZoneId: enablePrivateEndpoints ? privateDnsZonesModule.outputs.appServicePrivateDnsZoneId : ''
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
    privateDnsZoneId: enablePrivateEndpoints ? privateDnsZonesModule.outputs.appServicePrivateDnsZoneId : ''
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
    privateDnsZoneId: enablePrivateEndpoints ? privateDnsZonesModule.outputs.appServicePrivateDnsZoneId : ''
    enableVNetIntegration: enableVNetIntegration
    vnetIntegrationSubnetId: enableVNetIntegration ? vnetModule.outputs.vnetIntegrationSubnetId : ''
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
    privateDnsZoneId: enablePrivateEndpoints ? privateDnsZonesModule.outputs.appServicePrivateDnsZoneId : ''
    enableVNetIntegration: enableVNetIntegration
    vnetIntegrationSubnetId: enableVNetIntegration ? vnetModule.outputs.vnetIntegrationSubnetId : ''
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
    privateDnsZoneId: enablePrivateEndpoints ? privateDnsZonesModule.outputs.appServicePrivateDnsZoneId : ''
    enableVNetIntegration: enableVNetIntegration
    vnetIntegrationSubnetId: enableVNetIntegration ? vnetModule.outputs.vnetIntegrationSubnetId : ''
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
    privateDnsZoneId: enablePrivateEndpoints ? privateDnsZonesModule.outputs.appServicePrivateDnsZoneId : ''
    enableVNetIntegration: enableVNetIntegration
    vnetIntegrationSubnetId: enableVNetIntegration ? vnetModule.outputs.vnetIntegrationSubnetId : ''
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
    createPrivateEndpoint: enablePrivateEndpoints
    privateEndpointSubnetId: enablePrivateEndpoints ? vnetModule.outputs.privateEndpointSubnetId : ''
    privateDnsZoneId: (enablePrivateEndpoints && enableFunctionApps) ? privateDnsZonesModule.outputs.blobStoragePrivateDnsZoneId : ''
    allowedSubnets: enableVNetIntegration ? [vnetModule.outputs.vnetIntegrationSubnetId] : []
    allowBlobPublicAccess: !enablePrivateEndpoints
    // No role assignments needed - function apps use connection strings for runtime storage
    roleAssignments: []
    tags: union(commonTags, {
      Purpose: 'FunctionAppsRuntimeStorage'
    })
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

// Blob Storage Information
output blobStorageInfo object = enableBlobStorage ? {
  storageAccountId: blobStorageModule!.outputs.storageAccountId
  storageAccountName: blobStorageModule!.outputs.storageAccountName
  blobEndpoint: blobStorageModule!.outputs.storageAccountPrimaryBlobEndpoint
  containerNames: blobStorageModule!.outputs.containerNames
  hasPrivateEndpoint: blobStorageModule!.outputs.hasPrivateEndpoint
  privateEndpointId: blobStorageModule!.outputs.privateEndpointId
  privateEndpointName: blobStorageModule!.outputs.privateEndpointName
} : {
  storageAccountId: ''
  storageAccountName: ''
  blobEndpoint: ''
  containerNames: []
  hasPrivateEndpoint: false
  privateEndpointId: ''
  privateEndpointName: ''
}

// Function Apps Storage Account Information
output functionAppsStorageInfo object = enableFunctionApps ? {
  storageAccountId: functionAppsStorageModule!.outputs.storageAccountId
  storageAccountName: functionAppsStorageModule!.outputs.storageAccountName
  primaryEndpoints: functionAppsStorageModule!.outputs.primaryEndpoints
  hasPrivateEndpoint: functionAppsStorageModule!.outputs.hasPrivateEndpoint
  privateEndpointId: functionAppsStorageModule!.outputs.privateEndpointId
} : {
  storageAccountId: ''
  storageAccountName: ''
  primaryEndpoints: {}
  hasPrivateEndpoint: false
  privateEndpointId: ''
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
