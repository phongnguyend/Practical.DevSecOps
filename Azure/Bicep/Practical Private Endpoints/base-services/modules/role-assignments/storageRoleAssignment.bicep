// Storage Account Role Assignment Module
// This module assigns RBAC roles to a managed identity for Storage Account access
// Deployed at the storage account resource scope

targetScope = 'resourceGroup'

param storageAccountName string
param principalId string
param principalType string = 'ServicePrincipal'
param roleDefinitionId string = 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b' // Storage Blob Data Owner

// Available Storage RBAC roles:
// - Storage Blob Data Reader: '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1'
// - Storage Blob Data Contributor: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
// - Storage Blob Data Owner: 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b'

// Reference to existing Storage Account
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageAccountName
}

// RBAC Role Assignment scoped to the Storage Account
resource storageRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccount.id, principalId, roleDefinitionId)
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
    principalId: principalId
    principalType: principalType
  }
}

// Outputs
output roleAssignmentId string = storageRoleAssignment.id
output roleAssignmentName string = storageRoleAssignment.name
output storageAccountId string = storageAccount.id
