// Admin Public Backend Pool Module
// This module defines the backend pool for the admin public web app

@description('Admin public web app name')
param adminPublicWebAppName string

@description('Custom backend addresses to add to the pool')
param customBackendAddresses array = []

// Build the backend pool configuration
var backendPool = {
  name: 'adminPublicPool'
  properties: {
    backendAddresses: concat([
      {
        fqdn: '${adminPublicWebAppName}.azurewebsites.net'
      }
    ], customBackendAddresses)
  }
}

// Output the backend pool configuration
output backendPool object = backendPool
