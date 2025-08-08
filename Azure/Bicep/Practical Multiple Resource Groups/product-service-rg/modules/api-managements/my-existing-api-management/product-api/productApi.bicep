// Product API Orchestrator Module
// This module orchestrates all Product API components (backend, definition, operations, policies)

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

@description('Backend protocol')
param backendProtocol string = 'http'

@description('Additional backend properties')
param additionalBackendProperties object = {}

@description('Additional API properties')
param additionalApiProperties object = {}

// Deploy Product API Backend
module productApiBackend 'productApiBackend.bicep' = {
  name: 'product-api-backend'
  params: {
    apiManagementName: apiManagementName
    productApiUrl: productApiUrl
    protocol: backendProtocol
    additionalProperties: additionalBackendProperties
  }
}

// Deploy Product API Definition
module productApiDefinition 'productApiDefinition.bicep' = {
  name: 'product-api-definition'
  params: {
    apiManagementName: apiManagementName
    productApiUrl: productApiUrl
    apiPath: apiPath
    protocols: protocols
    subscriptionRequired: subscriptionRequired
    additionalProperties: additionalApiProperties
  }
  dependsOn: [
    productApiBackend
  ]
}

// Deploy Product API Operations
module productApiOperations 'productApiOperations.bicep' = {
  name: 'product-api-operations'
  params: {
    apiManagementName: apiManagementName
    productApiName: productApiDefinition.outputs.productApiName
  }
}

// Deploy Product API Policies
module productApiPolicies 'productApiPolicies.bicep' = {
  name: 'product-api-policies'
  params: {
    apiManagementName: apiManagementName
    productApiName: productApiDefinition.outputs.productApiName
  }
}

// Outputs
output productApiName string = productApiDefinition.outputs.productApiName
output productApiId string = productApiDefinition.outputs.productApiId
output productApiUrl string = productApiDefinition.outputs.productApiUrl
output productApiDisplayName string = productApiDefinition.outputs.productApiDisplayName
output productApiBackendId string = productApiBackend.outputs.productApiBackendId
output productApiBackendName string = productApiBackend.outputs.productApiBackendName
