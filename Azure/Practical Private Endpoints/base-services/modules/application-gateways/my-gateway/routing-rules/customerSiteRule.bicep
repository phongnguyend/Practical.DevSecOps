// Customer Site Routing Rule Module
// This module defines the routing rule for the customer site web app

@description('VNet name for resource naming')
param vnetName string

@description('Rule priority')
param priority int = 200

@description('Rule type')
param ruleType string = 'Basic'

@description('Backend HTTP settings name')
param backendHttpSettingsName string = 'appGatewayBackendHttpsSettings'

// Build the routing rule configuration
var routingRule = {
  name: 'customerSiteRule'
  properties: {
    ruleType: ruleType
    priority: priority
    httpListener: {
      id: resourceId('Microsoft.Network/applicationGateways/httpListeners', '${vnetName}-appgw', 'customerSiteListener')
    }
    backendAddressPool: {
      id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', '${vnetName}-appgw', 'customerSitePool')
    }
    backendHttpSettings: {
      id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', '${vnetName}-appgw', backendHttpSettingsName)
    }
  }
}

// Output the routing rule configuration
output routingRule object = routingRule
