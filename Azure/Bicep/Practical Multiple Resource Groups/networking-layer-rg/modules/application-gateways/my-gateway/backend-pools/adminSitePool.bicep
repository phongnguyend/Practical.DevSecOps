// Admin Site Backend Pool Module
// This module defines the backend pool for the admin site web app

@description('Admin site web app name')
param adminSiteWebAppName string

@description('Custom backend addresses to add to the pool')
param customBackendAddresses array = []

// Build the backend pool configuration
var backendPool = {
  name: 'adminSitePool'
  properties: {
    backendAddresses: concat([
      {
        fqdn: '${adminSiteWebAppName}.azurewebsites.net'
      }
    ], customBackendAddresses)
  }
}

// Output the backend pool configuration
output backendPool object = backendPool
