// new-subnet.bicep
// Template for adding a new subnet to existing VNet
// Use this when you need additional network isolation or dedicated subnets

@description('Name of the new subnet')
param subnetName string

@description('Address prefix for the new subnet (e.g., 10.0.3.0/24)')
param subnetAddressPrefix string

@description('Name of the existing VNet')
param existingVnetName string = 'PracticalPrivateEndpoints-vnet'

@description('Whether to enable private endpoint network policies')
param enablePrivateEndpointNetworkPolicies bool = false

@description('Whether to enable private link service network policies')
param enablePrivateLinkServiceNetworkPolicies bool = false

@description('Service endpoints to enable on the subnet')
param serviceEndpoints array = []

@description('Delegations for the subnet (e.g., for App Service, ACI, etc.)')
param delegations array = []

// Reference to existing VNet
resource existingVnet 'Microsoft.Network/virtualNetworks@2023-05-01' existing = {
  name: existingVnetName
}

// Create the new subnet
resource newSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' = {
  parent: existingVnet
  name: subnetName
  properties: {
    addressPrefix: subnetAddressPrefix
    privateEndpointNetworkPolicies: enablePrivateEndpointNetworkPolicies ? 'Enabled' : 'Disabled'
    privateLinkServiceNetworkPolicies: enablePrivateLinkServiceNetworkPolicies ? 'Enabled' : 'Disabled'
    serviceEndpoints: serviceEndpoints
    delegations: delegations
  }
}

// Outputs
output subnetId string = newSubnet.id
output subnetName string = newSubnet.name
output subnetAddressPrefix string = newSubnet.properties.addressPrefix
output vnetName string = existingVnet.name
