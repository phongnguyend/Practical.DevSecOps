// Consolidated Private DNS Zones Module
param enablePrivateEndpoints bool = false
param enableAppConfiguration bool = false
param enableBlobStorage bool = false
param enableCosmosDb bool = false
param enableServiceBus bool = false

// VNet Information
param vnetId string
param vnetName string

// Web App Names for Custom DNS Zone
param customerSiteWebAppName string = ''
param adminSiteWebAppName string = ''
param videoApiWebAppName string = ''
param musicApiWebAppName string = ''
param applicationGatewayPublicIP string = '0.0.0.0'
param tags object = {}

// App Configuration Private DNS Zone Module (conditional)
module appConfigPrivateDnsZone 'appConfigurationPrivateDNSZone.bicep' = if (enableAppConfiguration && enablePrivateEndpoints) {
  name: 'appConfigPrivateDnsZoneDeployment'
  params: {
    vnetId: vnetId
    tags: tags
  }
}

// Blob Storage Private DNS Zone Module (conditional)
module blobStoragePrivateDnsZone 'blobStoragePrivateDNSZone.bicep' = if (enableBlobStorage && enablePrivateEndpoints) {
  name: 'blobStoragePrivateDnsZoneDeployment'
  params: {
    vnetId: vnetId
    vnetName: vnetName
    tags: tags
  }
}

// Cosmos DB Private DNS Zone Module (conditional)
module cosmosPrivateDnsZone 'cosmosPrivateDNSZone.bicep' = if (enableCosmosDb && enablePrivateEndpoints) {
  name: 'cosmosPrivateDnsZoneDeployment'
  params: {
    vnetId: vnetId
    tags: tags
  }
}

// Service Bus Private DNS Zone Module (conditional)
module serviceBusPrivateDnsZone 'serviceBusPrivateDNSZone.bicep' = if (enableServiceBus && enablePrivateEndpoints) {
  name: 'serviceBusPrivateDnsZoneDeployment'
  params: {
    vnetId: vnetId
    tags: tags
  }
}

// App Service Private DNS Zone Module
module appServicePrivateDnsZone 'appServicePrivateDNSZone.bicep' = if (enablePrivateEndpoints) {
  name: 'appServicePrivateDnsZoneDeployment'
  params: {
    vnetId: vnetId
    tags: tags
  }
}

// Custom Private DNS Zone Module
module customPrivateDnsZone 'customPrivateDNSZone.bicep' = if (enablePrivateEndpoints) {
  name: 'customPrivateDnsZoneDeployment'
  params: {
    location: 'global'
    vnetId: vnetId
    vnetName: vnetName
    customerSiteWebAppName: customerSiteWebAppName
    adminSiteWebAppName: adminSiteWebAppName
    videoApiWebAppName: videoApiWebAppName
    musicApiWebAppName: musicApiWebAppName
    applicationGatewayPublicIP: applicationGatewayPublicIP
    tags: tags
  }
}

// Outputs - DNS Zone IDs for consumption by other modules
output appConfigPrivateDnsZoneId string = (enableAppConfiguration && enablePrivateEndpoints) ? appConfigPrivateDnsZone!.outputs.privateDnsZoneId : ''
output blobStoragePrivateDnsZoneId string = (enableBlobStorage && enablePrivateEndpoints) ? blobStoragePrivateDnsZone!.outputs.privateDnsZoneId : ''
output cosmosPrivateDnsZoneId string = (enableCosmosDb && enablePrivateEndpoints) ? cosmosPrivateDnsZone!.outputs.privateDnsZoneId : ''
output serviceBusPrivateDnsZoneId string = (enableServiceBus && enablePrivateEndpoints) ? serviceBusPrivateDnsZone!.outputs.privateDnsZoneId : ''
output appServicePrivateDnsZoneId string = enablePrivateEndpoints ? appServicePrivateDnsZone!.outputs.privateDnsZoneId : ''
output customPrivateDnsZoneId string = enablePrivateEndpoints ? customPrivateDnsZone!.outputs.customPrivateDnsZoneId : ''

// Additional outputs from custom private DNS zone
output internalDnsNames array = enablePrivateEndpoints ? customPrivateDnsZone!.outputs.internalDnsNames : []
