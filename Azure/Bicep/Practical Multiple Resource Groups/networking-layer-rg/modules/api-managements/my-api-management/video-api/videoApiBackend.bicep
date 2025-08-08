// Video API Backend Module
// This module creates the Video API backend for the API Management service

@description('The name of the API Management service')
param apiManagementName string

@description('The URL of the Video API backend service')
param videoApiUrl string

@description('Backend protocol')
param protocol string = 'http'

@description('Additional backend properties')
param additionalProperties object = {}

// Reference to existing API Management service
resource apiManagement 'Microsoft.ApiManagement/service@2023-05-01-preview' existing = {
  name: apiManagementName
}

// Video API Backend
resource videoApiBackend 'Microsoft.ApiManagement/service/backends@2023-05-01-preview' = {
  parent: apiManagement
  name: 'video-api-backend'
  properties: union({
    protocol: protocol
    url: videoApiUrl
    description: 'Video API Backend for managing video content'
    title: 'Video API Backend'
  }, additionalProperties)
}

// Outputs
output videoApiBackendId string = videoApiBackend.id
output videoApiBackendName string = videoApiBackend.name
output videoApiBackendUrl string = videoApiUrl
