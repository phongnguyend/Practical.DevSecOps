// Customer Site Backend Pool Module
// This module defines the backend pool for the customer site web app

@description('Customer site web app name')
param customerSiteWebAppName string

@description('Custom backend addresses to add to the pool')
param customBackendAddresses array = []

// Build the backend pool configuration
var backendPool = {
  name: 'customerSitePool'
  properties: {
    backendAddresses: concat([
      {
        fqdn: '${customerSiteWebAppName}.azurewebsites.net'
      }
    ], customBackendAddresses)
  }
}

// Output the backend pool configuration
output backendPool object = backendPool
