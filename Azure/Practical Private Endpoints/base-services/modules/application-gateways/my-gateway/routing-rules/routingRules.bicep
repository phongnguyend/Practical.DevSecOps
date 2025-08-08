// Routing Rules Orchestrator Module
// This module orchestrates all routing rule components

@description('VNet name for resource naming')
param vnetName string

@description('Custom routing rules to add')
param customRoutingRules array = []

// Deploy individual routing rule modules
module customerPublicRule 'customerPublicRule.bicep' = {
  name: 'customer-public-rule'
  params: {
    vnetName: vnetName
    priority: 100
    ruleType: 'Basic'
    backendHttpSettingsName: 'appGatewayBackendHttpSettings'
  }
}

module customerSiteRule 'customerSiteRule.bicep' = {
  name: 'customer-site-rule'
  params: {
    vnetName: vnetName
    priority: 200
    ruleType: 'Basic'
    backendHttpSettingsName: 'appGatewayBackendHttpsSettings'
  }
}

module adminPublicRule 'adminPublicRule.bicep' = {
  name: 'admin-public-rule'
  params: {
    vnetName: vnetName
    priority: 300
    ruleType: 'Basic'
    backendHttpSettingsName: 'appGatewayBackendHttpSettings'
  }
}

module adminSiteRule 'adminSiteRule.bicep' = {
  name: 'admin-site-rule'
  params: {
    vnetName: vnetName
    priority: 400
    ruleType: 'Basic'
    backendHttpSettingsName: 'appGatewayBackendHttpsSettings'
  }
}

// Collect all routing rules
var standardRoutingRules = [
  customerPublicRule.outputs.routingRule
  customerSiteRule.outputs.routingRule
  adminPublicRule.outputs.routingRule
  adminSiteRule.outputs.routingRule
]

// Output combined routing rules
output requestRoutingRules array = concat(standardRoutingRules, customRoutingRules)
