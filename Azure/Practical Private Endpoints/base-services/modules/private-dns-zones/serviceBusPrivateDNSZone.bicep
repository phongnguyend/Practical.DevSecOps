// Service Bus Private DNS Zone Module
param vnetId string

// Private DNS Zone for Service Bus
resource serviceBusPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.servicebus.windows.net'
  location: 'global'
  properties: {}
}

// Virtual Network Link
resource vnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: serviceBusPrivateDnsZone
  name: 'vnet-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

// Outputs
output privateDnsZoneId string = serviceBusPrivateDnsZone.id
output privateDnsZoneName string = serviceBusPrivateDnsZone.name
