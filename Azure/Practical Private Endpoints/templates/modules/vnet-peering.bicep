// vnet-peering.bicep
// Template for creating VNet peering between two Virtual Networks
// Use this to connect new VNets to existing infrastructure
// Note: This template should be deployed in the same resource group as the local VNet

@description('Name of the local VNet (in current resource group)')
param localVnetName string

@description('Name of the remote VNet')
param remoteVnetName string

@description('Full resource ID of the remote VNet')
param remoteVnetId string

@description('Whether to allow virtual network access')
param allowVirtualNetworkAccess bool = true

@description('Whether to allow forwarded traffic')
param allowForwardedTraffic bool = false

@description('Whether to allow gateway transit')
param allowGatewayTransit bool = false

@description('Whether to use remote gateways')
param useRemoteGateways bool = false

// Reference to local VNet
resource localVnet 'Microsoft.Network/virtualNetworks@2023-05-01' existing = {
  name: localVnetName
}

// Peering from local to remote
resource localToRemotePeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-05-01' = {
  parent: localVnet
  name: '${localVnetName}-to-${remoteVnetName}'
  properties: {
    allowVirtualNetworkAccess: allowVirtualNetworkAccess
    allowForwardedTraffic: allowForwardedTraffic
    allowGatewayTransit: allowGatewayTransit
    useRemoteGateways: useRemoteGateways
    remoteVirtualNetwork: {
      id: remoteVnetId
    }
  }
}

// Outputs
output peeringName string = localToRemotePeering.name
output peeringId string = localToRemotePeering.id
output localVnetId string = localVnet.id
output remoteVnetId string = remoteVnetId
output peeringState string = localToRemotePeering.properties.peeringState
