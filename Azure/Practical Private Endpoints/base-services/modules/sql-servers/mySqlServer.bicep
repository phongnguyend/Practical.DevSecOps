// SQL Server Module
param location string
param sqlServerName string
param adminUsername string
@secure()
param adminPassword string
param tags object = {}

// VNet integration configuration
param allowedSubnets array = []

// SQL Server
resource sqlServer 'Microsoft.Sql/servers@2023-08-01' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: adminUsername
    administratorLoginPassword: adminPassword
    version: '12.0'
  }
  tags: tags
}

// Firewall rule to allow Azure services
resource firewallRule 'Microsoft.Sql/servers/firewallRules@2023-08-01' = {
  parent: sqlServer
  name: 'AllowAllAzureIPs'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

// Virtual Network Rules for VNet Integration (conditional)
resource virtualNetworkRules 'Microsoft.Sql/servers/virtualNetworkRules@2023-08-01' = [for (subnetId, index) in allowedSubnets: if (!empty(allowedSubnets)) {
  parent: sqlServer
  name: 'VNetIntegrationRule-${index}'
  properties: {
    virtualNetworkSubnetId: subnetId
    ignoreMissingVnetServiceEndpoint: false
  }
}]

// Outputs
output sqlServerId string = sqlServer.id
output sqlServerName string = sqlServer.name
output sqlServerFqdn string = sqlServer.properties.fullyQualifiedDomainName
