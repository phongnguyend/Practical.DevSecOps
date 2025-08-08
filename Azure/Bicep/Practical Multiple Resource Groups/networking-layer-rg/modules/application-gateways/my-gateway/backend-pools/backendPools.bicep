// Backend Pools Orchestrator Module
// This module orchestrates all backend pool components

@description('Customer public web app name')
param customerPublicWebAppName string

@description('Customer site web app name')
param customerSiteWebAppName string

@description('Admin public web app name')
param adminPublicWebAppName string

@description('Admin site web app name')
param adminSiteWebAppName string

@description('Custom backend pools to add')
param customBackendPools array = []

// Deploy individual backend pool modules
module customerPublicPool 'customerPublicPool.bicep' = {
  name: 'customer-public-pool'
  params: {
    customerPublicWebAppName: customerPublicWebAppName
    customBackendAddresses: []
  }
}

module customerSitePool 'customerSitePool.bicep' = {
  name: 'customer-site-pool'
  params: {
    customerSiteWebAppName: customerSiteWebAppName
    customBackendAddresses: []
  }
}

module adminPublicPool 'adminPublicPool.bicep' = {
  name: 'admin-public-pool'
  params: {
    adminPublicWebAppName: adminPublicWebAppName
    customBackendAddresses: []
  }
}

module adminSitePool 'adminSitePool.bicep' = {
  name: 'admin-site-pool'
  params: {
    adminSiteWebAppName: adminSiteWebAppName
    customBackendAddresses: []
  }
}

// Collect all backend pools
var standardBackendPools = [
  customerPublicPool.outputs.backendPool
  customerSitePool.outputs.backendPool
  adminPublicPool.outputs.backendPool
  adminSitePool.outputs.backendPool
]

// Output combined backend pools
output backendAddressPools array = concat(standardBackendPools, customBackendPools)
