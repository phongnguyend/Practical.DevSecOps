// Key Vault Private DNS Zone Module
param vnetId string
param zoneName string = 'privatelink.vaultcore.azure.net'
param tags object = {}

// Private DNS Zone for Key Vault
resource keyVaultPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: zoneName
  location: 'global'
  properties: {}
  tags: tags
}

// Virtual Network Link
resource keyVaultVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${zoneName}-vnet-link'
  parent: keyVaultPrivateDnsZone
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

// Outputs
output privateDnsZoneId string = keyVaultPrivateDnsZone.id
output privateDnsZoneName string = keyVaultPrivateDnsZone.name
