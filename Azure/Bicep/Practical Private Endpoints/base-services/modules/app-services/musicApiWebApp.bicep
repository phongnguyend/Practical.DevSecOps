// Music API Web App Module - Music streaming API service
param location string
param webAppName string
param appServicePlanId string
param tags object = {}

// Music API specific settings
param windowsFxVersion string = 'DOTNET|8.0'
param alwaysOn bool = true
param httpsOnly bool = true
param minTlsVersion string = '1.2'
param ftpsState string = 'Disabled'

// Private Endpoint Parameters
param createPrivateEndpoint bool = false
param privateEndpointSubnetId string = ''
param privateDnsZoneId string = ''

// VNet Integration Parameters
param enableVNetIntegration bool = false
param vnetIntegrationSubnetId string = ''

// Music API Web App with streaming-specific configuration
resource musicApiWebApp 'Microsoft.Web/sites@2023-01-01' = {
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
      cors: {
        allowedOrigins: [
          'https://*.azurewebsites.net'
        ]
        supportCredentials: true
      }
    }
    publicNetworkAccess: createPrivateEndpoint ? 'Disabled' : 'Enabled'
    httpsOnly: httpsOnly
    virtualNetworkSubnetId: enableVNetIntegration ? vnetIntegrationSubnetId : null
  }
}

// Private Endpoint (conditional)
resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-09-01' = if (createPrivateEndpoint) {
  name: '${webAppName}-pe'
  location: location
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${webAppName}-pe-connection'
        properties: {
          privateLinkServiceId: musicApiWebApp.id
          groupIds: [
            'sites'
          ]
        }
      }
    ]
  }
}

// DNS Records for Private Endpoint (conditional)
resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-09-01' = if (createPrivateEndpoint) {
  name: '${webAppName}-pe-dns-group'
  parent: privateEndpoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config'
        properties: {
          privateDnsZoneId: privateDnsZoneId
        }
      }
    ]
  }
}

// Outputs
output webAppId string = musicApiWebApp.id
output webAppName string = musicApiWebApp.name
output defaultHostName string = musicApiWebApp.properties.defaultHostName
output principalId string = musicApiWebApp.identity.principalId
output hasPrivateEndpoint bool = createPrivateEndpoint
output privateEndpointId string = createPrivateEndpoint ? privateEndpoint.id : ''
output privateEndpointName string = createPrivateEndpoint ? privateEndpoint.name : ''

// Key Vault Access Policy for this web app
output keyVaultAccessPolicy object = {
  tenantId: tenant().tenantId
  objectId: musicApiWebApp.identity.principalId
  permissions: {
    keys: []
    secrets: [
      'get'
    ]
    certificates: []
  }
}

