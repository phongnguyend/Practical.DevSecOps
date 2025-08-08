// Reference existing Virtual Network from networking-layer
@description('Resource group of the existing virtual network (from networking-layer)')
param vnetResourceGroup string
@description('Name of the existing virtual network (from networking-layer)')
param vnetName string

resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: vnetName
  scope: resourceGroup(vnetResourceGroup)
}

// Outputs
output vnetId string = vnet.id
output vnetName string = vnet.name
output appGatewaySubnetId string = '${vnet.id}/subnets/AppGatewaySubnet'
output privateEndpointSubnetId string = '${vnet.id}/subnets/PrivateEndpointSubnet'
output testVMSubnetId string = '${vnet.id}/subnets/TestVMSubnet'
output apiManagementSubnetId string = '${vnet.id}/subnets/APIManagementSubnet'
output vnetIntegrationSubnetId string = '${vnet.id}/subnets/VNetIntegrationSubnet'
