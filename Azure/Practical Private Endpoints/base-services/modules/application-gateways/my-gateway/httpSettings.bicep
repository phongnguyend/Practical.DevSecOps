// Application Gateway HTTP Settings Configuration Module
// This module defines the HTTP settings configuration for the Application Gateway

@description('Request timeout in seconds')
param requestTimeout int = 20

@description('Cookie based affinity setting')
param cookieBasedAffinity string = 'Disabled'

@description('Pick host name from backend address')
param pickHostNameFromBackendAddress bool = true

@description('Custom HTTP settings to add')
param customHttpSettings array = []

// Build the standard HTTP settings
var standardHttpSettings = [
  {
    name: 'appGatewayBackendHttpSettings'
    properties: {
      port: 80
      protocol: 'Http'
      cookieBasedAffinity: cookieBasedAffinity
      pickHostNameFromBackendAddress: pickHostNameFromBackendAddress
      requestTimeout: requestTimeout
    }
  }
  {
    name: 'appGatewayBackendHttpsSettings'
    properties: {
      port: 443
      protocol: 'Https'
      cookieBasedAffinity: cookieBasedAffinity
      pickHostNameFromBackendAddress: pickHostNameFromBackendAddress
      requestTimeout: requestTimeout
    }
  }
]

// Outputs
output backendHttpSettingsCollection array = concat(standardHttpSettings, customHttpSettings)
