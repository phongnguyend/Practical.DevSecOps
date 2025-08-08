// Admin Site Listener Module
// This module defines the HTTP listener for the admin site web app

@description('VNet name for resource naming')
param vnetName string

@description('Admin site web app name')
param adminSiteWebAppName string

@description('Protocol for the listener')
param protocol string = 'Http'

@description('Frontend port name')
param frontendPortName string = 'port_80'

// Build the listener configuration
var listener = {
  name: 'adminSiteListener'
  properties: {
    frontendIPConfiguration: {
      id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', '${vnetName}-appgw', 'appGatewayFrontendIP')
    }
    frontendPort: {
      id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', '${vnetName}-appgw', frontendPortName)
    }
    protocol: protocol
    hostName: '${adminSiteWebAppName}.azurewebsites.net'
  }
}

// Output the listener configuration
output listener object = listener
