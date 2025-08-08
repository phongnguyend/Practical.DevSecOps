// Application Gateway Module

@description('The location for resources')
param location string

@description('VNet name for resource naming')
param vnetName string

@description('Application Gateway subnet ID')
param appGatewaySubnetId string

@description('Customer public web app name')
param customerPublicWebAppName string

@description('Customer site web app name')
param customerSiteWebAppName string

@description('Admin public web app name')
param adminPublicWebAppName string

@description('Admin site web app name')
param adminSiteWebAppName string

@description('Application Gateway SKU configuration')
param gatewaySkuConfig object = {
  name: 'WAF_v2'
  tier: 'WAF_v2'
  capacity: 2
}

@description('WAF configuration')
param wafConfig object = {
  enabled: true
  firewallMode: 'Prevention'
  ruleSetType: 'OWASP'
  ruleSetVersion: '3.2'
  disabledRuleGroups: []
  requestBodyCheck: true
  maxRequestBodySizeInKb: 128
  fileUploadLimitInMb: 100
}

@description('Additional tags for resources')
param tags object = {}

@description('Custom configuration overrides')
param customConfig object = {
  backendPools: []
  httpSettings: []
  listeners: []
  routingRules: []
}

// Public IP for Application Gateway
resource appGatewayPublicIP 'Microsoft.Network/publicIPAddresses@2023-09-01' = {
  name: '${vnetName}-appgw-pip'
  location: location
  tags: tags
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

// WAF Policy
resource wafPolicy 'Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies@2023-09-01' = if (wafConfig.enabled) {
  name: '${vnetName}-appgw-waf-policy'
  location: location
  tags: tags
  properties: {
    policySettings: {
      requestBodyCheck: wafConfig.requestBodyCheck
      maxRequestBodySizeInKb: wafConfig.maxRequestBodySizeInKb
      fileUploadLimitInMb: wafConfig.fileUploadLimitInMb
      state: 'Enabled'
      mode: wafConfig.firewallMode
    }
    managedRules: {
      managedRuleSets: [
        {
          ruleSetType: wafConfig.ruleSetType
          ruleSetVersion: wafConfig.ruleSetVersion
          ruleGroupOverrides: wafConfig.disabledRuleGroups
        }
      ]
      exclusions: []
    }
    customRules: []
  }
}

// Get Backend Pools Configuration
module backendPools 'backend-pools/backendPools.bicep' = {
  name: 'appgw-backend-pools'
  params: {
    customerPublicWebAppName: customerPublicWebAppName
    customerSiteWebAppName: customerSiteWebAppName
    adminPublicWebAppName: adminPublicWebAppName
    adminSiteWebAppName: adminSiteWebAppName
    customBackendPools: customConfig.backendPools
  }
}

// Get HTTP Settings Configuration
module httpSettings 'httpSettings.bicep' = {
  name: 'appgw-http-settings'
  params: {
    customHttpSettings: customConfig.httpSettings
  }
}

// Get Listeners Configuration
module listeners 'listeners/listeners.bicep' = {
  name: 'appgw-listeners'
  params: {
    vnetName: vnetName
    customerPublicWebAppName: customerPublicWebAppName
    customerSiteWebAppName: customerSiteWebAppName
    adminPublicWebAppName: adminPublicWebAppName
    adminSiteWebAppName: adminSiteWebAppName
    customListeners: customConfig.listeners
  }
}

// Get Routing Rules Configuration
module routingRules 'routing-rules/routingRules.bicep' = {
  name: 'appgw-routing-rules'
  params: {
    vnetName: vnetName
    customRoutingRules: customConfig.routingRules
  }
}

// Application Gateway
resource applicationGateway 'Microsoft.Network/applicationGateways@2023-09-01' = {
  name: '${vnetName}-appgw'
  location: location
  tags: tags
  properties: {
    sku: gatewaySkuConfig
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
    backendAddressPools: backendPools.outputs.backendAddressPools
    backendHttpSettingsCollection: httpSettings.outputs.backendHttpSettingsCollection
    httpListeners: listeners.outputs.httpListeners
    requestRoutingRules: routingRules.outputs.requestRoutingRules
    webApplicationFirewallConfiguration: wafConfig.enabled ? {
      enabled: wafConfig.enabled
      firewallMode: wafConfig.firewallMode
      ruleSetType: wafConfig.ruleSetType
      ruleSetVersion: wafConfig.ruleSetVersion
      disabledRuleGroups: wafConfig.disabledRuleGroups
      requestBodyCheck: wafConfig.requestBodyCheck
      maxRequestBodySizeInKb: wafConfig.maxRequestBodySizeInKb
      fileUploadLimitInMb: wafConfig.fileUploadLimitInMb
    } : null
    firewallPolicy: wafConfig.enabled ? {
      id: wafPolicy.id
    } : null
  }
}

// Outputs
output applicationGatewayId string = applicationGateway.id
output applicationGatewayName string = applicationGateway.name
output publicIPAddress string = appGatewayPublicIP.properties.ipAddress
output publicIPId string = appGatewayPublicIP.id
output wafPolicyId string = wafConfig.enabled ? wafPolicy.id : ''
output wafPolicyName string = wafConfig.enabled ? wafPolicy.name : ''
output wafEnabled bool = wafConfig.enabled
