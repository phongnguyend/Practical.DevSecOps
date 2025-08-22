@description('Resource group of the networking-layer deployment')
param privateDnsZonesResourceGroup string

@description('Private DNS Zone Name for App Configuration')
param appConfigPrivateDnsZoneName string = 'privatelink.azconfig.io'

@description('Private DNS Zone Name for Blob Storage')
param blobStoragePrivateDnsZoneName string = 'privatelink.blob.${environment().suffixes.storage}'

@description('Private DNS Zone Name for Cosmos DB')
param cosmosPrivateDnsZoneName string = 'privatelink.documents.azure.com'

@description('Private DNS Zone Name for Service Bus')
param serviceBusPrivateDnsZoneName string = 'privatelink.servicebus.windows.net'

@description('Private DNS Zone Name for App Service')
param appServicePrivateDnsZoneName string = 'privatelink.azurewebsites.net'

// Construct Private DNS Zone Resource IDs
var appConfigPrivateDnsZoneId = resourceId(privateDnsZonesResourceGroup, 'Microsoft.Network/privateDnsZones', appConfigPrivateDnsZoneName)
var blobStoragePrivateDnsZoneId = resourceId(privateDnsZonesResourceGroup, 'Microsoft.Network/privateDnsZones', blobStoragePrivateDnsZoneName)
var cosmosPrivateDnsZoneId = resourceId(privateDnsZonesResourceGroup, 'Microsoft.Network/privateDnsZones', cosmosPrivateDnsZoneName)
var serviceBusPrivateDnsZoneId = resourceId(privateDnsZonesResourceGroup, 'Microsoft.Network/privateDnsZones', serviceBusPrivateDnsZoneName)
var appServicePrivateDnsZoneId = resourceId(privateDnsZonesResourceGroup, 'Microsoft.Network/privateDnsZones', appServicePrivateDnsZoneName)

// Outputs
@description('Private DNS Zone ID for App Configuration')
output appConfigPrivateDnsZoneId string = appConfigPrivateDnsZoneId

@description('Private DNS Zone ID for Blob Storage')
output blobStoragePrivateDnsZoneId string = blobStoragePrivateDnsZoneId

@description('Private DNS Zone ID for Cosmos DB')
output cosmosPrivateDnsZoneId string = cosmosPrivateDnsZoneId

@description('Private DNS Zone ID for Service Bus')
output serviceBusPrivateDnsZoneId string = serviceBusPrivateDnsZoneId

@description('Private DNS Zone ID for App Service')
output appServicePrivateDnsZoneId string = appServicePrivateDnsZoneId
