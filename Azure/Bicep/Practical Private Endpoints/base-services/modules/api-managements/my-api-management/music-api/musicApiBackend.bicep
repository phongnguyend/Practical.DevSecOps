// Music API Backend Module
// This module creates the Music API backend for the API Management service

@description('The name of the API Management service')
param apiManagementName string

@description('The URL of the Music API backend service')
param musicApiUrl string

@description('Backend protocol')
param protocol string = 'http'

@description('Additional backend properties')
param additionalProperties object = {}

// Reference to existing API Management service
resource apiManagement 'Microsoft.ApiManagement/service@2023-05-01-preview' existing = {
  name: apiManagementName
}

// Music API Backend
resource musicApiBackend 'Microsoft.ApiManagement/service/backends@2023-05-01-preview' = {
  parent: apiManagement
  name: 'music-api-backend'
  properties: union({
    protocol: protocol
    url: musicApiUrl
    description: 'Music API Backend for managing music content'
    title: 'Music API Backend'
  }, additionalProperties)
}

// Outputs
output musicApiBackendId string = musicApiBackend.id
output musicApiBackendName string = musicApiBackend.name
output musicApiBackendUrl string = musicApiUrl
