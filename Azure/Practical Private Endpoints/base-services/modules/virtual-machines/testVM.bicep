// Test VM Module
param location string
param vmName string
param vmSize string = 'Standard_B1s'
param adminUsername string
@secure()
param adminPassword string
param subnetId string
param includePublicIP bool = true
param computerName string = 'testvm'
param tags object = {}

// Public IP for Test VM (optional)
resource testVMPublicIP 'Microsoft.Network/publicIPAddresses@2023-09-01' = if (includePublicIP) {
  name: '${vmName}-pip'
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
  tags: tags
}

// Network Security Group for Test VM
resource testVMNSG 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: '${vmName}-nsg'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowRDPInbound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 1000
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowHTTPOutbound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 1000
          direction: 'Outbound'
        }
      }
      {
        name: 'AllowHTTPSOutbound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 1010
          direction: 'Outbound'
        }
      }
    ]
  }
  tags: tags
}

// Network Interface for Test VM
resource testVMNIC 'Microsoft.Network/networkInterfaces@2023-09-01' = {
  name: '${vmName}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetId
          }
          publicIPAddress: includePublicIP ? {
            id: testVMPublicIP.id
          } : null
        }
      }
    ]
    networkSecurityGroup: {
      id: testVMNSG.id
    }
  }
  tags: tags
}

// Windows Virtual Machine for testing
resource testVM 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: computerName
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        enableAutomaticUpdates: true
        provisionVMAgent: true
      }
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-datacenter'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: testVMNIC.id
        }
      ]
    }
  }
  tags: tags
}

// Outputs
output vmId string = testVM.id
output vmName string = testVM.name
output vmPrivateIP string = testVMNIC.properties.ipConfigurations[0].properties.privateIPAddress
output vmNSGId string = testVMNSG.id
output hasPublicIP bool = includePublicIP
output vmPublicIPResourceId string = includePublicIP ? testVMPublicIP.id : ''
