param location string
param functionAppName string
param appServicePlanId string
param storageAccountName string

// Private endpoint configuration
param createPrivateEndpoint bool
param privateEndpointSubnetId string
param privateDnsZoneId string

// VNet Integration Parameters
param enableVNetIntegration bool
param vnetIntegrationSubnetId string

// Function-specific settings
param linuxFxVersion string = 'DOTNET-ISOLATED|8.0'
param alwaysOn bool = true

// Application Insights Configuration
param applicationInsightsConnectionString string

// Additional app settings from outside (optional)
param additionalAppSettings object = {}

// Tags
param tags object

// Reference to existing storage account for function app
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageAccountName
}

// Video Function App
resource videoFunctionApp 'Microsoft.Web/sites@2024-04-01' = {
  name: functionAppName
  location: location
  tags: tags
  kind: 'functionapp,linux'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: true
    publicNetworkAccess: createPrivateEndpoint ? 'Disabled' : 'Enabled'
    reserved: true  // Required for Linux Function Apps
    siteConfig: {
      minTlsVersion: '1.2'
      use32BitWorkerProcess: false
      ftpsState: 'FtpsOnly'
      alwaysOn: alwaysOn
      linuxFxVersion: linuxFxVersion
    }
  }

  resource configAppSettings 'config' = {
    name: 'appsettings'
    properties: union({
      APPLICATIONINSIGHTS_AUTHENTICATION_STRING: 'Authorization=AAD'
      APPLICATIONINSIGHTS_CONNECTION_STRING: applicationInsightsConnectionString
      AzureWebJobsStorage__credential: 'managedidentity'
      AzureWebJobsStorage__blobServiceUri: 'https://${storageAccount.name}.blob.${environment().suffixes.storage}'
      AzureWebJobsStorage__queueServiceUri: 'https://${storageAccount.name}.queue.${environment().suffixes.storage}'
      AzureWebJobsStorage__tableServiceUri: 'https://${storageAccount.name}.table.${environment().suffixes.storage}'
      FUNCTIONS_EXTENSION_VERSION: '~4'
      FUNCTIONS_WORKER_RUNTIME: 'dotnet-isolated'
      WEBSITE_USE_PLACEHOLDER_DOTNETISOLATED: '1'
    }, additionalAppSettings)
  }
}

// Private Endpoint (conditional)
resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-09-01' = if (createPrivateEndpoint) {
  name: '${functionAppName}-pe'
  location: location
  tags: tags
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${functionAppName}-pe-connection'
        properties: {
          privateLinkServiceId: videoFunctionApp.id
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
  name: '${functionAppName}-pe-dns-group'
  parent: privateEndpoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-azurewebsites-net'
        properties: {
          privateDnsZoneId: privateDnsZoneId
        }
      }
    ]
  }
}

// VNet Integration
resource networkConfig 'Microsoft.Web/sites/networkConfig@2022-03-01' = if (enableVNetIntegration) {
  name: 'virtualNetwork'
  parent: videoFunctionApp
  properties: {
    subnetResourceId: vnetIntegrationSubnetId
  }
}


// Outputs
output functionAppId string = videoFunctionApp.id
output functionAppName string = videoFunctionApp.name
output principalId string = videoFunctionApp.identity.principalId
output defaultHostName string = videoFunctionApp.properties.defaultHostName
output hasPrivateEndpoint bool = createPrivateEndpoint
output privateEndpointId string = createPrivateEndpoint ? privateEndpoint.id : ''
output privateEndpointName string = createPrivateEndpoint ? privateEndpoint.name : ''
output functionAppUrl string = 'https://${videoFunctionApp.properties.defaultHostName}'
