param location string = 'global'
param vnetId string
param vnetName string
param customDomainName string = 'rookies.internal'
param applicationGatewayPublicIP string = '0.0.0.0'
param tags object = {}

// Web app names for CNAME records
param customerSiteWebAppName string
param adminSiteWebAppName string
param videoApiWebAppName string
param musicApiWebAppName string

// Custom Private DNS Zone for internal domain
resource customPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: customDomainName
  location: location
  tags: tags
}

// Link Custom Private DNS Zone to VNet
resource customPrivateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: customPrivateDnsZone
  name: '${vnetName}-custom-link'
  location: location
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

// Custom DNS CNAME Records pointing to private endpoint DNS names
resource customerSiteCustomDnsRecord 'Microsoft.Network/privateDnsZones/CNAME@2020-06-01' = {
  parent: customPrivateDnsZone
  name: 'customer-site'
  properties: {
    cnameRecord: {
      cname: '${customerSiteWebAppName}.privatelink.azurewebsites.net'
    }
    ttl: 300
  }
}

resource adminSiteCustomDnsRecord 'Microsoft.Network/privateDnsZones/CNAME@2020-06-01' = {
  parent: customPrivateDnsZone
  name: 'admin-site'
  properties: {
    cnameRecord: {
      cname: '${adminSiteWebAppName}.privatelink.azurewebsites.net'
    }
    ttl: 300
  }
}

resource videoApiCustomDnsRecord 'Microsoft.Network/privateDnsZones/CNAME@2020-06-01' = {
  parent: customPrivateDnsZone
  name: 'video-api'
  properties: {
    cnameRecord: {
      cname: '${videoApiWebAppName}.privatelink.azurewebsites.net'
    }
    ttl: 300
  }
}

resource musicApiCustomDnsRecord 'Microsoft.Network/privateDnsZones/CNAME@2020-06-01' = {
  parent: customPrivateDnsZone
  name: 'music-api'
  properties: {
    cnameRecord: {
      cname: '${musicApiWebAppName}.privatelink.azurewebsites.net'
    }
    ttl: 300
  }
}

// Additional custom records for web apps pointing to Application Gateway
resource customerPublicWebCustomDnsRecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  parent: customPrivateDnsZone
  name: 'customer-public-web'
  properties: {
    aRecords: [
      {
        ipv4Address: applicationGatewayPublicIP
      }
    ]
    ttl: 300
  }
}

resource adminPublicWebCustomDnsRecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  parent: customPrivateDnsZone
  name: 'admin-public-web'
  properties: {
    aRecords: [
      {
        ipv4Address: applicationGatewayPublicIP
      }
    ]
    ttl: 300
  }
}

// Output the custom DNS zone ID for reference
output customPrivateDnsZoneId string = customPrivateDnsZone.id
output customPrivateDnsZoneName string = customPrivateDnsZone.name

// Output internal DNS names for reference
output internalDnsNames array = [
  {
    name: 'Customer Site Internal'
    fqdn: 'customer-site.${customDomainName}'
    target: '${customerSiteWebAppName}.privatelink.azurewebsites.net'
  }
  {
    name: 'Admin Site Internal'
    fqdn: 'admin-site.${customDomainName}'
    target: '${adminSiteWebAppName}.privatelink.azurewebsites.net'
  }
  {
    name: 'Video API Internal'
    fqdn: 'video-api.${customDomainName}'
    target: '${videoApiWebAppName}.privatelink.azurewebsites.net'
  }
  {
    name: 'Music API Internal'
    fqdn: 'music-api.${customDomainName}'
    target: '${musicApiWebAppName}.privatelink.azurewebsites.net'
  }
  {
    name: 'Customer Public Web Internal'
    fqdn: 'customer-public-web.${customDomainName}'
    target: applicationGatewayPublicIP
  }
  {
    name: 'Admin Public Web Internal'
    fqdn: 'admin-public-web.${customDomainName}'
    target: applicationGatewayPublicIP
  }
]
