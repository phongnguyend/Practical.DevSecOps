// Customer Site Web App Module - Customer internal management interface
param location string
param webAppName string
param appServicePlanId string
param tags object = {}

// VNet Integration Parameters
param enableVNetIntegration bool = false
param vnetIntegrationSubnetId string = ''

// Customer Site specific settings
param linuxFxVersion string = 'DOTNET|8.0'
param alwaysOn bool = true
param httpsOnly bool = true
param minTlsVersion string = '1.2'
param ftpsState string = 'Disabled'

// Private Endpoint Parameters
param createPrivateEndpoint bool = false
param privateEndpointSubnetId string = ''
param privateDnsZoneId string = ''

// Customer Site Web App with enhanced security
resource customerSiteWebApp 'Microsoft.Web/sites@2023-01-01' = {
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
  linuxFxVersion: linuxFxVersion
      alwaysOn: alwaysOn
      ftpsState: ftpsState
      minTlsVersion: minTlsVersion
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
          privateLinkServiceId: customerSiteWebApp.id
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
output webAppId string = customerSiteWebApp.id
output webAppName string = customerSiteWebApp.name
output defaultHostName string = customerSiteWebApp.properties.defaultHostName
output principalId string = customerSiteWebApp.identity.principalId
output hasPrivateEndpoint bool = createPrivateEndpoint
output privateEndpointId string = createPrivateEndpoint ? privateEndpoint.id : ''
output privateEndpointName string = createPrivateEndpoint ? privateEndpoint.name : ''
