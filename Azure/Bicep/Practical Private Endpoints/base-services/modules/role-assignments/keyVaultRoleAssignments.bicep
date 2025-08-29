// Key Vault RBAC Role Assignment Module
// This module assigns multiple RBAC roles to managed identities for Key Vault access
// Deployed at the target resource group scope where the Key Vault exists
// Uses Azure RBAC instead of legacy access policies

targetScope = 'resourceGroup'

param keyVaultName string
param roleAssignments array

// Available Key Vault RBAC roles:
// - Key Vault Reader: '21090545-7ca7-4776-b22c-e363652d74d2' (read metadata only)
// - Key Vault Secrets User: '4633458b-17de-408a-b874-0445c86b69e6' (read secrets only)
// - Key Vault Secrets Officer: 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7' (read/write secrets)
// - Key Vault Administrator: '00482a5a-887f-4fb3-b363-3b7fe8e74483' (full access)

// Reference to existing Key Vault in current resource group
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

// RBAC Role Assignments - much cleaner than access policies
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for (assignment, index) in roleAssignments: {
  name: guid(keyVault.id, assignment.principalId, assignment.roleDefinitionId)
  scope: keyVault
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', assignment.roleDefinitionId)
    principalId: assignment.principalId
    principalType: assignment.?principalType ?? 'ServicePrincipal'
  }
}]

// Outputs
output roleAssignmentIds array = [for i in range(0, length(roleAssignments)): roleAssignment[i].id]
output keyVaultId string = keyVault.id
output keyVaultName string = keyVault.name
