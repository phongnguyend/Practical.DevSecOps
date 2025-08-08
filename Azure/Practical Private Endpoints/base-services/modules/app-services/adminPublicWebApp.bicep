// Admin Public Web App Module - Admin public interface
param location string
param webAppName string
param appServicePlanId string
param tags object = {}

// VNet Integration Parameters
param enableVNetIntegration bool = false
param vnetIntegrationSubnetId string = ''

// Admin Public specific settings
param windowsFxVersion string = 'DOTNET|8.0'
param alwaysOn bool = true
param httpsOnly bool = true
param minTlsVersion string = '1.2'
param ftpsState string = 'Disabled'

// Admin Public Web App with enhanced monitoring
resource adminPublicWebApp 'Microsoft.Web/sites@2023-01-01' = {
  name: webAppName
  location: location
  kind: 'app'
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlanId
    siteConfig: {
      windowsFxVersion: windowsFxVersion
      alwaysOn: alwaysOn
      ftpsState: ftpsState
      minTlsVersion: minTlsVersion
    }
    publicNetworkAccess: 'Enabled'
    httpsOnly: httpsOnly
    virtualNetworkSubnetId: enableVNetIntegration ? vnetIntegrationSubnetId : null
  }
}

// Outputs
output webAppId string = adminPublicWebApp.id
output webAppName string = adminPublicWebApp.name
output defaultHostName string = adminPublicWebApp.properties.defaultHostName
output principalId string = adminPublicWebApp.identity.principalId
output hasPrivateEndpoint bool = false
output privateEndpointId string = ''
output privateEndpointName string = ''

// Key Vault Access Policy for this web app
output keyVaultAccessPolicy object = {
  tenantId: tenant().tenantId
  objectId: adminPublicWebApp.identity.principalId
  permissions: {
    keys: [
      'get'
      'list'
    ]
    secrets: [
      'get'
      'list'
    ]
    certificates: [
      'get'
      'list'
    ]
  }
}
