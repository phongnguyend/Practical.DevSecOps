// App Configuration Private DNS Zone Module
param vnetId string
param zoneName string = 'privatelink.azconfig.io'
param tags object = {}

// Private DNS Zone for App Configuration
resource appConfigPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: zoneName
  location: 'global'
  properties: {}
  tags: tags
}

// Virtual Network Link
resource appConfigVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${zoneName}-vnet-link'
  parent: appConfigPrivateDnsZone
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

// Outputs
output privateDnsZoneId string = appConfigPrivateDnsZone.id
output privateDnsZoneName string = appConfigPrivateDnsZone.name
