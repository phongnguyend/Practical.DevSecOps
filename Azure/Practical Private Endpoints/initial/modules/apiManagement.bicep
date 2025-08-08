// API Management Module
param location string
param apiManagementName string
param publisherEmail string
param publisherName string
param vnetId string
param apiManagementSubnetName string
param videoApiUrl string
param musicApiUrl string
param apiManagementSku string = 'Premium'
param apiManagementCapacity int = 1

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
}

// Video API Backend
resource videoApiBackend 'Microsoft.ApiManagement/service/backends@2023-05-01-preview' = {
  parent: apiManagement
  name: 'video-api-backend'
  properties: {
    protocol: 'http'
    url: videoApiUrl
    description: 'Video API Backend'
  }
}

// Music API Backend  
resource musicApiBackend 'Microsoft.ApiManagement/service/backends@2023-05-01-preview' = {
  parent: apiManagement
  name: 'music-api-backend'
  properties: {
    protocol: 'http'
    url: musicApiUrl
    description: 'Music API Backend'
  }
}

// Video API Definition
resource videoApi 'Microsoft.ApiManagement/service/apis@2023-05-01-preview' = {
  parent: apiManagement
  name: 'video-api'
  properties: {
    displayName: 'Video API'
    description: 'API for managing video content'
    path: 'video'
    protocols: ['https']
    subscriptionRequired: false
    serviceUrl: videoApiUrl
  }
}

// Music API Definition
resource musicApi 'Microsoft.ApiManagement/service/apis@2023-05-01-preview' = {
  parent: apiManagement
  name: 'music-api'
  properties: {
    displayName: 'Music API'
    description: 'API for managing music content'
    path: 'music'
    protocols: ['https']
    subscriptionRequired: false
    serviceUrl: musicApiUrl
  }
}

// Video API Operations
resource videoApiGetOperation 'Microsoft.ApiManagement/service/apis/operations@2023-05-01-preview' = {
  parent: videoApi
  name: 'get-videos'
  properties: {
    displayName: 'Get Videos'
    method: 'GET'
    urlTemplate: '/'
    description: 'Get all videos'
  }
}

resource videoApiPostOperation 'Microsoft.ApiManagement/service/apis/operations@2023-05-01-preview' = {
  parent: videoApi
  name: 'post-video'
  properties: {
    displayName: 'Create Video'
    method: 'POST'
    urlTemplate: '/'
    description: 'Create a new video'
  }
}

// Music API Operations
resource musicApiGetOperation 'Microsoft.ApiManagement/service/apis/operations@2023-05-01-preview' = {
  parent: musicApi
  name: 'get-music'
  properties: {
    displayName: 'Get Music'
    method: 'GET'
    urlTemplate: '/'
    description: 'Get all music'
  }
}

resource musicApiPostOperation 'Microsoft.ApiManagement/service/apis/operations@2023-05-01-preview' = {
  parent: musicApi
  name: 'post-music'
  properties: {
    displayName: 'Create Music'
    method: 'POST'
    urlTemplate: '/'
    description: 'Create a new music track'
  }
}

// API Management Policies for Video API
resource videoApiPolicy 'Microsoft.ApiManagement/service/apis/policies@2023-05-01-preview' = {
  parent: videoApi
  name: 'policy'
  properties: {
    value: '''
    <policies>
      <inbound>
        <base />
        <set-backend-service backend-id="video-api-backend" />
        <rate-limit calls="100" renewal-period="60" />
      </inbound>
      <backend>
        <base />
      </backend>
      <outbound>
        <base />
      </outbound>
      <on-error>
        <base />
      </on-error>
    </policies>
    '''
    format: 'xml'
  }
}

// API Management Policies for Music API
resource musicApiPolicy 'Microsoft.ApiManagement/service/apis/policies@2023-05-01-preview' = {
  parent: musicApi
  name: 'policy'
  properties: {
    value: '''
    <policies>
      <inbound>
        <base />
        <set-backend-service backend-id="music-api-backend" />
        <rate-limit calls="100" renewal-period="60" />
      </inbound>
      <backend>
        <base />
      </backend>
      <outbound>
        <base />
      </outbound>
      <on-error>
        <base />
      </on-error>
    </policies>
    '''
    format: 'xml'
  }
}

// Outputs
output apiManagementName string = apiManagement.name
output apiManagementGatewayUrl string = 'https://${apiManagement.name}.azure-api.net'
output apiManagementDeveloperPortalUrl string = 'https://${apiManagement.name}.developer.azure-api.net'
output apiManagementManagementUrl string = 'https://${apiManagement.name}.management.azure-api.net'
output videoApiUrl string = 'https://${apiManagement.name}.azure-api.net/video'
output musicApiUrl string = 'https://${apiManagement.name}.azure-api.net/music'
