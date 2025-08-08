// add-to-application-gateway.bicep - Module for adding new microservice to Application Gateway
// This updates the existing Application Gateway to include the new microservice

param existingWebAppName string
param existingVnetName string = 'PracticalPrivateEndpoints-vnet'
param existingResourceGroupName string = 'PracticalPrivateEndpoints'
param pathPattern string // e.g., /inventory-api/* (should be provided by caller)
param priority int = 100 // Lower number = higher priority
param location string = 'southeastasia'

// Extract service name from web app name (e.g., 'PracticalPrivateEndpoints-INVENTORY-API' -> 'INVENTORY-API')
var serviceName = length(split(existingWebAppName, '-')) > 1 ? split(existingWebAppName, '-')[1] : existingWebAppName

// Reference existing Application Gateway
resource existingApplicationGateway 'Microsoft.Network/applicationGateways@2023-09-01' existing = {
  name: '${existingVnetName}-appgw'
  scope: resourceGroup(existingResourceGroupName)
}

// Reference the new web app
resource existingWebApp 'Microsoft.Web/sites@2023-01-01' existing = {
  name: existingWebAppName
  scope: resourceGroup(existingResourceGroupName)
}

// Get existing Application Gateway Public IP
resource existingAppGwPublicIP 'Microsoft.Network/publicIPAddresses@2023-09-01' existing = {
  name: '${existingVnetName}-appgw-pip'
  scope: resourceGroup(existingResourceGroupName)
}

// Update Application Gateway with new microservice configuration
resource updatedApplicationGateway 'Microsoft.Network/applicationGateways@2023-09-01' = {
  name: existingApplicationGateway.name
  location: location
  properties: {
    sku: existingApplicationGateway.properties.sku
    gatewayIPConfigurations: existingApplicationGateway.properties.gatewayIPConfigurations
    frontendIPConfigurations: existingApplicationGateway.properties.frontendIPConfigurations
    frontendPorts: existingApplicationGateway.properties.frontendPorts
    
    // Add new backend pool for microservice
    backendAddressPools: concat(existingApplicationGateway.properties.backendAddressPools, [
      {
        name: '${toLower(serviceName)}Pool'
        properties: {
          backendAddresses: [
            {
              fqdn: existingWebApp.properties.defaultHostName
            }
          ]
        }
      }
    ])
    
    // Add new backend HTTP settings for microservice
    backendHttpSettingsCollection: concat(existingApplicationGateway.properties.backendHttpSettingsCollection, [
      {
        name: '${toLower(serviceName)}HttpSettings'
        properties: {
          port: 443
          protocol: 'Https'
          cookieBasedAffinity: 'Disabled'
          requestTimeout: 30
          pickHostNameFromBackendAddress: true
          probeEnabled: false
        }
      }
    ])
    
    // Add new HTTP listener for microservice
    httpListeners: concat(existingApplicationGateway.properties.httpListeners, [
      {
        name: '${toLower(serviceName)}Listener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', existingApplicationGateway.name, 'appGatewayFrontendIP')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', existingApplicationGateway.name, 'port_80')
          }
          protocol: 'Http'
          hostNames: []
        }
      }
    ])
    
    // Add new routing rule for microservice
    requestRoutingRules: concat(existingApplicationGateway.properties.requestRoutingRules, [
      {
        name: '${toLower(serviceName)}RoutingRule'
        properties: {
          ruleType: 'PathBasedRouting'
          priority: priority
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', existingApplicationGateway.name, '${toLower(serviceName)}Listener')
          }
          urlPathMap: {
            id: resourceId('Microsoft.Network/applicationGateways/urlPathMaps', existingApplicationGateway.name, 'pathMap')
          }
        }
      }
    ])
    
    // Update URL path maps to include new microservice path
    urlPathMaps: [
      {
        name: 'pathMap'
        properties: {
          defaultBackendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', existingApplicationGateway.name, 'customerPublicPool')
          }
          defaultBackendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', existingApplicationGateway.name, 'customerPublicHttpSettings')
          }
          pathRules: concat(
            existingApplicationGateway.properties.urlPathMaps[0].properties.pathRules,
            [
              {
                name: '${toLower(serviceName)}PathRule'
                properties: {
                  paths: [
                    pathPattern
                  ]
                  backendAddressPool: {
                    id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', existingApplicationGateway.name, '${toLower(serviceName)}Pool')
                  }
                  backendHttpSettings: {
                    id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', existingApplicationGateway.name, '${toLower(serviceName)}HttpSettings')
                  }
                }
              }
            ]
          )
        }
      }
    ]
  }
}

// Outputs
output applicationGatewayName string = updatedApplicationGateway.name
output applicationGatewayFqdn string = existingAppGwPublicIP.properties.dnsSettings.fqdn
output newBackendPoolName string = '${toLower(serviceName)}Pool'
output pathPattern string = pathPattern
output microserviceUrl string = 'http://${existingAppGwPublicIP.properties.dnsSettings.fqdn}${pathPattern}'
