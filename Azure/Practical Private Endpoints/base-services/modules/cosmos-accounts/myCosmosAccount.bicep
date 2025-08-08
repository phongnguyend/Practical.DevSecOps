// Azure Cosmos DB Account Module - NoSQL database account with global distribution
param location string
param cosmosAccountName string
param consistencyLevel string = 'Session'
param enableAutomaticFailover bool = true
param enableMultipleWriteLocations bool = false

// Private Endpoint Parameters
param createPrivateEndpoint bool = false
param privateEndpointSubnetId string = ''
param privateDnsZoneId string = ''

// VNet integration configuration
param allowedSubnets array = []

// Network access configuration
param allowedIpRanges array = []
param enablePublicNetworkAccess bool = true

// Backup configuration
param backupIntervalInMinutes int = 240
param backupRetentionIntervalInHours int = 8
param backupStorageRedundancy string = 'Local'

// Tags
param tags object = {}

// Role Assignment Parameters
param roleAssignments array = []

// Generate virtual network rules from allowed subnets
var virtualNetworkRules = [for subnetId in allowedSubnets: {
  id: subnetId
  ignoreMissingVNetServiceEndpoint: false
}]

// Cosmos DB Account
resource cosmosAccount 'Microsoft.DocumentDB/databaseAccounts@2023-04-15' = {
  name: cosmosAccountName
  location: location
  tags: tags
  kind: 'GlobalDocumentDB'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    databaseAccountOfferType: 'Standard'
    consistencyPolicy: {
      defaultConsistencyLevel: consistencyLevel
      maxIntervalInSeconds: 86400
      maxStalenessPrefix: 1000000
    }
    locations: [
      {
        locationName: location
        failoverPriority: 0
        isZoneRedundant: false
      }
    ]
    enableAutomaticFailover: enableAutomaticFailover
    enableMultipleWriteLocations: enableMultipleWriteLocations
    isVirtualNetworkFilterEnabled: (!empty(allowedIpRanges) || createPrivateEndpoint || length(allowedSubnets) > 0)
    virtualNetworkRules: length(allowedSubnets) > 0 ? virtualNetworkRules : []
    ipRules: [for ipRange in allowedIpRanges: {
      ipAddressOrRange: ipRange
    }]
    publicNetworkAccess: enablePublicNetworkAccess ? 'Enabled' : 'Disabled'
    networkAclBypass: 'AzureServices'
    backupPolicy: {
      type: 'Periodic'
      periodicModeProperties: {
        backupIntervalInMinutes: backupIntervalInMinutes
        backupRetentionIntervalInHours: backupRetentionIntervalInHours
        backupStorageRedundancy: backupStorageRedundancy
      }
    }
    analyticalStorageConfiguration: {
      schemaType: 'WellDefined'
    }
  }
}

// Private Endpoint for Cosmos DB (conditional)
resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-09-01' = if (createPrivateEndpoint) {
  name: '${cosmosAccountName}-pe'
  location: location
  tags: tags
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${cosmosAccountName}-pe-connection'
        properties: {
          privateLinkServiceId: cosmosAccount.id
          groupIds: [
            'Sql'
          ]
        }
      }
    ]
  }
}

// DNS Records for Private Endpoint (conditional)
resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-09-01' = if (createPrivateEndpoint) {
  name: '${cosmosAccountName}-pe-dns-group'
  parent: privateEndpoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-documents-azure-com'
        properties: {
          privateDnsZoneId: privateDnsZoneId
        }
      }
    ]
  }
}

// Role Assignments
resource cosmosRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for (assignment, index) in roleAssignments: if (!empty(assignment.principalId)) {
  name: guid(cosmosAccount.id, assignment.principalId, assignment.roleDefinitionId)
  scope: cosmosAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', assignment.roleDefinitionId)
    principalId: assignment.principalId
    principalType: 'ServicePrincipal'
  }
}]

// Outputs
output cosmosAccountId string = cosmosAccount.id
output cosmosAccountName string = cosmosAccount.name
output cosmosAccountEndpoint string = cosmosAccount.properties.documentEndpoint
output principalId string = cosmosAccount.identity.principalId
output hasPrivateEndpoint bool = createPrivateEndpoint
output privateEndpointId string = createPrivateEndpoint ? privateEndpoint.id : ''
output privateEndpointName string = createPrivateEndpoint ? privateEndpoint.name : ''

// Built-in role definitions for Cosmos DB RBAC
output cosmosDataOwnerRoleId string = 'b24988ac-6180-42a0-ab88-20f7382dd24c'
output cosmosDataContributorRoleId string = '5bd9cd88-fe45-4216-938b-f97437e15450'
output cosmosDataReaderRoleId string = 'fbdf93bf-df7d-467e-a4d2-9458aa1360c8'
