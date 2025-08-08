// Video API Orchestrator Module
// This module orchestrates all Video API components (backend, definition, operations, policies)

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

@description('Backend protocol')
param backendProtocol string = 'http'

@description('Additional backend properties')
param additionalBackendProperties object = {}

@description('Additional API properties')
param additionalApiProperties object = {}

// Deploy Video API Backend
module videoApiBackend 'videoApiBackend.bicep' = {
  name: 'video-api-backend'
  params: {
    apiManagementName: apiManagementName
    videoApiUrl: videoApiUrl
    protocol: backendProtocol
    additionalProperties: additionalBackendProperties
  }
}

// Deploy Video API Definition
module videoApiDefinition 'videoApiDefinition.bicep' = {
  name: 'video-api-definition'
  params: {
    apiManagementName: apiManagementName
    videoApiUrl: videoApiUrl
    apiPath: apiPath
    protocols: protocols
    subscriptionRequired: subscriptionRequired
    additionalProperties: additionalApiProperties
  }
  dependsOn: [
    videoApiBackend
  ]
}

// Deploy Video API Operations
module videoApiOperations 'videoApiOperations.bicep' = {
  name: 'video-api-operations'
  params: {
    apiManagementName: apiManagementName
    videoApiName: videoApiDefinition.outputs.videoApiName
  }
}

// Deploy Video API Policies
module videoApiPolicies 'videoApiPolicies.bicep' = {
  name: 'video-api-policies'
  params: {
    apiManagementName: apiManagementName
    videoApiName: videoApiDefinition.outputs.videoApiName
  }
}

// Outputs
output videoApiName string = videoApiDefinition.outputs.videoApiName
output videoApiId string = videoApiDefinition.outputs.videoApiId
output videoApiUrl string = videoApiDefinition.outputs.videoApiUrl
output videoApiDisplayName string = videoApiDefinition.outputs.videoApiDisplayName
output videoApiBackendId string = videoApiBackend.outputs.videoApiBackendId
output videoApiBackendName string = videoApiBackend.outputs.videoApiBackendName
