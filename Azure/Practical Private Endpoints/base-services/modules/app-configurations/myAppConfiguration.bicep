// App Configuration Module - Centralized application configuration store
param location string
param appConfigName string
param skuName string = 'standard'

// Private Endpoint Parameters
param createPrivateEndpoint bool = false
param privateEndpointSubnetId string = ''
param privateDnsZoneId string = ''

// Tags
param tags object = {}

// Role Assignment Parameters
param roleAssignments array = []

// App Configuration Store
resource appConfiguration 'Microsoft.AppConfiguration/configurationStores@2023-03-01' = {
  name: appConfigName
  location: location
  tags: tags
  sku: {
    name: skuName
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    encryption: {
      keyVaultProperties: null
    }
    disableLocalAuth: false
    softDeleteRetentionInDays: 1
    enablePurgeProtection: false
    publicNetworkAccess: createPrivateEndpoint ? 'Disabled' : 'Enabled'
  }
}

// Private Endpoint (conditional)
resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-09-01' = if (createPrivateEndpoint) {
  name: '${appConfigName}-pe'
  location: location
  tags: tags
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${appConfigName}-pe-connection'
        properties: {
          privateLinkServiceId: appConfiguration.id
          groupIds: [
            'configurationStores'
          ]
        }
      }
    ]
  }
}

// DNS Records for Private Endpoint (conditional)
resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-09-01' = if (createPrivateEndpoint) {
  name: '${appConfigName}-pe-dns-group'
  parent: privateEndpoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-azconfig-io'
        properties: {
          privateDnsZoneId: privateDnsZoneId
        }
      }
    ]
  }
}

// Role Assignments
resource appConfigRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for (assignment, index) in roleAssignments: if (!empty(assignment.principalId)) {
  name: guid(appConfiguration.id, assignment.principalId, '516239f1-63e1-4d78-a4de-a74fb236a071')
  scope: appConfiguration
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '516239f1-63e1-4d78-a4de-a74fb236a071') // App Configuration Data Reader
    principalId: assignment.principalId
    principalType: 'ServicePrincipal'
  }
}]

// Outputs
output appConfigId string = appConfiguration.id
output appConfigName string = appConfiguration.name
output endpoint string = appConfiguration.properties.endpoint
output principalId string = appConfiguration.identity.principalId
output hasPrivateEndpoint bool = createPrivateEndpoint
output privateEndpointId string = createPrivateEndpoint ? privateEndpoint.id : ''
output privateEndpointName string = createPrivateEndpoint ? privateEndpoint.name : ''

// Role assignment helper - App Configuration Data Owner role
output appConfigDataOwnerRoleId string = '5ae67dd6-50cb-40e7-96ff-dc2bfa4b606b'

// Role assignment helper - App Configuration Data Reader role  
output appConfigDataReaderRoleId string = '516239f1-63e1-4d78-a4de-a74fb236a071'
