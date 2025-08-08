// new-site.bicep - Template for deploying new websites/sites
// This file can be used without modifying existing infrastructure
// Sites are integrated with Application Gateway for public access

param location string = 'southeastasia'
param siteName string // e.g., 'CUSTOMER-PORTAL', 'ADMIN-DASHBOARD'
param existingVnetName string = 'PracticalPrivateEndpoints-vnet'
param existingAppServicePlanName string = 'PracticalPrivateEndpoints'
param existingResourceGroupName string = 'PracticalPrivateEndpoints'
param createPrivateEndpoint bool = true
param enablePublicAccess bool = true // Sites typically need public access
param addToApplicationGateway bool = true // Sites should be added to Application Gateway by default
param applicationGatewayPathPattern string = '/${toLower(siteName)}/*' // Default path pattern
param applicationGatewayPriority int = 100 // Routing rule priority

// Reference existing resources
resource existingVnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: existingVnetName
  scope: resourceGroup(existingResourceGroupName)
}

resource existingAppServicePlan 'Microsoft.Web/serverfarms@2023-01-01' existing = {
  name: existingAppServicePlanName
  scope: resourceGroup(existingResourceGroupName)
}

// New Web App for the site
resource newSiteApp 'Microsoft.Web/sites@2023-01-01' = {
  name: 'PracticalPrivateEndpoints-${siteName}'
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
resource newSitePrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-09-01' = if (createPrivateEndpoint) {
  name: 'PracticalPrivateEndpoints-${siteName}-pe'
  location: location
  properties: {
    subnet: {
      id: existingVnet.properties.subnets[2].id // Private endpoint subnet
    }
    privateLinkServiceConnections: [
      {
        name: 'PracticalPrivateEndpoints-${siteName}-pe-connection'
        properties: {
          privateLinkServiceId: newSiteApp.id
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

resource newSitePrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-09-01' = if (createPrivateEndpoint) {
  name: '${siteName}-dns-group'
  parent: newSitePrivateEndpoint
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
output webAppId string = newSiteApp.id
output webAppName string = newSiteApp.name
output webAppUrl string = 'https://${newSiteApp.properties.defaultHostName}'
output privateEndpointId string = createPrivateEndpoint ? newSitePrivateEndpoint.id : ''

// Optional Application Gateway Integration
module applicationGatewayIntegration 'add-to-application-gateway.bicep' = if (addToApplicationGateway) {
  name: '${siteName}-appgw-integration'
  params: {
    existingWebAppName: newSiteApp.name
    existingVnetName: existingVnetName
    existingResourceGroupName: existingResourceGroupName
    pathPattern: applicationGatewayPathPattern
    priority: applicationGatewayPriority
    location: location
  }
}

// Additional outputs when Application Gateway is used
output applicationGatewayIntegrated bool = addToApplicationGateway
output applicationGatewayPathPattern string = addToApplicationGateway ? applicationGatewayPathPattern : ''
