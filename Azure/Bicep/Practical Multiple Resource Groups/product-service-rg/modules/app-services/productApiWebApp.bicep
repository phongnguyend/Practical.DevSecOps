param location string
param appServicePlanId string
param productApiWebAppName string
param enablePrivateEndpoints bool = false
param privateEndpointSubnetId string = ''
param tags object = {}

// Product API Web App
resource productApiWebApp 'Microsoft.Web/sites@2023-01-01' = {
  name: productApiWebAppName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: true
    publicNetworkAccess: enablePrivateEndpoints ? 'Disabled' : 'Enabled'
    siteConfig: {
      netFrameworkVersion: 'v8.0'
      appSettings: [
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '1'
        }
      ]
    }
  }
  tags: tags
}

// Private Endpoint for Product API (if enabled)
resource productApiPrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-04-01' = if (enablePrivateEndpoints && privateEndpointSubnetId != '') {
  name: '${productApiWebAppName}-pe'
  location: location
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${productApiWebAppName}-pe-connection'
        properties: {
          privateLinkServiceId: productApiWebApp.id
          groupIds: ['sites']
        }
      }
    ]
  }
  tags: tags
}

// Outputs
output productApiWebAppId string = productApiWebApp.id
output productApiWebAppName string = productApiWebApp.name
output productApiWebAppUrl string = 'https://${productApiWebApp.properties.defaultHostName}'
output productApiWebAppPrincipalId string = productApiWebApp.identity.principalId
output hasPrivateEndpoint bool = enablePrivateEndpoints && privateEndpointSubnetId != ''
output privateEndpointId string = enablePrivateEndpoints && privateEndpointSubnetId != '' ? productApiPrivateEndpoint.id : ''
