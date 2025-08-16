param location string
param keyVaultName string
param tenantId string = tenant().tenantId
param enableSoftDelete bool = true
param softDeleteRetentionInDays int = 90
param enablePurgeProtection bool = true
param tags object = {}

// VNet integration configuration
param allowedSubnets array = []

// Access policies for different services with different permissions
param accessPolicies array = []

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
    enableRbacAuthorization: false
    accessPolicies: accessPolicies
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
