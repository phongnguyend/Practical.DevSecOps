// Application Gateway Module
param location string
param vnetName string
param appGatewaySubnetId string
param customerPublicWebAppName string
param customerSiteWebAppName string
param adminPublicWebAppName string
param adminSiteWebAppName string

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
            id: appGatewaySubnetId
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
        name: 'customerPublicPool'
        properties: {
          backendAddresses: [
            {
              fqdn: '${customerPublicWebAppName}.azurewebsites.net'
            }
          ]
        }
      }
      {
        name: 'customerSitePool'
        properties: {
          backendAddresses: [
            {
              fqdn: '${customerSiteWebAppName}.azurewebsites.net'
            }
          ]
        }
      }
      {
        name: 'adminPublicPool'
        properties: {
          backendAddresses: [
            {
              fqdn: '${adminPublicWebAppName}.azurewebsites.net'
            }
          ]
        }
      }
      {
        name: 'adminSitePool'
        properties: {
          backendAddresses: [
            {
              fqdn: '${adminSiteWebAppName}.azurewebsites.net'
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
        name: 'customerPublicListener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', '${vnetName}-appgw', 'appGatewayFrontendIP')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', '${vnetName}-appgw', 'port_80')
          }
          protocol: 'Http'
          hostName: '${customerPublicWebAppName}.azurewebsites.net'
        }
      }
      {
        name: 'customerSiteListener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', '${vnetName}-appgw', 'appGatewayFrontendIP')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', '${vnetName}-appgw', 'port_80')
          }
          protocol: 'Http'
          hostName: '${customerSiteWebAppName}.azurewebsites.net'
        }
      }
      {
        name: 'adminPublicListener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', '${vnetName}-appgw', 'appGatewayFrontendIP')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', '${vnetName}-appgw', 'port_80')
          }
          protocol: 'Http'
          hostName: '${adminPublicWebAppName}.azurewebsites.net'
        }
      }
      {
        name: 'adminSiteListener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', '${vnetName}-appgw', 'appGatewayFrontendIP')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', '${vnetName}-appgw', 'port_80')
          }
          protocol: 'Http'
          hostName: '${adminSiteWebAppName}.azurewebsites.net'
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'customerPublicRule'
        properties: {
          ruleType: 'Basic'
          priority: 100
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', '${vnetName}-appgw', 'customerPublicListener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', '${vnetName}-appgw', 'customerPublicPool')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', '${vnetName}-appgw', 'appGatewayBackendHttpSettings')
          }
        }
      }
      {
        name: 'customerSiteRule'
        properties: {
          ruleType: 'Basic'
          priority: 200
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', '${vnetName}-appgw', 'customerSiteListener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', '${vnetName}-appgw', 'customerSitePool')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', '${vnetName}-appgw', 'appGatewayBackendHttpsSettings')
          }
        }
      }
      {
        name: 'adminPublicRule'
        properties: {
          ruleType: 'Basic'
          priority: 300
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', '${vnetName}-appgw', 'adminPublicListener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', '${vnetName}-appgw', 'adminPublicPool')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', '${vnetName}-appgw', 'appGatewayBackendHttpSettings')
          }
        }
      }
      {
        name: 'adminSiteRule'
        properties: {
          ruleType: 'Basic'
          priority: 400
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', '${vnetName}-appgw', 'adminSiteListener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', '${vnetName}-appgw', 'adminSitePool')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', '${vnetName}-appgw', 'appGatewayBackendHttpsSettings')
          }
        }
      }
    ]
  }
}

// Outputs
output applicationGatewayId string = applicationGateway.id
output applicationGatewayName string = applicationGateway.name
output publicIPAddress string = appGatewayPublicIP.properties.ipAddress
output publicIPId string = appGatewayPublicIP.id
