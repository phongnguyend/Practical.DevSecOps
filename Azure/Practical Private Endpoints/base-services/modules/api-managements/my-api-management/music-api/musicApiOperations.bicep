// Music API Operations Module
// This module creates operations for the Music API

@description('The name of the API Management service')
param apiManagementName string

@description('The name of the Music API')
param musicApiName string

// Reference to existing API Management service
resource apiManagement 'Microsoft.ApiManagement/service@2023-05-01-preview' existing = {
  name: apiManagementName
}

// Reference to existing Music API
resource musicApi 'Microsoft.ApiManagement/service/apis@2023-05-01-preview' existing = {
  parent: apiManagement
  name: musicApiName
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

resource musicApiGetByIdOperation 'Microsoft.ApiManagement/service/apis/operations@2023-05-01-preview' = {
  parent: musicApi
  name: 'get-music-by-id'
  properties: {
    displayName: 'Get Music by ID'
    method: 'GET'
    urlTemplate: '/{id}'
    description: 'Get a specific music track by ID'
    templateParameters: [
      {
        name: 'id'
        description: 'Music ID'
        type: 'string'
        required: true
      }
    ]
  }
}

resource musicApiPutOperation 'Microsoft.ApiManagement/service/apis/operations@2023-05-01-preview' = {
  parent: musicApi
  name: 'put-music'
  properties: {
    displayName: 'Update Music'
    method: 'PUT'
    urlTemplate: '/{id}'
    description: 'Update an existing music track'
    templateParameters: [
      {
        name: 'id'
        description: 'Music ID'
        type: 'string'
        required: true
      }
    ]
  }
}

resource musicApiDeleteOperation 'Microsoft.ApiManagement/service/apis/operations@2023-05-01-preview' = {
  parent: musicApi
  name: 'delete-music'
  properties: {
    displayName: 'Delete Music'
    method: 'DELETE'
    urlTemplate: '/{id}'
    description: 'Delete a music track'
    templateParameters: [
      {
        name: 'id'
        description: 'Music ID'
        type: 'string'
        required: true
      }
    ]
  }
}

// Outputs
output musicApiGetOperationName string = musicApiGetOperation.name
output musicApiPostOperationName string = musicApiPostOperation.name
output musicApiGetByIdOperationName string = musicApiGetByIdOperation.name
output musicApiPutOperationName string = musicApiPutOperation.name
output musicApiDeleteOperationName string = musicApiDeleteOperation.name
