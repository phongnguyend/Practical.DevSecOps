// Storage Account Role Assignment Module
// This module assigns multiple RBAC roles to managed identities for Storage Account access
// Deployed at the storage account resource scope

targetScope = 'resourceGroup'

param storageAccountName string
param roleAssignments array

// Available Storage RBAC roles:
// - Storage Blob Data Reader: '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1'
// - Storage Blob Data Contributor: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
// - Storage Blob Data Owner: 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b'

// Reference to existing Storage Account
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageAccountName
}

// RBAC Role Assignments scoped to the Storage Account
resource storageRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for (assignment, index) in roleAssignments: {
  name: guid(storageAccount.id, assignment.principalId, assignment.roleDefinitionId)
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', assignment.roleDefinitionId)
    principalId: assignment.principalId
    principalType: assignment.?principalType ?? 'ServicePrincipal'
  }
}]

// Outputs
output roleAssignmentIds array = [for i in range(0, length(roleAssignments)): storageRoleAssignment[i].id]
output roleAssignmentNames array = [for i in range(0, length(roleAssignments)): storageRoleAssignment[i].name]
output storageAccountId string = storageAccount.id
