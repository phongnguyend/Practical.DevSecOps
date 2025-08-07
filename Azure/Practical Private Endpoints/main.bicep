param location string = 'southeastasia'
param resourceGroupName string = 'PracticalPrivateEndpoints'
param sqlServerName string = 'PracticalPrivateEndpoints'
param adminUsername string = 'PracticalPrivateEndpoints'
@secure()
param adminPassword string = 'sqladmin123!@#'
param appServicePlanName string = 'PracticalPrivateEndpoints'
param vnetName string = 'PracticalPrivateEndpoints-vnet'

param webAppNames array = [
  'PracticalPrivateEndpoints-DEV'
  'PracticalPrivateEndpoints-DEV-API'
  'PracticalPrivateEndpoints-QC'
  'PracticalPrivateEndpoints-QC-API'
]

param dbNames array = [
  'PracticalPrivateEndpoints-DEV'
  'PracticalPrivateEndpoints-QC'
]

// Test VM parameters
param vmAdminUsername string = 'testadmin'
@secure()
param vmAdminPassword string = 'TestVM123!@#'

// Virtual Network with Application Gateway and Private Endpoint subnets
resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
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
    ]
  }
}

// SQL Server
resource sqlServer 'Microsoft.Sql/servers@2023-08-01' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: adminUsername
    administratorLoginPassword: adminPassword
    version: '12.0'
  }
}

// Firewall rule to allow Azure services
resource firewallRule 'Microsoft.Sql/servers/firewallRules@2023-08-01' = {
  name: '${sqlServer.name}/AllowAllAzureIPs'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

// SQL Databases
resource sqlDatabases 'Microsoft.Sql/servers/databases@2023-08-01' = [for dbName in dbNames: {
  name: '${sqlServer.name}/${dbName}'
  location: location
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 2147483648
    requestedServiceObjectiveName: 'Basic'
    backupStorageRedundancy: 'Local'
  }
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
  kind: 'v12.0,user'
}]

// Windows App Service Plan (B1)
resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: 'B1'
    tier: 'Basic'
  }
  kind: 'app' // Windows
  properties: {
    reserved: false
  }
}

// Web Apps using .NET 8 on Windows
resource webApps 'Microsoft.Web/sites@2023-01-01' = [for name in webAppNames: {
  name: name
  location: location
  kind: 'app' // Windows
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      windowsFxVersion: 'DOTNET|8.0'
    }
    publicNetworkAccess: endsWith(name, '-API') ? 'Disabled' : 'Enabled'
  }
}]

// Private Endpoints for DEV-API and QC-API web apps only
resource privateEndpointDevApi 'Microsoft.Network/privateEndpoints@2023-09-01' = {
  name: 'PracticalPrivateEndpoints-DEV-API-pe'
  location: location
  properties: {
    subnet: {
      id: '${vnet.id}/subnets/PrivateEndpointSubnet'
    }
    privateLinkServiceConnections: [
      {
        name: 'PracticalPrivateEndpoints-DEV-API-pe-connection'
        properties: {
          privateLinkServiceId: webApps[1].id // DEV-API is at index 1
          groupIds: [
            'sites'
          ]
        }
      }
    ]
  }
}

resource privateEndpointQcApi 'Microsoft.Network/privateEndpoints@2023-09-01' = {
  name: 'PracticalPrivateEndpoints-QC-API-pe'
  location: location
  properties: {
    subnet: {
      id: '${vnet.id}/subnets/PrivateEndpointSubnet'
    }
    privateLinkServiceConnections: [
      {
        name: 'PracticalPrivateEndpoints-QC-API-pe-connection'
        properties: {
          privateLinkServiceId: webApps[3].id // QC-API is at index 3
          groupIds: [
            'sites'
          ]
        }
      }
    ]
  }
}

// Private DNS Zone for Azure Web Apps
resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.azurewebsites.net'
  location: 'global'
}

// Link Private DNS Zone to VNet
resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZone
  name: '${vnetName}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
}

// DNS Records for Private Endpoints
resource privateDnsZoneGroupDevApi 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-09-01' = {
  name: 'devapi-dns-group'
  parent: privateEndpointDevApi
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config'
        properties: {
          privateDnsZoneId: privateDnsZone.id
        }
      }
    ]
  }
}

resource privateDnsZoneGroupQcApi 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-09-01' = {
  name: 'qcapi-dns-group'
  parent: privateEndpointQcApi
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config'
        properties: {
          privateDnsZoneId: privateDnsZone.id
        }
      }
    ]
  }
}

// Custom Private DNS Zone for internal domain
resource customPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'rookies.internal'
  location: 'global'
}

// Link Custom Private DNS Zone to VNet
resource customPrivateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: customPrivateDnsZone
  name: '${vnetName}-custom-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
}

// Custom DNS CNAME Records pointing to private endpoint DNS names
resource devApiCustomDnsRecord 'Microsoft.Network/privateDnsZones/CNAME@2020-06-01' = {
  parent: customPrivateDnsZone
  name: 'dev-api'
  properties: {
    cnameRecord: {
      cname: '${webApps[1].name}.privatelink.azurewebsites.net'
    }
    ttl: 300
  }
  dependsOn: [
    privateDnsZoneGroupDevApi
  ]
}

resource qcApiCustomDnsRecord 'Microsoft.Network/privateDnsZones/CNAME@2020-06-01' = {
  parent: customPrivateDnsZone
  name: 'qc-api'
  properties: {
    cnameRecord: {
      cname: '${webApps[3].name}.privatelink.azurewebsites.net'
    }
    ttl: 300
  }
  dependsOn: [
    privateDnsZoneGroupQcApi
  ]
}

// Additional custom records for web apps pointing to Application Gateway
resource devWebCustomDnsRecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  parent: customPrivateDnsZone
  name: 'dev-web'
  properties: {
    aRecords: [
      {
        ipv4Address: appGatewayPublicIP.properties.ipAddress
      }
    ]
    ttl: 300
  }
}

resource qcWebCustomDnsRecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  parent: customPrivateDnsZone
  name: 'qc-web'
  properties: {
    aRecords: [
      {
        ipv4Address: appGatewayPublicIP.properties.ipAddress
      }
    ]
    ttl: 300
  }
}

// Public IP for Application Gateway
resource appGatewayPublicIP 'Microsoft.Network/publicIPAddresses@2023-09-01' = {
  name: '${vnetName}-appgw-pip'
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

// Application Gateway
resource applicationGateway 'Microsoft.Network/applicationGateways@2023-09-01' = {
  name: '${vnetName}-appgw'
  location: location
  properties: {
    sku: {
      name: 'Standard_v2'
      tier: 'Standard_v2'
      capacity: 2
    }
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfig'
        properties: {
          subnet: {
            id: '${vnet.id}/subnets/AppGatewaySubnet'
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'appGatewayFrontendIP'
        properties: {
          publicIPAddress: {
            id: appGatewayPublicIP.id
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'port_80'
        properties: {
          port: 80
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'devPool'
        properties: {
          backendAddresses: [
            {
              fqdn: '${webApps[0].name}.azurewebsites.net'
            }
          ]
        }
      }
      {
        name: 'devApiPool'
        properties: {
          backendAddresses: [
            {
              fqdn: '${webApps[1].name}.azurewebsites.net'
            }
          ]
        }
      }
      {
        name: 'qcPool'
        properties: {
          backendAddresses: [
            {
              fqdn: '${webApps[2].name}.azurewebsites.net'
            }
          ]
        }
      }
      {
        name: 'qcApiPool'
        properties: {
          backendAddresses: [
            {
              fqdn: '${webApps[3].name}.azurewebsites.net'
            }
          ]
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'appGatewayBackendHttpSettings'
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: true
          requestTimeout: 20
        }
      }
      {
        name: 'appGatewayBackendHttpsSettings'
        properties: {
          port: 443
          protocol: 'Https'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: true
          requestTimeout: 20
        }
      }
    ]
    httpListeners: [
      {
        name: 'devListener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', '${vnetName}-appgw', 'appGatewayFrontendIP')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', '${vnetName}-appgw', 'port_80')
          }
          protocol: 'Http'
          hostName: '${webApps[0].name}.azurewebsites.net'
        }
      }
      {
        name: 'devApiListener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', '${vnetName}-appgw', 'appGatewayFrontendIP')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', '${vnetName}-appgw', 'port_80')
          }
          protocol: 'Http'
          hostName: '${webApps[1].name}.azurewebsites.net'
        }
      }
      {
        name: 'qcListener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', '${vnetName}-appgw', 'appGatewayFrontendIP')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', '${vnetName}-appgw', 'port_80')
          }
          protocol: 'Http'
          hostName: '${webApps[2].name}.azurewebsites.net'
        }
      }
      {
        name: 'qcApiListener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', '${vnetName}-appgw', 'appGatewayFrontendIP')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', '${vnetName}-appgw', 'port_80')
          }
          protocol: 'Http'
          hostName: '${webApps[3].name}.azurewebsites.net'
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'devRule'
        properties: {
          ruleType: 'Basic'
          priority: 100
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', '${vnetName}-appgw', 'devListener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', '${vnetName}-appgw', 'devPool')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', '${vnetName}-appgw', 'appGatewayBackendHttpSettings')
          }
        }
      }
      {
        name: 'devApiRule'
        properties: {
          ruleType: 'Basic'
          priority: 200
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', '${vnetName}-appgw', 'devApiListener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', '${vnetName}-appgw', 'devApiPool')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', '${vnetName}-appgw', 'appGatewayBackendHttpsSettings')
          }
        }
      }
      {
        name: 'qcRule'
        properties: {
          ruleType: 'Basic'
          priority: 300
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', '${vnetName}-appgw', 'qcListener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', '${vnetName}-appgw', 'qcPool')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', '${vnetName}-appgw', 'appGatewayBackendHttpSettings')
          }
        }
      }
      {
        name: 'qcApiRule'
        properties: {
          ruleType: 'Basic'
          priority: 400
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', '${vnetName}-appgw', 'qcApiListener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', '${vnetName}-appgw', 'qcApiPool')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', '${vnetName}-appgw', 'appGatewayBackendHttpsSettings')
          }
        }
      }
    ]
  }
  dependsOn: [
    webApps
  ]
}

// Network Security Group for Test VM
resource testVMNSG 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: 'testvm-nsg'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowRDP'
        properties: {
          priority: 1000
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

// Public IP for Test VM
resource testVMPublicIP 'Microsoft.Network/publicIPAddresses@2023-09-01' = {
  name: 'testvm-pip'
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

// Network Interface for Test VM
resource testVMNIC 'Microsoft.Network/networkInterfaces@2023-09-01' = {
  name: 'testvm-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: '${vnet.id}/subnets/TestVMSubnet'
          }
          publicIPAddress: {
            id: testVMPublicIP.id
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: testVMNSG.id
    }
  }
}

// Test VM to access private endpoints
resource testVM 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: 'test-vm'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2s'
    }
    osProfile: {
      computerName: 'testvm'
      adminUsername: vmAdminUsername
      adminPassword: vmAdminPassword
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
}

// Output ADO.NET connection strings
output connectionStrings array = [for db in dbNames: {
  name: db
  value: 'Server=tcp:${sqlServer.name}.database.windows.net,1433;Initial Catalog=${db};Persist Security Info=False;User ID=${adminUsername};Password=${adminPassword};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'
}]

// Output Application Gateway Public IP
output applicationGatewayPublicIP string = appGatewayPublicIP.properties.ipAddress

// Output Web App URLs accessible through Application Gateway
output webAppUrls array = [for name in webAppNames: {
  name: name
  url: 'http://${name}.azurewebsites.net'
}]

// Output Test VM Public IP for RDP access
output testVMPublicIP string = testVMPublicIP.properties.ipAddress

// Output Custom Domain URLs (VNet-only access)
output customDomainUrls array = [
  {
    name: 'DEV-API'
    url: 'https://dev-api.rookies.internal'
    description: 'DEV API via private endpoint (VNet only)'
  }
  {
    name: 'QC-API'
    url: 'https://qc-api.rookies.internal'
    description: 'QC API via private endpoint (VNet only)'
  }
  {
    name: 'DEV-WEB'
    url: 'http://dev-web.rookies.internal'
    description: 'DEV Web via Application Gateway (VNet only)'
  }
  {
    name: 'QC-WEB'
    url: 'http://qc-web.rookies.internal'
    description: 'QC Web via Application Gateway (VNet only)'
  }
]

					  
					 
			 
