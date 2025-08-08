param location string = 'southeastasia'

// Feature Flags
param enablePrivateEndpoints bool = false
param enableApplicationGateway bool = false
param enableApiManagement bool = false
param enableAppConfiguration bool = false
param enableBlobStorage bool = false
param enableCosmosDb bool = false
param enableServiceBus bool = false

param vnetName string = 'PracticalMultipleResourceGroups-vnet'
param apiManagementName string = 'PracticalMultipleResourceGroups-apim'
param publisherEmail string = 'admin@practical.devsecops'
param publisherName string = 'Practical DevSecOps'

// Individual Web App Name Parameters
param customerPublicWebAppName string = 'PracticalMultipleResourceGroups-CUSTOMER-PUBLIC'
param customerSiteWebAppName string = 'PracticalMultipleResourceGroups-CUSTOMER-SITE'
param adminPublicWebAppName string = 'PracticalMultipleResourceGroups-ADMIN-PUBLIC'
param adminSiteWebAppName string = 'PracticalMultipleResourceGroups-ADMIN-SITE'
param videoApiWebAppName string = 'PracticalMultipleResourceGroups-VIDEO-API'
param musicApiWebAppName string = 'PracticalMultipleResourceGroups-MUSIC-API'

// API Management parameters
param apiManagementSku string = 'Premium'
param apiManagementCapacity int = 1

// Application Gateway WAF parameters
param enableWAF bool = true
param wafMode string = 'Prevention'
param wafRuleSetVersion string = '3.2'
param wafRequestBodyCheck bool = true
param wafMaxRequestBodySizeInKb int = 128
param wafFileUploadLimitInMb int = 100

// Common tags variable
var commonTags = {
  Environment: 'Development'
  Project: 'PracticalMultipleResourceGroups'
}

// API Management NSG Module
module apiManagementNSGModule 'modules/network-security-groups/apiManagementNSG.bicep' = {
  name: 'apiManagementNSGDeployment'
  params: {
    location: location
    name: '${vnetName}-apim-nsg'
    tags: commonTags
  }
}

// Virtual Network Module
module vnetModule 'modules/virtual-networks/virtualNetwork.bicep' = {
  name: 'virtualNetworkDeployment'
  params: {
    location: location
    vnetName: vnetName
    vnetAddressPrefix: '10.0.0.0/16'
    apiManagementNSGId: apiManagementNSGModule.outputs.apiManagementNSGId
    tags: commonTags
  }
}

// Consolidated Private DNS Zones Module
module privateDnsZonesModule 'modules/private-dns-zones/privateDNSZones.bicep' = if (enablePrivateEndpoints) {
  name: 'privateDnsZonesDeployment'
  params: {
    enablePrivateEndpoints: enablePrivateEndpoints
    enableAppConfiguration: enableAppConfiguration
    enableBlobStorage: enableBlobStorage
    enableCosmosDb: enableCosmosDb
    enableServiceBus: enableServiceBus
    vnetId: vnetModule.outputs.vnetId
    vnetName: vnetName
    customerSiteWebAppName: customerSiteWebAppName
    adminSiteWebAppName: adminSiteWebAppName
    videoApiWebAppName: videoApiWebAppName
    musicApiWebAppName: musicApiWebAppName
    applicationGatewayPublicIP: enableApplicationGateway ? applicationGatewayModule!.outputs.publicIPAddress : '0.0.0.0'
    tags: commonTags
  }
}

// Application Gateway Module
module applicationGatewayModule 'modules/application-gateways/my-gateway/applicationGateway.bicep' = if (enableApplicationGateway) {
  name: 'applicationGatewayDeployment'
  params: {
    location: location
    vnetName: vnetName
    appGatewaySubnetId: vnetModule.outputs.appGatewaySubnetId
    customerPublicWebAppName: customerPublicWebAppName
    customerSiteWebAppName: customerSiteWebAppName
    adminPublicWebAppName: adminPublicWebAppName
    adminSiteWebAppName: adminSiteWebAppName
    // WAF Configuration
    wafConfig: {
      enabled: enableWAF
      firewallMode: wafMode
      ruleSetType: 'OWASP'
      ruleSetVersion: wafRuleSetVersion
      disabledRuleGroups: []
      requestBodyCheck: wafRequestBodyCheck
      maxRequestBodySizeInKb: wafMaxRequestBodySizeInKb
      fileUploadLimitInMb: wafFileUploadLimitInMb
    }
    tags: commonTags
  }
}

// API Management Module
module apiManagementModule 'modules/api-managements/my-api-management/myApiManagement.bicep' = if (enableApiManagement) {
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
    tags: commonTags
  }
}

// Output Application Gateway Public IP
output applicationGatewayPublicIP string = enableApplicationGateway ? applicationGatewayModule!.outputs.publicIPAddress : ''

// Output Application Gateway WAF Information
output applicationGatewayWAF object = enableApplicationGateway ? {
  wafEnabled: applicationGatewayModule!.outputs.wafEnabled
  wafPolicyId: applicationGatewayModule!.outputs.wafPolicyId
  wafPolicyName: applicationGatewayModule!.outputs.wafPolicyName
  wafMode: wafMode
  ruleSetVersion: wafRuleSetVersion
} : {
  wafEnabled: false
  wafPolicyId: ''
  wafPolicyName: ''
  wafMode: ''
  ruleSetVersion: ''
}

// Output API Management Gateway URL
output apiManagementGatewayUrl string = enableApiManagement ? apiManagementModule!.outputs.apiManagementGatewayUrl : ''

// Output API Management Developer Portal URL
output apiManagementDeveloperPortalUrl string = enableApiManagement ? apiManagementModule!.outputs.apiManagementDeveloperPortalUrl : ''

// Output API Management Management URL
output apiManagementManagementUrl string = enableApiManagement ? apiManagementModule!.outputs.apiManagementManagementUrl : ''

// Output API Endpoints
output apiEndpoints array = enableApiManagement ? [
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
output internalDnsNames array = enablePrivateEndpoints ? privateDnsZonesModule!.outputs.internalDnsNames : []

// Network Security Group Outputs
output apiManagementNSGId string = apiManagementNSGModule.outputs.apiManagementNSGId
