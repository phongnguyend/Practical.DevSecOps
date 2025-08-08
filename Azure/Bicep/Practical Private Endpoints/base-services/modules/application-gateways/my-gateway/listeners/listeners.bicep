// Listeners Orchestrator Module
// This module orchestrates all listener components

@description('VNet name for resource naming')
param vnetName string

@description('Customer public web app name')
param customerPublicWebAppName string

@description('Customer site web app name')
param customerSiteWebAppName string

@description('Admin public web app name')
param adminPublicWebAppName string

@description('Admin site web app name')
param adminSiteWebAppName string

@description('Custom listeners to add')
param customListeners array = []

// Deploy individual listener modules
module customerPublicListener 'customerPublicListener.bicep' = {
  name: 'customer-public-listener'
  params: {
    vnetName: vnetName
    customerPublicWebAppName: customerPublicWebAppName
    protocol: 'Http'
    frontendPortName: 'port_80'
  }
}

module customerSiteListener 'customerSiteListener.bicep' = {
  name: 'customer-site-listener'
  params: {
    vnetName: vnetName
    customerSiteWebAppName: customerSiteWebAppName
    protocol: 'Http'
    frontendPortName: 'port_80'
  }
}

module adminPublicListener 'adminPublicListener.bicep' = {
  name: 'admin-public-listener'
  params: {
    vnetName: vnetName
    adminPublicWebAppName: adminPublicWebAppName
    protocol: 'Http'
    frontendPortName: 'port_80'
  }
}

module adminSiteListener 'adminSiteListener.bicep' = {
  name: 'admin-site-listener'
  params: {
    vnetName: vnetName
    adminSiteWebAppName: adminSiteWebAppName
    protocol: 'Http'
    frontendPortName: 'port_80'
  }
}

// Collect all listeners
var standardListeners = [
  customerPublicListener.outputs.listener
  customerSiteListener.outputs.listener
  adminPublicListener.outputs.listener
  adminSiteListener.outputs.listener
]

// Output combined listeners
output httpListeners array = concat(standardListeners, customListeners)
