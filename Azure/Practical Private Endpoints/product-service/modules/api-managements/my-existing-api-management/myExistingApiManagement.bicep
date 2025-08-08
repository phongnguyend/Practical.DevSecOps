// Product Service API Management Integration Module
// This module integrates the Product API with the EXISTING API Management service from base-services
// NOTE: This does NOT create a new API Management service - it references and extends an existing one

@description('The name of the EXISTING API Management service from base-services')
param apiManagementName string

@description('The URL of the Product API backend service')
param productApiUrl string

@description('API path for the Product API')
param apiPath string = 'products'

@description('API protocols')
param protocols array = ['https']

@description('Whether subscription is required for the Product API')
param subscriptionRequired bool = false

@description('Backend protocol')
param backendProtocol string = 'http'

// Reference the existing API Management service (deployed by base-services)
resource existingApiManagement 'Microsoft.ApiManagement/service@2023-05-01-preview' existing = {
  name: apiManagementName
}

// Deploy Product API components to existing API Management
module productApiIntegration 'product-api/productApi.bicep' = {
  name: 'productApiIntegration'
  params: {
    apiManagementName: apiManagementName
    productApiUrl: productApiUrl
    apiPath: apiPath
    protocols: protocols
    subscriptionRequired: subscriptionRequired
    backendProtocol: backendProtocol
  }
}

// Outputs
output productApiName string = productApiIntegration.outputs.productApiName
output productApiId string = productApiIntegration.outputs.productApiId
output productApiUrl string = productApiIntegration.outputs.productApiUrl
output productApiDisplayName string = productApiIntegration.outputs.productApiDisplayName
output productApiBackendId string = productApiIntegration.outputs.productApiBackendId
output productApiBackendName string = productApiIntegration.outputs.productApiBackendName

// API Management Gateway URL for Product API (using existing APIM from base-services)
output productApiGatewayUrl string = 'https://${apiManagementName}.azure-api.net/${apiPath}'

// Existing API Management service information
output existingApiManagementId string = existingApiManagement.id
output existingApiManagementName string = existingApiManagement.name
output existingApiManagementGatewayUrl string = existingApiManagement.properties.gatewayUrl
