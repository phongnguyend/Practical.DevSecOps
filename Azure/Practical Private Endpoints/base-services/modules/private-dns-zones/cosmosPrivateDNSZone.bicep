// Private DNS Zone for Azure Cosmos DB
param vnetId string

// Tags
param tags object = {}

// Private DNS Zone for Cosmos DB
resource cosmosPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.documents.azure.com'
  location: 'global'
  tags: tags
  properties: {}
}

// Link Private DNS Zone to Virtual Network
resource cosmosPrivateDnsZoneVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: cosmosPrivateDnsZone
  name: 'cosmos-dns-vnet-link'
  location: 'global'
  tags: tags
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

// Outputs
output privateDnsZoneId string = cosmosPrivateDnsZone.id
output privateDnsZoneName string = cosmosPrivateDnsZone.name
