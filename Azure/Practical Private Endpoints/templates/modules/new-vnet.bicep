// new-vnet.bicep
// Template for creating a new Virtual Network
// Use this when you need separate network environments or regions

@description('Name of the new Virtual Network')
param vnetName string

@description('Address space for the VNet (e.g., 10.1.0.0/16)')
param vnetAddressSpace string

@description('Location for the VNet')
param location string = resourceGroup().location

@description('Subnets to create in the VNet')
param subnets array = [
  {
    name: 'default'
    addressPrefix: '10.1.1.0/24'
    serviceEndpoints: []
    delegations: []
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
]

@description('Whether to create a network security group for each subnet')
param createNSGs bool = true

@description('NSG rules to apply to subnets (if createNSGs is true)')
param nsgRules array = [
  {
    name: 'AllowHTTPS'
    priority: 100
    direction: 'Inbound'
    access: 'Allow'
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '443'
    sourceAddressPrefix: '*'
    destinationAddressPrefix: '*'
  }
  {
    name: 'AllowHTTP'
    priority: 110
    direction: 'Inbound'
    access: 'Allow'
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '80'
    sourceAddressPrefix: '*'
    destinationAddressPrefix: '*'
  }
]

@description('DNS servers for the VNet (empty array for Azure default)')
param dnsServers array = []

@description('Whether to enable DDoS protection')
param enableDdosProtection bool = false

@description('DDoS protection plan resource ID (required if enableDdosProtection is true)')
param ddosProtectionPlanId string = ''

// Create Network Security Groups if requested
resource networkSecurityGroups 'Microsoft.Network/networkSecurityGroups@2023-05-01' = [for subnet in subnets: if (createNSGs) {
  name: '${vnetName}-${subnet.name}-nsg'
  location: location
  properties: {
    securityRules: [for rule in nsgRules: {
      name: rule.name
      properties: {
        priority: rule.priority
        direction: rule.direction
        access: rule.access
        protocol: rule.protocol
        sourcePortRange: rule.sourcePortRange
        destinationPortRange: rule.destinationPortRange
        sourceAddressPrefix: rule.sourceAddressPrefix
        destinationAddressPrefix: rule.destinationAddressPrefix
      }
    }]
  }
}]

// Create the Virtual Network
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [vnetAddressSpace]
    }
    dhcpOptions: empty(dnsServers) ? null : {
      dnsServers: dnsServers
    }
    enableDdosProtection: enableDdosProtection
    ddosProtectionPlan: enableDdosProtection && !empty(ddosProtectionPlanId) ? {
      id: ddosProtectionPlanId
    } : null
    subnets: [for (subnet, index) in subnets: {
      name: subnet.name
      properties: {
        addressPrefix: subnet.addressPrefix
        serviceEndpoints: subnet.serviceEndpoints
        delegations: subnet.delegations
        privateEndpointNetworkPolicies: subnet.privateEndpointNetworkPolicies
        privateLinkServiceNetworkPolicies: subnet.privateLinkServiceNetworkPolicies
        networkSecurityGroup: createNSGs ? {
          id: networkSecurityGroups[index].id
        } : null
      }
    }]
  }
}

// Outputs
output vnetId string = virtualNetwork.id
output vnetName string = virtualNetwork.name
output vnetAddressSpace string = vnetAddressSpace
output subnetIds array = [for (subnet, index) in subnets: {
  name: subnet.name
  id: virtualNetwork.properties.subnets[index].id
  addressPrefix: subnet.addressPrefix
}]
output nsgIds array = [for (subnet, index) in subnets: createNSGs ? {
  name: subnet.name
  nsgId: networkSecurityGroups[index].id
  nsgName: networkSecurityGroups[index].name
} : {
  name: subnet.name
  nsgId: ''
  nsgName: ''
}]
