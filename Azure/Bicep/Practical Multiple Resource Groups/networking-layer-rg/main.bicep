// Nested parameter objects for better organization
param general object = {
  location: 'southeastasia'
}

param featureFlags object = {
  enablePrivateEndpoints: false
  enableApplicationGateway: false
  enableApiManagement: false
  enableAppConfiguration: false
  enableBlobStorage: false
  enableCosmosDb: false
  enableServiceBus: false
  enableWAF: false
}

param networking object = {
  vnetName: 'PracticalMultipleResourceGroups-vnet'
}

param apiManagement object = {
  name: 'PracticalMultipleResourceGroups-apim'
  publisherEmail: 'admin@practical.devsecops'
  publisherName: 'Practical DevSecOps'
  sku: 'Premium'
  capacity: 1
}

param webApps object = {
  apps: {
    customerPublic: 'PracticalMultipleResourceGroups-CUSTOMER-PUBLIC'
    customerSite: 'PracticalMultipleResourceGroups-CUSTOMER-SITE'
    adminPublic: 'PracticalMultipleResourceGroups-ADMIN-PUBLIC'
    adminSite: 'PracticalMultipleResourceGroups-ADMIN-SITE'
    videoApi: 'PracticalMultipleResourceGroups-VIDEO-API'
    musicApi: 'PracticalMultipleResourceGroups-MUSIC-API'
  }
}

param applicationGateway object = {
  waf: {
    mode: 'Prevention'
    ruleSetVersion: '3.2'
    requestBodyCheck: true
    maxRequestBodySizeInKb: 128
    fileUploadLimitInMb: 100
  }
}

// Common tags variable
var commonTags = {
  Environment: 'Development'
  Project: 'PracticalMultipleResourceGroups'
}

// API Management NSG Module
module apiManagementNSGModule 'modules/network-security-groups/apiManagementNSG.bicep' = {
  name: 'apiManagementNSGDeployment'
  params: {
    location: general.location
    name: '${networking.vnetName}-apim-nsg'
    tags: commonTags
  }
}

// Virtual Network Module
module vnetModule 'modules/virtual-networks/virtualNetwork.bicep' = {
  name: 'virtualNetworkDeployment'
  params: {
    location: general.location
    vnetName: networking.vnetName
    vnetAddressPrefix: '10.0.0.0/16'
    apiManagementNSGId: apiManagementNSGModule.outputs.apiManagementNSGId
    tags: commonTags
  }
}

// Consolidated Private DNS Zones Module
module privateDnsZonesModule 'modules/private-dns-zones/privateDNSZones.bicep' = if (featureFlags.enablePrivateEndpoints) {
  name: 'privateDnsZonesDeployment'
  params: {
    enablePrivateEndpoints: featureFlags.enablePrivateEndpoints
    vnetId: vnetModule.outputs.vnetId
    vnetName: networking.vnetName
    customerSiteWebAppName: webApps.apps.customerSite
    adminSiteWebAppName: webApps.apps.adminSite
    videoApiWebAppName: webApps.apps.videoApi
    musicApiWebAppName: webApps.apps.musicApi
    applicationGatewayPublicIP: featureFlags.enableApplicationGateway ? applicationGatewayModule!.outputs.publicIPAddress : '0.0.0.0'
    tags: commonTags
  }
}

// Application Gateway Module
module applicationGatewayModule 'modules/application-gateways/my-gateway/applicationGateway.bicep' = if (featureFlags.enableApplicationGateway) {
  name: 'applicationGatewayDeployment'
  params: {
    location: general.location
    vnetName: networking.vnetName
    appGatewaySubnetId: vnetModule.outputs.appGatewaySubnetId
    customerPublicWebAppName: webApps.apps.customerPublic
    customerSiteWebAppName: webApps.apps.customerSite
    adminPublicWebAppName: webApps.apps.adminPublic
    adminSiteWebAppName: webApps.apps.adminSite
    // WAF Configuration
    wafConfig: {
      enabled: featureFlags.enableWAF
      firewallMode: applicationGateway.waf.mode
      ruleSetType: 'OWASP'
      ruleSetVersion: applicationGateway.waf.ruleSetVersion
      disabledRuleGroups: []
      requestBodyCheck: applicationGateway.waf.requestBodyCheck
      maxRequestBodySizeInKb: applicationGateway.waf.maxRequestBodySizeInKb
      fileUploadLimitInMb: applicationGateway.waf.fileUploadLimitInMb
    }
    tags: commonTags
  }
}

// API Management Module
module apiManagementModule 'modules/api-managements/my-api-management/myApiManagement.bicep' = if (featureFlags.enableApiManagement) {
  name: 'apiManagementDeployment'
  params: {
    location: general.location
    apiManagementName: apiManagement.name
    publisherEmail: apiManagement.publisherEmail
    publisherName: apiManagement.publisherName
    vnetId: vnetModule.outputs.vnetId
    apiManagementSubnetName: 'APIManagementSubnet'
    videoApiUrl: 'https://${webApps.apps.videoApi}.azurewebsites.net'
    musicApiUrl: 'https://${webApps.apps.musicApi}.azurewebsites.net'
    apiManagementSku: apiManagement.sku
    apiManagementCapacity: apiManagement.capacity
    tags: commonTags
  }
}

// Output Application Gateway Public IP
output applicationGatewayPublicIP string = featureFlags.enableApplicationGateway ? applicationGatewayModule!.outputs.publicIPAddress : ''

// Output Application Gateway WAF Information
output applicationGatewayWAF object = featureFlags.enableApplicationGateway ? {
  wafEnabled: applicationGatewayModule!.outputs.wafEnabled
  wafPolicyId: applicationGatewayModule!.outputs.wafPolicyId
  wafPolicyName: applicationGatewayModule!.outputs.wafPolicyName
  wafMode: applicationGateway.waf.mode
  ruleSetVersion: applicationGateway.waf.ruleSetVersion
} : {
  wafEnabled: false
  wafPolicyId: ''
  wafPolicyName: ''
  wafMode: ''
  ruleSetVersion: ''
}

// Output API Management Gateway URL
output apiManagementGatewayUrl string = featureFlags.enableApiManagement ? apiManagementModule!.outputs.apiManagementGatewayUrl : ''

// Output API Management Developer Portal URL
output apiManagementDeveloperPortalUrl string = featureFlags.enableApiManagement ? apiManagementModule!.outputs.apiManagementDeveloperPortalUrl : ''

// Output API Management Management URL
output apiManagementManagementUrl string = featureFlags.enableApiManagement ? apiManagementModule!.outputs.apiManagementManagementUrl : ''

// Output API Endpoints
output apiEndpoints array = featureFlags.enableApiManagement ? [
  {
    name: 'Video API'
    url: apiManagementModule!.outputs.videoApiUrl
    description: 'Video API through API Management'
  }
  {
    name: 'Music API'
    url: apiManagementModule!.outputs.musicApiUrl
    description: 'Music API through API Management'
  }
] : []

// Internal DNS Names for Private Access (from consolidated private DNS zones module)
output internalDnsNames array = featureFlags.enablePrivateEndpoints ? privateDnsZonesModule!.outputs.internalDnsNames : []

// Network Security Group Outputs
output apiManagementNSGId string = apiManagementNSGModule.outputs.apiManagementNSGId
