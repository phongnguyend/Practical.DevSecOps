param location string
param keyVaultName string
param productApiPrincipalId string
param productFunctionPrincipalId string = ''
param tags object = {}

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
    enableRbacAuthorization: false
    accessPolicies: concat(
      [
        // Product API Access Policy
        {
          tenantId: tenant().tenantId
          objectId: productApiPrincipalId
          permissions: {
            keys: ['get', 'list']
            secrets: ['get', 'list']
            certificates: ['get', 'list']
          }
        }
      ],
      // Product Function App Access Policy (if enabled)
      productFunctionPrincipalId != '' ? [
        {
          tenantId: tenant().tenantId
          objectId: productFunctionPrincipalId
          permissions: {
            keys: ['get', 'list']
            secrets: ['get', 'list']
            certificates: ['get', 'list']
          }
        }
      ] : []
    )
  }
  tags: tags
}

// Outputs
output keyVaultId string = keyVault.id
output keyVaultName string = keyVault.name
output keyVaultUri string = keyVault.properties.vaultUri
