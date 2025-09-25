// Queue Storage Private DNS Zone Module
param vnetId string
param zoneName string = 'privatelink.queue.${environment().suffixes.storage}'
param vnetName string
param tags object = {}

// Private DNS Zone for Queue Storage
resource queuePrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: zoneName
  location: 'global'
  properties: {}
  tags: tags
}

// Virtual Network Link
resource queueVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: queuePrivateDnsZone
  name: '${vnetName}-queue-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

// Outputs
output privateDnsZoneId string = queuePrivateDnsZone.id
output privateDnsZoneName string = queuePrivateDnsZone.name
