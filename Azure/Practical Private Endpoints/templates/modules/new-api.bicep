// new-api.bicep - Template for deploying new APIs
// This file can be used without modifying existing infrastructure
// APIs are integrated with API Management for centralized API gateway

param location string = 'southeastasia'
param apiName string // e.g., 'INVENTORY-API', 'PAYMENT-API'
param existingVnetName string = 'PracticalPrivateEndpoints-vnet'
param existingAppServicePlanName string = 'PracticalPrivateEndpoints'
param existingResourceGroupName string = 'PracticalPrivateEndpoints'
param createPrivateEndpoint bool = true
param enablePublicAccess bool = false
param addToApiManagement bool = true // APIs should be added to API Management by default

// Reference existing resources
resource existingVnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: existingVnetName
  scope: resourceGroup(existingResourceGroupName)
}

resource existingAppServicePlan 'Microsoft.Web/serverfarms@2023-01-01' existing = {
  name: existingAppServicePlanName
  scope: resourceGroup(existingResourceGroupName)
}

// New Web App for the API
resource newApiApp 'Microsoft.Web/sites@2023-01-01' = {
  name: 'PracticalPrivateEndpoints-${apiName}'
  location: location
  kind: 'app'
  properties: {
    serverFarmId: existingAppServicePlan.id
    siteConfig: {
      windowsFxVersion: 'DOTNET|8.0'
    }
    publicNetworkAccess: enablePublicAccess ? 'Enabled' : 'Disabled'
  }
}

// Private Endpoint (optional)
resource newApiPrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-09-01' = if (createPrivateEndpoint) {
  name: 'PracticalPrivateEndpoints-${apiName}-pe'
  location: location
  properties: {
    subnet: {
      id: existingVnet.properties.subnets[2].id // Private endpoint subnet
    }
    privateLinkServiceConnections: [
      {
        name: 'PracticalPrivateEndpoints-${apiName}-pe-connection'
        properties: {
          privateLinkServiceId: newApiApp.id
          groupIds: ['sites']
        }
      }
    ]
  }
}

// Private DNS Zone Group for the private endpoint
resource existingPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: 'privatelink.azurewebsites.net'
  scope: resourceGroup(existingResourceGroupName)
}

resource newApiPrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-09-01' = if (createPrivateEndpoint) {
  name: '${apiName}-dns-group'
  parent: newApiPrivateEndpoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config'
        properties: {
          privateDnsZoneId: existingPrivateDnsZone.id
        }
      }
    ]
  }
}

// Outputs
output webAppId string = newApiApp.id
output webAppName string = newApiApp.name
output webAppUrl string = 'https://${newApiApp.properties.defaultHostName}'
output privateEndpointId string = createPrivateEndpoint ? newApiPrivateEndpoint.id : ''

// Optional API Management Integration
module apiManagementIntegration 'add-to-apim.bicep' = if (addToApiManagement) {
  name: '${apiName}-apim-integration'
  params: {
    apiName: apiName
    existingApiManagementName: 'PracticalPrivateEndpoints-apim'
    apiUrl: 'https://${newApiApp.properties.defaultHostName}'
  }
}

// Additional outputs when API Management is used
output apiManagementIntegrated bool = addToApiManagement
