// Customer Public Web App Module - Customer public interface
param location string
param webAppName string
param appServicePlanId string
param tags object = {}

// VNet Integration Parameters
param enableVNetIntegration bool = false
param vnetIntegrationSubnetId string = ''

// Diagnostic Settings Parameters
param diagnosticLogAnalyticsWorkspaceId string = ''
param diagnosticCategories array = [
  'AppServiceHTTPLogs'
  'AppServiceConsoleLogs'
  'AppServiceAppLogs'
  'AppServiceAuditLogs'
  'AppServicePlatformLogs'
]

// Customer Public specific settings
param linuxFxVersion string = 'DOTNET|8.0'
param alwaysOn bool = true
param httpsOnly bool = true
param minTlsVersion string = '1.2'
param ftpsState string = 'Disabled'

// Customer Public Web App - Always public access
resource customerPublicWebApp 'Microsoft.Web/sites@2023-01-01' = {
  name: webAppName
  location: location
  kind: 'app,linux'
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlanId
    siteConfig: {
      linuxFxVersion: linuxFxVersion
      alwaysOn: alwaysOn
      ftpsState: ftpsState
      minTlsVersion: minTlsVersion
    }
    publicNetworkAccess: 'Enabled'
    httpsOnly: httpsOnly
    virtualNetworkSubnetId: enableVNetIntegration ? vnetIntegrationSubnetId : null
  }
}

// Diagnostic Settings for App Service (conditional)
resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(diagnosticLogAnalyticsWorkspaceId)) {
  name: '${webAppName}-diagnostic-settings'
  scope: customerPublicWebApp
  properties: {
    workspaceId: diagnosticLogAnalyticsWorkspaceId
    logs: [for category in diagnosticCategories: {
      category: category
      enabled: true
    }]
  }
}

// Outputs
output webAppId string = customerPublicWebApp.id
output webAppName string = customerPublicWebApp.name
output defaultHostName string = customerPublicWebApp.properties.defaultHostName
output principalId string = customerPublicWebApp.identity.principalId
output hasPrivateEndpoint bool = false
output privateEndpointId string = ''
output privateEndpointName string = ''
