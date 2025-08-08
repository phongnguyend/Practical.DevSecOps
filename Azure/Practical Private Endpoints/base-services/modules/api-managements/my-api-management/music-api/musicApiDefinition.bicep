// Music API Definition Module
// This module creates the Music API definition for the API Management service

@description('The name of the API Management service')
param apiManagementName string

@description('The URL of the Music API backend service')
param musicApiUrl string

@description('API path')
param apiPath string = 'music'

@description('API protocols')
param protocols array = ['https']

@description('Subscription required')
param subscriptionRequired bool = false

@description('Additional API properties')
param additionalProperties object = {}

// Reference to existing API Management service
resource apiManagement 'Microsoft.ApiManagement/service@2023-05-01-preview' existing = {
  name: apiManagementName
}

// Music API Definition
resource musicApi 'Microsoft.ApiManagement/service/apis@2023-05-01-preview' = {
  parent: apiManagement
  name: 'music-api'
  properties: union({
    displayName: 'Music API'
    description: 'API for managing music content'
    path: apiPath
    protocols: protocols
    subscriptionRequired: subscriptionRequired
    serviceUrl: musicApiUrl
  }, additionalProperties)
}

// Outputs
output musicApiName string = musicApi.name
output musicApiId string = musicApi.id
output musicApiUrl string = 'https://${apiManagementName}.azure-api.net/${apiPath}'
output musicApiDisplayName string = musicApi.properties.displayName
