// Customer Public Backend Pool Module
// This module defines the backend pool for the customer public web app

@description('Customer public web app name')
param customerPublicWebAppName string

@description('Custom backend addresses to add to the pool')
param customBackendAddresses array = []

// Build the backend pool configuration
var backendPool = {
  name: 'customerPublicPool'
  properties: {
    backendAddresses: concat([
      {
        fqdn: '${customerPublicWebAppName}.azurewebsites.net'
      }
    ], customBackendAddresses)
  }
}

// Output the backend pool configuration
output backendPool object = backendPool
