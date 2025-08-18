param location string
param keyVaultName string
param tags object = {}

// Role Assignment Parameters
param roleAssignments array = []

// Key Vault
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: tenant().tenantId
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
    enablePurgeProtection: false
    enableRbacAuthorization: true
  }
  tags: tags
}

// Role Assignments
resource keyVaultRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for (assignment, index) in roleAssignments: if (!empty(assignment.principalId)) {
  name: guid(keyVault.id, assignment.principalId, assignment.roleDefinitionId)
  scope: keyVault
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', assignment.roleDefinitionId)
    principalId: assignment.principalId
    principalType: 'ServicePrincipal'
  }
}]

// Outputs
output keyVaultId string = keyVault.id
output keyVaultName string = keyVault.name
output keyVaultUri string = keyVault.properties.vaultUri

// Key Vault role definition IDs for reference
output keyVaultAdministratorRoleId string = '00482a5a-887f-4fb3-b363-3b7fe8e74483'
output keyVaultSecretsUserRoleId string = '4633458b-17de-408a-b874-0445c86b69e6'
output keyVaultSecretsOfficerRoleId string = 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7'
output keyVaultCertificatesOfficerRoleId string = 'a4417e6f-fecd-4de8-b567-7b0420556985'
output keyVaultCryptoOfficerRoleId string = '14b46e9e-c2b7-41b4-b07b-48a6ebf60603'
