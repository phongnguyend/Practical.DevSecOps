// Admin Site Web App Module - Internal admin portal with private endpoint capability
param location string
param webAppName string
param appServicePlanId string
param tags object = {}

// Admin Site specific settings
param linuxFxVersion string = 'DOTNET|8.0'
param alwaysOn bool = true
param httpsOnly bool = true
param minTlsVersion string = '1.2'
param ftpsState string = 'FtpsOnly'

// Private Endpoint Parameters
param createPrivateEndpoint bool = false
param privateEndpointSubnetId string = ''
param privateDnsZoneId string = ''

// VNet Integration Parameters
param enableVNetIntegration bool = false
param vnetIntegrationSubnetId string = ''

// Admin Site Web App with maximum security
resource adminSiteWebApp 'Microsoft.Web/sites@2023-01-01' = {
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
      ipSecurityRestrictions: [
        {
          ipAddress: '10.0.0.0/8'
          action: 'Allow'
          priority: 100
          name: 'AllowPrivateNetworks'
          description: 'Allow access from private networks only'
        }
      ]
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
          privateLinkServiceId: adminSiteWebApp.id
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
output webAppId string = adminSiteWebApp.id
output webAppName string = adminSiteWebApp.name
output defaultHostName string = adminSiteWebApp.properties.defaultHostName
output principalId string = adminSiteWebApp.identity.principalId
output hasPrivateEndpoint bool = createPrivateEndpoint
output privateEndpointId string = createPrivateEndpoint ? privateEndpoint.id : ''
output privateEndpointName string = createPrivateEndpoint ? privateEndpoint.name : ''
