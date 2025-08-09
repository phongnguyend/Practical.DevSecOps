param location string = 'southeastasia'
param resourceGroupName string = 'PracticalPrivateEndpoints'
param sqlServerName string = 'PracticalPrivateEndpoints'
param adminUsername string = 'PracticalPrivateEndpoints'
@secure()
param adminPassword string = 'sqladmin123!@#'
param appServicePlanName string = 'PracticalPrivateEndpoints'
param vnetName string = 'PracticalPrivateEndpoints-vnet'
param apiManagementName string = 'PracticalPrivateEndpoints-apim'
param publisherEmail string = 'admin@practical.devsecops'
param publisherName string = 'Practical DevSecOps'

// Individual Web App Name Parameters
param customerPublicWebAppName string = 'PracticalPrivateEndpoints-CUSTOMER-PUBLIC'
param customerSiteWebAppName string = 'PracticalPrivateEndpoints-CUSTOMER-SITE'
param adminPublicWebAppName string = 'PracticalPrivateEndpoints-ADMIN-PUBLIC'
param adminSiteWebAppName string = 'PracticalPrivateEndpoints-ADMIN-SITE'
param videoApiWebAppName string = 'PracticalPrivateEndpoints-VIDEO-API'
param musicApiWebAppName string = 'PracticalPrivateEndpoints-MUSIC-API'

// Individual Database Name Parameters
param customerDbName string = 'PracticalPrivateEndpoints-CUSTOMER-DB'
param adminDbName string = 'PracticalPrivateEndpoints-ADMIN-DB'
param videoDbName string = 'PracticalPrivateEndpoints-VIDEO-DB'
param musicDbName string = 'PracticalPrivateEndpoints-MUSIC-DB'

// Test VM parameters
param vmAdminUsername string = 'testadmin'
@secure()
param vmAdminPassword string = 'TestVM123!@#'

// API Management parameters
param apiManagementSku string = 'Premium'
param apiManagementCapacity int = 1

// Virtual Network Module
module vnetModule 'modules/virtualNetwork.bicep' = {
  name: 'virtualNetworkDeployment'
  params: {
    location: location
    vnetName: vnetName
    vnetAddressPrefix: '10.0.0.0/16'
  }
}

// SQL Server Module
module sqlServerModule 'modules/sqlServer.bicep' = {
  name: 'sqlServerDeployment'
  params: {
    location: location
    sqlServerName: sqlServerName
    adminUsername: adminUsername
    adminPassword: adminPassword
  }
}

// Individual Database Modules
module customerDatabaseModule 'modules/sqlDatabase.bicep' = {
  name: 'customerDatabaseDeployment'
  params: {
    location: location
    sqlServerName: sqlServerName
    databaseName: customerDbName
  }
  dependsOn: [
    sqlServerModule
  ]
}

module adminDatabaseModule 'modules/sqlDatabase.bicep' = {
  name: 'adminDatabaseDeployment'
  params: {
    location: location
    sqlServerName: sqlServerName
    databaseName: adminDbName
  }
  dependsOn: [
    sqlServerModule
  ]
}

module videoDatabaseModule 'modules/sqlDatabase.bicep' = {
  name: 'videoDatabaseDeployment'
  params: {
    location: location
    sqlServerName: sqlServerName
    databaseName: videoDbName
  }
  dependsOn: [
    sqlServerModule
  ]
}

module musicDatabaseModule 'modules/sqlDatabase.bicep' = {
  name: 'musicDatabaseDeployment'
  params: {
    location: location
    sqlServerName: sqlServerName
    databaseName: musicDbName
  }
  dependsOn: [
    sqlServerModule
  ]
}

// Private DNS Zone for Azure Web Apps
resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.azurewebsites.net'
  location: 'global'
}

// Link Private DNS Zone to VNet
resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZone
  name: '${vnetName}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetModule.outputs.vnetId
    }
  }
}

// App Service Plan Module
module appServicePlanModule 'modules/appServicePlan.bicep' = {
  name: 'appServicePlanDeployment'
  params: {
    location: location
    appServicePlanName: appServicePlanName
  }
}

// Customer Public Web App Module
module customerPublicWebAppModule 'modules/appService.bicep' = {
  name: 'customerPublicWebAppDeployment'
  params: {
    location: location
    webAppName: customerPublicWebAppName
    appServicePlanId: appServicePlanModule.outputs.appServicePlanId
    publicNetworkAccess: 'Enabled'
  }
}

// Customer Site Web App Module
module customerSiteWebAppModule 'modules/appService.bicep' = {
  name: 'customerSiteWebAppDeployment'
  params: {
    location: location
    webAppName: customerSiteWebAppName
    appServicePlanId: appServicePlanModule.outputs.appServicePlanId
    publicNetworkAccess: 'Disabled'
    createPrivateEndpoint: true
    privateEndpointSubnetId: vnetModule.outputs.privateEndpointSubnetId
    privateDnsZoneId: privateDnsZone.id
  }
}

// Admin Public Web App Module
module adminPublicWebAppModule 'modules/appService.bicep' = {
  name: 'adminPublicWebAppDeployment'
  params: {
    location: location
    webAppName: adminPublicWebAppName
    appServicePlanId: appServicePlanModule.outputs.appServicePlanId
    publicNetworkAccess: 'Enabled'
  }
}

// Admin Site Web App Module
module adminSiteWebAppModule 'modules/appService.bicep' = {
  name: 'adminSiteWebAppDeployment'
  params: {
    location: location
    webAppName: adminSiteWebAppName
    appServicePlanId: appServicePlanModule.outputs.appServicePlanId
    publicNetworkAccess: 'Disabled'
    createPrivateEndpoint: true
    privateEndpointSubnetId: vnetModule.outputs.privateEndpointSubnetId
    privateDnsZoneId: privateDnsZone.id
  }
}

// Video API Web App Module
module videoApiWebAppModule 'modules/appService.bicep' = {
  name: 'videoApiWebAppDeployment'
  params: {
    location: location
    webAppName: videoApiWebAppName
    appServicePlanId: appServicePlanModule.outputs.appServicePlanId
    publicNetworkAccess: 'Disabled'
    createPrivateEndpoint: true
    privateEndpointSubnetId: vnetModule.outputs.privateEndpointSubnetId
    privateDnsZoneId: privateDnsZone.id
  }
}

// Music API Web App Module
module musicApiWebAppModule 'modules/appService.bicep' = {
  name: 'musicApiWebAppDeployment'
  params: {
    location: location
    webAppName: musicApiWebAppName
    appServicePlanId: appServicePlanModule.outputs.appServicePlanId
    publicNetworkAccess: 'Disabled'
    createPrivateEndpoint: true
    privateEndpointSubnetId: vnetModule.outputs.privateEndpointSubnetId
    privateDnsZoneId: privateDnsZone.id
  }
}

// Custom Private DNS Zone Module
module customPrivateDnsZoneModule 'modules/customPrivateDNSZone.bicep' = {
  name: 'customPrivateDnsZoneDeployment'
  params: {
    location: 'global'
    vnetId: vnetModule.outputs.vnetId
    vnetName: vnetName
    customerSiteWebAppName: customerSiteWebAppName
    adminSiteWebAppName: adminSiteWebAppName
    videoApiWebAppName: videoApiWebAppName
    musicApiWebAppName: musicApiWebAppName
    applicationGatewayPublicIP: applicationGatewayModule.outputs.publicIPAddress
  }
}

// Application Gateway Module
module applicationGatewayModule 'modules/applicationGateway.bicep' = {
  name: 'applicationGatewayDeployment'
  params: {
    location: location
    vnetName: vnetName
    appGatewaySubnetId: vnetModule.outputs.appGatewaySubnetId
    customerPublicWebAppName: customerPublicWebAppName
    customerSiteWebAppName: customerSiteWebAppName
    adminPublicWebAppName: adminPublicWebAppName
    adminSiteWebAppName: adminSiteWebAppName
  }
}

// API Management Module
module apiManagementModule 'modules/apiManagement.bicep' = {
  name: 'apiManagementDeployment'
  params: {
    location: location
    apiManagementName: apiManagementName
    publisherEmail: publisherEmail
    publisherName: publisherName
    vnetId: vnetModule.outputs.vnetId
    apiManagementSubnetName: 'APIManagementSubnet'
    videoApiUrl: 'https://${videoApiWebAppName}.azurewebsites.net'
    musicApiUrl: 'https://${musicApiWebAppName}.azurewebsites.net'
    apiManagementSku: apiManagementSku
    apiManagementCapacity: apiManagementCapacity
  }
}

// Test VM Module
module testVMModule 'modules/testVM.bicep' = {
  name: 'testVMDeployment'
  params: {
    location: location
    vmName: 'test-vm'
    vmSize: 'Standard_B1s'
    adminUsername: vmAdminUsername
    adminPassword: vmAdminPassword
    subnetId: vnetModule.outputs.testVMSubnetId
    includePublicIP: true
  }
}

// Output SQL Server information for connection string creation
output sqlServerInfo object = {
  serverName: sqlServerModule.outputs.sqlServerName
  serverFqdn: sqlServerModule.outputs.sqlServerFqdn
  databaseNames: [
    customerDatabaseModule.outputs.databaseName
    adminDatabaseModule.outputs.databaseName
    videoDatabaseModule.outputs.databaseName
    musicDatabaseModule.outputs.databaseName
  ]
}

// Output Application Gateway Public IP
output applicationGatewayPublicIP string = applicationGatewayModule.outputs.publicIPAddress

// Output Web App URLs accessible through Application Gateway
output webAppUrls array = [
  {
    name: customerPublicWebAppName
    url: 'http://${customerPublicWebAppName}.azurewebsites.net'
  }
  {
    name: customerSiteWebAppName
    url: 'http://${customerSiteWebAppName}.azurewebsites.net'
  }
  {
    name: adminPublicWebAppName
    url: 'http://${adminPublicWebAppName}.azurewebsites.net'
  }
  {
    name: adminSiteWebAppName
    url: 'http://${adminSiteWebAppName}.azurewebsites.net'
  }
  {
    name: videoApiWebAppName
    url: 'http://${videoApiWebAppName}.azurewebsites.net'
  }
  {
    name: musicApiWebAppName
    url: 'http://${musicApiWebAppName}.azurewebsites.net'
  }
]

// Output Test VM information for access
output testVMInfo object = {
  vmName: testVMModule.outputs.vmName
  vmPrivateIP: testVMModule.outputs.vmPrivateIP
  hasPublicIP: testVMModule.outputs.hasPublicIP
  publicIPResourceId: testVMModule.outputs.vmPublicIPResourceId
}

// Output API Management Gateway URL
output apiManagementGatewayUrl string = apiManagementModule.outputs.apiManagementGatewayUrl

// Output API Management Developer Portal URL
output apiManagementDeveloperPortalUrl string = apiManagementModule.outputs.apiManagementDeveloperPortalUrl

// Output API Management Management URL
output apiManagementManagementUrl string = apiManagementModule.outputs.apiManagementManagementUrl

// Output API Endpoints
output apiEndpoints array = [
  {
    name: 'Video API'
    url: apiManagementModule.outputs.videoApiUrl
    description: 'Video API through API Management'
  }
  {
    name: 'Music API'
    url: apiManagementModule.outputs.musicApiUrl
    description: 'Music API through API Management'
  }
]

// Comprehensive Web Apps Information (reconstructed from individual modules)
output webAppsInfo array = [
  {
    index: 0
    name: customerPublicWebAppModule.outputs.webAppName
    id: customerPublicWebAppModule.outputs.webAppId
    defaultHostName: customerPublicWebAppModule.outputs.defaultHostName
    hasPrivateEndpoint: false
    privateEndpointId: ''
    privateDnsName: ''
    publicUrl: 'https://${customerPublicWebAppModule.outputs.defaultHostName}'
    isPublicAccessEnabled: true
  }
  {
    index: 1
    name: customerSiteWebAppModule.outputs.webAppName
    id: customerSiteWebAppModule.outputs.webAppId
    defaultHostName: customerSiteWebAppModule.outputs.defaultHostName
    hasPrivateEndpoint: customerSiteWebAppModule.outputs.hasPrivateEndpoint
    privateEndpointId: customerSiteWebAppModule.outputs.privateEndpointId
    privateDnsName: '${customerSiteWebAppModule.outputs.webAppName}.privatelink.azurewebsites.net'
    publicUrl: 'https://${customerSiteWebAppModule.outputs.defaultHostName}'
    isPublicAccessEnabled: false
  }
  {
    index: 2
    name: adminPublicWebAppModule.outputs.webAppName
    id: adminPublicWebAppModule.outputs.webAppId
    defaultHostName: adminPublicWebAppModule.outputs.defaultHostName
    hasPrivateEndpoint: false
    privateEndpointId: ''
    privateDnsName: ''
    publicUrl: 'https://${adminPublicWebAppModule.outputs.defaultHostName}'
    isPublicAccessEnabled: true
  }
  {
    index: 3
    name: adminSiteWebAppModule.outputs.webAppName
    id: adminSiteWebAppModule.outputs.webAppId
    defaultHostName: adminSiteWebAppModule.outputs.defaultHostName
    hasPrivateEndpoint: adminSiteWebAppModule.outputs.hasPrivateEndpoint
    privateEndpointId: adminSiteWebAppModule.outputs.privateEndpointId
    privateDnsName: '${adminSiteWebAppModule.outputs.webAppName}.privatelink.azurewebsites.net'
    publicUrl: 'https://${adminSiteWebAppModule.outputs.defaultHostName}'
    isPublicAccessEnabled: false
  }
  {
    index: 4
    name: videoApiWebAppModule.outputs.webAppName
    id: videoApiWebAppModule.outputs.webAppId
    defaultHostName: videoApiWebAppModule.outputs.defaultHostName
    hasPrivateEndpoint: videoApiWebAppModule.outputs.hasPrivateEndpoint
    privateEndpointId: videoApiWebAppModule.outputs.privateEndpointId
    privateDnsName: '${videoApiWebAppModule.outputs.webAppName}.privatelink.azurewebsites.net'
    publicUrl: 'https://${videoApiWebAppModule.outputs.defaultHostName}'
    isPublicAccessEnabled: false
  }
  {
    index: 5
    name: musicApiWebAppModule.outputs.webAppName
    id: musicApiWebAppModule.outputs.webAppId
    defaultHostName: musicApiWebAppModule.outputs.defaultHostName
    hasPrivateEndpoint: musicApiWebAppModule.outputs.hasPrivateEndpoint
    privateEndpointId: musicApiWebAppModule.outputs.privateEndpointId
    privateDnsName: '${musicApiWebAppModule.outputs.webAppName}.privatelink.azurewebsites.net'
    publicUrl: 'https://${musicApiWebAppModule.outputs.defaultHostName}'
    isPublicAccessEnabled: false
  }
]

// Internal DNS Names for Private Access (from custom DNS zone module)
output internalDnsNames array = customPrivateDnsZoneModule.outputs.internalDnsNames
