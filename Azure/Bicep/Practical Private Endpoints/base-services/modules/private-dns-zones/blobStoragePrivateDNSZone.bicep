// Blob Storage Private DNS Zone Module
param vnetId string
param zoneName string = 'privatelink.blob.${environment().suffixes.storage}'
param vnetName string
param tags object = {}

// Private DNS Zone for Blob Storage
resource blobPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: zoneName
  location: 'global'
  properties: {}
  tags: tags
}

// Virtual Network Link
resource blobVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: blobPrivateDnsZone
  name: '${vnetName}-blob-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

// Outputs
output privateDnsZoneId string = blobPrivateDnsZone.id
output privateDnsZoneName string = blobPrivateDnsZone.name
