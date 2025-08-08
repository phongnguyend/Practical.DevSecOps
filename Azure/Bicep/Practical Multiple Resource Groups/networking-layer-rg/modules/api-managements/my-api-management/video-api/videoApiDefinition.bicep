// Video API Definition Module
// This module creates the Video API definition for the API Management service

@description('The name of the API Management service')
param apiManagementName string

@description('The URL of the Video API backend service')
param videoApiUrl string

@description('API path')
param apiPath string = 'video'

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

// Video API Definition
resource videoApi 'Microsoft.ApiManagement/service/apis@2023-05-01-preview' = {
  parent: apiManagement
  name: 'video-api'
  properties: union({
    displayName: 'Video API'
    description: 'API for managing video content'
    path: apiPath
    protocols: protocols
    subscriptionRequired: subscriptionRequired
    serviceUrl: videoApiUrl
  }, additionalProperties)
}

// Outputs
output videoApiName string = videoApi.name
output videoApiId string = videoApi.id
output videoApiUrl string = 'https://${apiManagementName}.azure-api.net/${apiPath}'
output videoApiDisplayName string = videoApi.properties.displayName
