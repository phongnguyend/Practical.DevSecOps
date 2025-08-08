// Product API Definition Module
// This module creates the Product API definition for the API Management service

@description('The name of the API Management service')
param apiManagementName string

@description('The URL of the Product API backend service')
param productApiUrl string

@description('API path')
param apiPath string = 'products'

@description('API protocols')
param protocols array = ['https']

@description('Subscription required')
param subscriptionRequired bool = false

@description('Additional API properties')
param additionalProperties object = {}

// Reference to existing API Management service (from base-services)
resource apiManagement 'Microsoft.ApiManagement/service@2023-05-01-preview' existing = {
  name: apiManagementName
}

// Product API Definition
resource productApi 'Microsoft.ApiManagement/service/apis@2023-05-01-preview' = {
  parent: apiManagement
  name: 'product-api'
  properties: union({
    displayName: 'Product API'
    description: 'API for managing product catalog, inventory, and categories'
    path: apiPath
    protocols: protocols
    subscriptionRequired: subscriptionRequired
    serviceUrl: productApiUrl
  }, additionalProperties)
}

// Outputs
output productApiName string = productApi.name
output productApiId string = productApi.id
output productApiUrl string = 'https://${apiManagementName}.azure-api.net/${apiPath}'
output productApiDisplayName string = productApi.properties.displayName
