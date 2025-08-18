param location string
param keyVaultName string
param tenantId string = tenant().tenantId
param enableSoftDelete bool = true
param softDeleteRetentionInDays int = 90
param enablePurgeProtection bool = true
param tags object = {}

// VNet integration configuration
param allowedSubnets array = []

// Role Assignment Parameters
param roleAssignments array = []

// Generate virtual network rules from allowed subnets
var virtualNetworkRules = [for subnetId in allowedSubnets: {
  id: subnetId
}]

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: true
    tenantId: tenantId
    enableSoftDelete: enableSoftDelete
    softDeleteRetentionInDays: softDeleteRetentionInDays
    enablePurgeProtection: enablePurgeProtection
    enableRbacAuthorization: true
    sku: {
      family: 'A'
      name: 'standard'
    }
    networkAcls: {
      defaultAction: length(allowedSubnets) > 0 ? 'Deny' : 'Allow'
      bypass: 'AzureServices'
      virtualNetworkRules: length(allowedSubnets) > 0 ? virtualNetworkRules : []
    }
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

// Sample secrets for demonstration
resource sqlConnectionStringSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'SqlConnectionString'
  properties: {
    value: 'Server=tcp:${keyVaultName}.${environment().suffixes.sqlServerHostname};Initial Catalog=SampleDB;Persist Security Info=False;User ID=sampleuser;Password=SamplePassword123!;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'
  }
}

resource apiKeySecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'ApiKey'
  properties: {
    value: 'sample-api-key-value'
  }
}

output keyVaultId string = keyVault.id
output keyVaultName string = keyVault.name
output keyVaultUri string = keyVault.properties.vaultUri
output keyVaultResourceGroup string = resourceGroup().name

// Key Vault role definition IDs for reference
output keyVaultAdministratorRoleId string = '00482a5a-887f-4fb3-b363-3b7fe8e74483'
output keyVaultSecretsUserRoleId string = '4633458b-17de-408a-b874-0445c86b69e6'
output keyVaultSecretsOfficerRoleId string = 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7'
output keyVaultCertificatesOfficerRoleId string = 'a4417e6f-fecd-4de8-b567-7b0420556985'
output keyVaultCryptoOfficerRoleId string = '14b46e9e-c2b7-41b4-b07b-48a6ebf60603'
