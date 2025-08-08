// new-app-service.bicep
// Template for creating a new App Service (Web App)
// Use this to deploy individual web applications to App Service Plans

@description('Name of the App Service (Web App)')
param appServiceName string

@description('Name of the existing App Service Plan')
param existingAppServicePlanName string

@description('Resource group containing the App Service Plan')
param appServicePlanResourceGroup string = resourceGroup().name

@description('Location for the App Service')
param location string = resourceGroup().location

@description('Runtime stack for the application')
@allowed([
  'DOTNETCORE|8.0'
  'DOTNETCORE|6.0'
  'DOTNET|8.0'
  'DOTNET|6.0'
  'NODE|20-lts'
  'NODE|18-lts'
  'PYTHON|3.11'
  'PYTHON|3.10'
  'JAVA|17-java17'
  'JAVA|11-java11'
  'PHP|8.2'
  'PHP|8.1'
])
param linuxFxVersion string = 'DOTNETCORE|8.0'

@description('Net Framework version (for Windows apps)')
@allowed([
  'v4.0'
  'v6.0'
  'v8.0'
])
param netFrameworkVersion string = 'v8.0'

@description('Whether to enable HTTPS only')
param httpsOnly bool = true

@description('Whether to enable client affinity')
param clientAffinityEnabled bool = false

@description('Application settings')
param appSettings array = []

@description('Connection strings')
param connectionStrings array = []

@description('Whether to create a system-assigned managed identity')
param enableSystemAssignedIdentity bool = true

@description('Whether to enable Application Insights')
param enableApplicationInsights bool = true

@description('Name of existing Application Insights (if not provided, will create new)')
param existingApplicationInsightsName string = ''

@description('Whether to enable VNet integration')
param enableVNetIntegration bool = false

@description('Name of the existing VNet for integration')
param existingVnetName string = 'PracticalPrivateEndpoints-vnet'

@description('Name of the subnet for VNet integration')
param vnetIntegrationSubnetName string = 'default'

@description('Whether to create a private endpoint')
param createPrivateEndpoint bool = false

@description('Name of the subnet for private endpoint')
param privateEndpointSubnetName string = 'private-endpoints'

@description('Whether to disable public network access')
param publicNetworkAccess bool = true

@description('Tags to apply to the App Service')
param tags object = {}

// Reference to existing App Service Plan
resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' existing = {
  name: existingAppServicePlanName
  scope: resourceGroup(appServicePlanResourceGroup)
}

// Reference to existing VNet (if VNet integration is enabled)
resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' existing = if (enableVNetIntegration) {
  name: existingVnetName
}

// Reference to VNet integration subnet
resource vnetIntegrationSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' existing = if (enableVNetIntegration) {
  parent: vnet
  name: vnetIntegrationSubnetName
}

// Reference to private endpoint subnet
resource privateEndpointSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' existing = if (createPrivateEndpoint) {
  parent: vnet
  name: privateEndpointSubnetName
}

// Create Application Insights if enabled and not existing
resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = if (enableApplicationInsights && empty(existingApplicationInsightsName)) {
  name: '${appServiceName}-ai'
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Request_Source: 'rest'
    RetentionInDays: 90
    WorkspaceResourceId: null
    IngestionMode: 'ApplicationInsights'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

// Reference to existing Application Insights
resource existingApplicationInsights 'Microsoft.Insights/components@2020-02-02' existing = if (enableApplicationInsights && !empty(existingApplicationInsightsName)) {
  name: existingApplicationInsightsName
}

// Determine if App Service Plan is Linux
var isLinux = appServicePlan.properties.reserved

// Create the App Service
resource appService 'Microsoft.Web/sites@2023-01-01' = {
  name: appServiceName
  location: location
  tags: tags
  identity: enableSystemAssignedIdentity ? {
    type: 'SystemAssigned'
  } : null
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: httpsOnly
    clientAffinityEnabled: clientAffinityEnabled
    publicNetworkAccess: publicNetworkAccess ? 'Enabled' : 'Disabled'
    virtualNetworkSubnetId: enableVNetIntegration ? vnetIntegrationSubnet.id : null
    siteConfig: {
      linuxFxVersion: isLinux ? linuxFxVersion : null
      netFrameworkVersion: !isLinux ? netFrameworkVersion : null
      alwaysOn: appServicePlan.sku.tier != 'Free' && appServicePlan.sku.tier != 'Shared'
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      scmMinTlsVersion: '1.2'
      use32BitWorkerProcess: false
      webSocketsEnabled: false
      appSettings: appSettings
      connectionStrings: connectionStrings
    }
  }
}

// Create private endpoint if requested
resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-05-01' = if (createPrivateEndpoint) {
  name: '${appServiceName}-pe'
  location: location
  tags: tags
  properties: {
    subnet: {
      id: privateEndpointSubnet.id
    }
    privateLinkServiceConnections: [
      {
        name: '${appServiceName}-pe-connection'
        properties: {
          privateLinkServiceId: appService.id
          groupIds: [
            'sites'
          ]
        }
      }
    ]
  }
}

// Create private DNS zone group for private endpoint
resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-05-01' = if (createPrivateEndpoint) {
  parent: privateEndpoint
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-azurewebsites-net'
        properties: {
          privateDnsZoneId: resourceId('Microsoft.Network/privateDnsZones', 'privatelink.azurewebsites.net')
        }
      }
    ]
  }
}

// Outputs
output appServiceId string = appService.id
output appServiceName string = appService.name
output defaultHostName string = appService.properties.defaultHostName
output appServiceUrl string = 'https://${appService.properties.defaultHostName}'
output principalId string = enableSystemAssignedIdentity ? appService.identity.principalId : ''
output appServicePlanId string = appServicePlan.id
output applicationInsightsId string = enableApplicationInsights && empty(existingApplicationInsightsName) ? applicationInsights.id : enableApplicationInsights && !empty(existingApplicationInsightsName) ? existingApplicationInsights.id : ''
output privateEndpointId string = createPrivateEndpoint ? privateEndpoint.id : ''
output isLinux bool = isLinux
output vnetIntegrationEnabled bool = enableVNetIntegration
