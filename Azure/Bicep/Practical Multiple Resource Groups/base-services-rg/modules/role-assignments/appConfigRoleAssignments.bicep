// Role Assignment Module for App Configuration Access
// This module creates multiple role assignments to grant App Configuration access
// to managed identities - deployed at the target resource group scope

targetScope = 'resourceGroup'

param appConfigurationName string
param roleAssignments array

// Reference to existing App Configuration in current resource group
resource appConfig 'Microsoft.AppConfiguration/configurationStores@2023-03-01' existing = {
  name: appConfigurationName
}

// Role Assignments - using a deterministic but unique name for each
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for (assignment, index) in roleAssignments: {
  name: guid(appConfig.id, assignment.principalId, assignment.roleDefinitionId)
  scope: appConfig
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', assignment.roleDefinitionId)
    principalId: assignment.principalId
    principalType: assignment.?principalType ?? 'ServicePrincipal'
  }
}]

// Outputs
output roleAssignmentIds array = [for i in range(0, length(roleAssignments)): roleAssignment[i].id]
output roleAssignmentNames array = [for i in range(0, length(roleAssignments)): roleAssignment[i].name]
output appConfigId string = appConfig.id
