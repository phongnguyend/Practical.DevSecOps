// Table Storage Private DNS Zone Module
param vnetId string
param zoneName string = 'privatelink.table.${environment().suffixes.storage}'
param vnetName string
param tags object = {}

// Private DNS Zone for Table Storage
resource tablePrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: zoneName
  location: 'global'
  properties: {}
  tags: tags
}

// Virtual Network Link
resource tableVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: tablePrivateDnsZone
  name: '${vnetName}-table-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

// Outputs
output privateDnsZoneId string = tablePrivateDnsZone.id
output privateDnsZoneName string = tablePrivateDnsZone.name
