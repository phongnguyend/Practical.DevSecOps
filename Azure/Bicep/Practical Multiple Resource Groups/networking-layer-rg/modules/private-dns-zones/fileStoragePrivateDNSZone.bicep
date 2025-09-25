// File Storage Private DNS Zone Module
param vnetId string
param zoneName string = 'privatelink.file.${environment().suffixes.storage}'
param vnetName string
param tags object = {}

// Private DNS Zone for File Storage
resource filePrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: zoneName
  location: 'global'
  properties: {}
  tags: tags
}

// Virtual Network Link
resource fileVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: filePrivateDnsZone
  name: '${vnetName}-file-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

// Outputs
output privateDnsZoneId string = filePrivateDnsZone.id
output privateDnsZoneName string = filePrivateDnsZone.name
