// Product API Backend Module
// This module creates the Product API backend for the API Management service

@description('The name of the API Management service')
param apiManagementName string

@description('The URL of the Product API backend service')
param productApiUrl string

@description('Backend protocol')
param protocol string = 'http'

@description('Additional backend properties')
param additionalProperties object = {}

// Reference to existing API Management service (from base-services)
resource apiManagement 'Microsoft.ApiManagement/service@2023-05-01-preview' existing = {
  name: apiManagementName
}

// Product API Backend
resource productApiBackend 'Microsoft.ApiManagement/service/backends@2023-05-01-preview' = {
  parent: apiManagement
  name: 'product-api-backend'
  properties: union({
    protocol: protocol
    url: productApiUrl
    description: 'Product API Backend for managing product catalog and inventory'
    title: 'Product API Backend'
  }, additionalProperties)
}

// Outputs
output productApiBackendId string = productApiBackend.id
output productApiBackendName string = productApiBackend.name
output productApiBackendUrl string = productApiUrl
