// Music API Orchestrator Module
// This module orchestrates all Music API components (backend, definition, operations, policies)

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

@description('Backend protocol')
param backendProtocol string = 'http'

@description('Additional backend properties')
param additionalBackendProperties object = {}

@description('Additional API properties')
param additionalApiProperties object = {}

// Deploy Music API Backend
module musicApiBackend 'musicApiBackend.bicep' = {
  name: 'music-api-backend'
  params: {
    apiManagementName: apiManagementName
    musicApiUrl: musicApiUrl
    protocol: backendProtocol
    additionalProperties: additionalBackendProperties
  }
}

// Deploy Music API Definition
module musicApiDefinition 'musicApiDefinition.bicep' = {
  name: 'music-api-definition'
  params: {
    apiManagementName: apiManagementName
    musicApiUrl: musicApiUrl
    apiPath: apiPath
    protocols: protocols
    subscriptionRequired: subscriptionRequired
    additionalProperties: additionalApiProperties
  }
  dependsOn: [
    musicApiBackend
  ]
}

// Deploy Music API Operations
module musicApiOperations 'musicApiOperations.bicep' = {
  name: 'music-api-operations'
  params: {
    apiManagementName: apiManagementName
    musicApiName: musicApiDefinition.outputs.musicApiName
  }
}

// Deploy Music API Policies
module musicApiPolicies 'musicApiPolicies.bicep' = {
  name: 'music-api-policies'
  params: {
    apiManagementName: apiManagementName
    musicApiName: musicApiDefinition.outputs.musicApiName
  }
}

// Outputs
output musicApiName string = musicApiDefinition.outputs.musicApiName
output musicApiId string = musicApiDefinition.outputs.musicApiId
output musicApiUrl string = musicApiDefinition.outputs.musicApiUrl
output musicApiDisplayName string = musicApiDefinition.outputs.musicApiDisplayName
output musicApiBackendId string = musicApiBackend.outputs.musicApiBackendId
output musicApiBackendName string = musicApiBackend.outputs.musicApiBackendName
