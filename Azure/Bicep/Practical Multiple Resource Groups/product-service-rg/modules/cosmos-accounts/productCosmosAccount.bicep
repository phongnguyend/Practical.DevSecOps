param location string
param cosmosAccountName string
param consistencyLevel string = 'Session'
param enableAutomaticFailover bool = true
param createPrivateEndpoint bool = false
param privateEndpointSubnetId string = ''
param enablePublicNetworkAccess bool = true
// Array of role assignments with structure: { principalId: string, roleDefinitionId: string }
param roleAssignments array = []
param sqlRoleAssignments array = []
param tags object = {}

// Cosmos DB Account
resource cosmosAccount 'Microsoft.DocumentDB/databaseAccounts@2023-09-15' = {
  name: cosmosAccountName
  location: location
  kind: 'GlobalDocumentDB'
  properties: {
    databaseAccountOfferType: 'Standard'
    consistencyPolicy: {
      defaultConsistencyLevel: consistencyLevel
    }
    locations: [
      {
        locationName: location
        failoverPriority: 0
        isZoneRedundant: false
      }
    ]
    enableAutomaticFailover: enableAutomaticFailover
    enableMultipleWriteLocations: false
    publicNetworkAccess: enablePublicNetworkAccess ? 'Enabled' : 'Disabled'
    networkAclBypass: 'AzureServices'
    networkAclBypassResourceIds: []
  }
  tags: tags
}

// Private Endpoint for Cosmos DB (if enabled)
resource cosmosPrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-04-01' = if (createPrivateEndpoint && privateEndpointSubnetId != '') {
  name: '${cosmosAccountName}-pe'
  location: location
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${cosmosAccountName}-pe-connection'
        properties: {
          privateLinkServiceId: cosmosAccount.id
          groupIds: ['Sql']
        }
      }
    ]
  }
  tags: tags
}

// Generic Role Assignments for Cosmos DB
resource cosmosRoleAssignments 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2023-09-15' = [for (roleAssignment, index) in roleAssignments: {
  parent: cosmosAccount
  name: guid(cosmosAccount.id, roleAssignment.principalId, roleAssignment.roleDefinitionId)
  properties: {
    roleDefinitionId: '${cosmosAccount.id}/sqlRoleDefinitions/${roleAssignment.roleDefinitionId}'
    principalId: roleAssignment.principalId
    scope: cosmosAccount.id
  }
}]

// SQL Role Assignments for Cosmos DB Data Plane Roles
resource cosmosSqlRoleAssignments 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2023-04-15' = [for (assignment, index) in sqlRoleAssignments: if (!empty(assignment.principalId)) {
  name: guid(cosmosAccount.id, assignment.principalId, assignment.roleDefinitionId)
  parent: cosmosAccount
  properties: {
    roleDefinitionId: '${cosmosAccount.id}/sqlRoleDefinitions/${assignment.roleDefinitionId}'
    principalId: assignment.principalId
    scope: cosmosAccount.id
  }
}]

// Outputs
output cosmosAccountId string = cosmosAccount.id
output cosmosAccountName string = cosmosAccount.name
output cosmosAccountEndpoint string = cosmosAccount.properties.documentEndpoint
output hasPrivateEndpoint bool = createPrivateEndpoint && privateEndpointSubnetId != ''
output privateEndpointId string = createPrivateEndpoint && privateEndpointSubnetId != '' ? cosmosPrivateEndpoint.id : ''
