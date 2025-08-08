// Video API Operations Module
// This module creates operations for the Video API

@description('The name of the API Management service')
param apiManagementName string

@description('The name of the Video API')
param videoApiName string

// Reference to existing API Management service
resource apiManagement 'Microsoft.ApiManagement/service@2023-05-01-preview' existing = {
  name: apiManagementName
}

// Reference to existing Video API
resource videoApi 'Microsoft.ApiManagement/service/apis@2023-05-01-preview' existing = {
  parent: apiManagement
  name: videoApiName
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

resource videoApiGetByIdOperation 'Microsoft.ApiManagement/service/apis/operations@2023-05-01-preview' = {
  parent: videoApi
  name: 'get-video-by-id'
  properties: {
    displayName: 'Get Video by ID'
    method: 'GET'
    urlTemplate: '/{id}'
    description: 'Get a specific video by ID'
    templateParameters: [
      {
        name: 'id'
        description: 'Video ID'
        type: 'string'
        required: true
      }
    ]
  }
}

resource videoApiPutOperation 'Microsoft.ApiManagement/service/apis/operations@2023-05-01-preview' = {
  parent: videoApi
  name: 'put-video'
  properties: {
    displayName: 'Update Video'
    method: 'PUT'
    urlTemplate: '/{id}'
    description: 'Update an existing video'
    templateParameters: [
      {
        name: 'id'
        description: 'Video ID'
        type: 'string'
        required: true
      }
    ]
  }
}

resource videoApiDeleteOperation 'Microsoft.ApiManagement/service/apis/operations@2023-05-01-preview' = {
  parent: videoApi
  name: 'delete-video'
  properties: {
    displayName: 'Delete Video'
    method: 'DELETE'
    urlTemplate: '/{id}'
    description: 'Delete a video'
    templateParameters: [
      {
        name: 'id'
        description: 'Video ID'
        type: 'string'
        required: true
      }
    ]
  }
}

// Outputs
output videoApiGetOperationName string = videoApiGetOperation.name
output videoApiPostOperationName string = videoApiPostOperation.name
output videoApiGetByIdOperationName string = videoApiGetByIdOperation.name
output videoApiPutOperationName string = videoApiPutOperation.name
output videoApiDeleteOperationName string = videoApiDeleteOperation.name
