// API Management Module
param location string
param apiManagementName string
param publisherEmail string
param publisherName string
param vnetId string
param apiManagementSubnetName string
param videoApiUrl string
param musicApiUrl string
param apiManagementSku string = 'Standard'
param apiManagementCapacity int = 1
param tags object = {}

// API Management Service
resource apiManagement 'Microsoft.ApiManagement/service@2023-05-01-preview' = {
  name: apiManagementName
  location: location
  sku: {
    name: apiManagementSku
    capacity: apiManagementCapacity
  }
  properties: {
    publisherEmail: publisherEmail
    publisherName: publisherName
    // VNet integration only supported for Premium tier
    virtualNetworkType: (apiManagementSku == 'Premium') ? 'External' : 'None'
    virtualNetworkConfiguration: (apiManagementSku == 'Premium') ? {
      subnetResourceId: '${vnetId}/subnets/${apiManagementSubnetName}'
    } : null
  }
  tags: tags
}

// Deploy Video API (all components)
module videoApi 'video-api/videoApi.bicep' = {
  name: 'video-api'
  params: {
    apiManagementName: apiManagement.name
    videoApiUrl: videoApiUrl
  }
}

// Deploy Music API (all components)
module musicApi 'music-api/musicApi.bicep' = {
  name: 'music-api'
  params: {
    apiManagementName: apiManagement.name
    musicApiUrl: musicApiUrl
  }
}// Outputs
output apiManagementName string = apiManagement.name
output apiManagementGatewayUrl string = 'https://${apiManagement.name}.azure-api.net'
output apiManagementDeveloperPortalUrl string = 'https://${apiManagement.name}.developer.azure-api.net'
output apiManagementManagementUrl string = 'https://${apiManagement.name}.management.azure-api.net'
output videoApiUrl string = videoApi.outputs.videoApiUrl
output musicApiUrl string = musicApi.outputs.musicApiUrl
