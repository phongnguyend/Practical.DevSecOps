param location string
param appServicePlanId string
param productFunctionAppName string
param functionStorageAccountName string
param enablePrivateEndpoints bool = false
param privateEndpointSubnetId string = ''
param tags object = {}

// Product Function App
resource productFunctionApp 'Microsoft.Web/sites@2023-01-01' = {
  name: productFunctionAppName
  location: location
  kind: 'functionapp,linux'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: true
    publicNetworkAccess: enablePrivateEndpoints ? 'Disabled' : 'Enabled'
    siteConfig: {
      linuxFxVersion: 'DOTNET|8.0'
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${functionStorageAccountName};AccountKey=listKeys(resourceId(\'Microsoft.Storage/storageAccounts\', functionStorageAccountName), \'2023-01-01\').keys[0].value;EndpointSuffix=core.windows.net'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${functionStorageAccountName};AccountKey=listKeys(resourceId(\'Microsoft.Storage/storageAccounts\', functionStorageAccountName), \'2023-01-01\').keys[0].value;EndpointSuffix=core.windows.net'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(productFunctionAppName)
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet-isolated'
        }
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '1'
        }
      ]
    }
  }
  tags: tags
}

// Private Endpoint for Product Function App (if enabled)
resource productFunctionPrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-04-01' = if (enablePrivateEndpoints && privateEndpointSubnetId != '') {
  name: '${productFunctionAppName}-pe'
  location: location
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${productFunctionAppName}-pe-connection'
        properties: {
          privateLinkServiceId: productFunctionApp.id
          groupIds: ['sites']
        }
      }
    ]
  }
  tags: tags
}

// Outputs
output productFunctionAppId string = productFunctionApp.id
output productFunctionAppName string = productFunctionApp.name
output productFunctionAppUrl string = 'https://${productFunctionApp.properties.defaultHostName}'
output productFunctionAppPrincipalId string = productFunctionApp.identity.principalId
output hasPrivateEndpoint bool = enablePrivateEndpoints && privateEndpointSubnetId != ''
output privateEndpointId string = enablePrivateEndpoints && privateEndpointSubnetId != '' ? productFunctionPrivateEndpoint.id : ''
