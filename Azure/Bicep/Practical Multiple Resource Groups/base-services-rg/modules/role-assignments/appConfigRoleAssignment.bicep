// Role Assignment Module for App Configuration Access
// This module creates a role assignment to grant App Configuration Data Reader access
// to a managed identity - deployed at the target resource group scope

targetScope = 'resourceGroup'

param appConfigurationName string
param principalId string
param principalType string = 'ServicePrincipal'
param roleDefinitionId string = '516239f1-63e1-4d78-a4de-a74fb236a071' // App Configuration Data Reader

// Reference to existing App Configuration in current resource group
resource appConfig 'Microsoft.AppConfiguration/configurationStores@2023-03-01' existing = {
  name: appConfigurationName
}

// Role Assignment - using a deterministic but unique name
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(appConfig.id, principalId, roleDefinitionId)
  scope: appConfig
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
    principalId: principalId
    principalType: principalType
  }
}

// Outputs
output roleAssignmentId string = roleAssignment.id
output roleAssignmentName string = roleAssignment.name
output appConfigId string = appConfig.id
