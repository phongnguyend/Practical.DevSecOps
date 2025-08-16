// Virtual Network Module
param location string
param vnetName string
param vnetAddressPrefix string = '10.0.0.0/16'
param apiManagementNSGId string
param tags object = {}

// Virtual Network with Application Gateway and Private Endpoint subnets
resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: 'AppGatewaySubnet'
        properties: {
          addressPrefix: '10.0.1.0/24'
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'PrivateEndpointSubnet'
        properties: {
          addressPrefix: '10.0.2.0/24'
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'TestVMSubnet'
        properties: {
          addressPrefix: '10.0.3.0/24'
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'APIManagementSubnet'
        properties: {
          addressPrefix: '10.0.4.0/24'
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Disabled'
          networkSecurityGroup: {
            id: apiManagementNSGId
          }
        }
      }
      {
        name: 'VNetIntegrationSubnet'
        properties: {
          addressPrefix: '10.0.5.0/24'
          delegations: [
            {
              name: 'Microsoft.Web.serverFarms'
              properties: {
                serviceName: 'Microsoft.Web/serverFarms'
              }
            }
          ]
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
            }
            {
              service: 'Microsoft.Sql'
            }
            {
              service: 'Microsoft.KeyVault'
            }
            {
              service: 'Microsoft.DocumentDB'
            }
            {
              service: 'Microsoft.ServiceBus'
            }
          ]
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
  }
  tags: tags
}

// Outputs
output vnetId string = vnet.id
output vnetName string = vnet.name
output appGatewaySubnetId string = '${vnet.id}/subnets/AppGatewaySubnet'
output privateEndpointSubnetId string = '${vnet.id}/subnets/PrivateEndpointSubnet'
output testVMSubnetId string = '${vnet.id}/subnets/TestVMSubnet'
output apiManagementSubnetId string = '${vnet.id}/subnets/APIManagementSubnet'
output vnetIntegrationSubnetId string = '${vnet.id}/subnets/VNetIntegrationSubnet'
