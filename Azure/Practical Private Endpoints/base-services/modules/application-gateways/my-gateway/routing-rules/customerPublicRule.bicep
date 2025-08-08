// Customer Public Routing Rule Module
// This module defines the routing rule for the customer public web app

@description('VNet name for resource naming')
param vnetName string

@description('Rule priority')
param priority int = 100

@description('Rule type')
param ruleType string = 'Basic'

@description('Backend HTTP settings name')
param backendHttpSettingsName string = 'appGatewayBackendHttpSettings'

// Build the routing rule configuration
var routingRule = {
  name: 'customerPublicRule'
  properties: {
    ruleType: ruleType
    priority: priority
    httpListener: {
      id: resourceId('Microsoft.Network/applicationGateways/httpListeners', '${vnetName}-appgw', 'customerPublicListener')
    }
    backendAddressPool: {
      id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', '${vnetName}-appgw', 'customerPublicPool')
    }
    backendHttpSettings: {
      id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', '${vnetName}-appgw', backendHttpSettingsName)
    }
  }
}

// Output the routing rule configuration
output routingRule object = routingRule
