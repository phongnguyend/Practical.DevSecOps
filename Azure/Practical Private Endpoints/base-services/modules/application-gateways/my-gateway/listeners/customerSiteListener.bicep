// Customer Site Listener Module
// This module defines the HTTP listener for the customer site web app

@description('VNet name for resource naming')
param vnetName string

@description('Customer site web app name')
param customerSiteWebAppName string

@description('Protocol for the listener')
param protocol string = 'Http'

@description('Frontend port name')
param frontendPortName string = 'port_80'

// Build the listener configuration
var listener = {
  name: 'customerSiteListener'
  properties: {
    frontendIPConfiguration: {
      id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', '${vnetName}-appgw', 'appGatewayFrontendIP')
    }
    frontendPort: {
      id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', '${vnetName}-appgw', frontendPortName)
    }
    protocol: protocol
    hostName: '${customerSiteWebAppName}.azurewebsites.net'
  }
}

// Output the listener configuration
output listener object = listener
