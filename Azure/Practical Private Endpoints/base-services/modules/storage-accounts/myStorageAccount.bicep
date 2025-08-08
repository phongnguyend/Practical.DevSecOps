// Azure Blob Storage Module - Storage account with blob containers
param location string
param storageAccountName string
param storageAccountType string = 'Standard_LRS'
param accessTier string = 'Hot'
param allowBlobPublicAccess bool = false
param minimumTlsVersion string = 'TLS1_2'

// Container configuration
param containerNames array = [
  'documents'
  'images'
  'backups'
]
param containerPublicAccess string = 'None'

// Private Endpoint Parameters
param createPrivateEndpoint bool = false
param privateEndpointSubnetId string = ''
param privateDnsZoneId string = ''

// VNet integration configuration
param allowedSubnets array = []

// Network access configuration
param allowedIpRanges array = []
param bypassAzureServices bool = true

// Tags
param tags object = {}

// Role Assignment Parameters
param roleAssignments array = []

// Generate virtual network rules from allowed subnets
var virtualNetworkRules = [for subnetId in allowedSubnets: {
  id: subnetId
  action: 'Allow'
}]

// Storage Account
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  tags: tags
  sku: {
    name: storageAccountType
  }
  kind: 'StorageV2'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    accessTier: accessTier
    allowBlobPublicAccess: allowBlobPublicAccess
    allowSharedKeyAccess: true
    defaultToOAuthAuthentication: false
    minimumTlsVersion: minimumTlsVersion
    supportsHttpsTrafficOnly: true
    publicNetworkAccess: createPrivateEndpoint ? 'Disabled' : 'Enabled'
    networkAcls: {
      bypass: bypassAzureServices ? 'AzureServices' : 'None'
      defaultAction: (length(allowedIpRanges) > 0 || length(allowedSubnets) > 0) ? 'Deny' : 'Allow'
      ipRules: [for ipRange in allowedIpRanges: {
        value: ipRange
        action: 'Allow'
      }]
      virtualNetworkRules: length(allowedSubnets) > 0 ? virtualNetworkRules : []
    }
  }
}

// Blob Service
resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
    deleteRetentionPolicy: {
      enabled: true
      days: 7
    }
    containerDeleteRetentionPolicy: {
      enabled: true
      days: 7
    }
    changeFeed: {
      enabled: false
    }
    restorePolicy: {
      enabled: false
    }
    isVersioningEnabled: false
  }
}

// Blob Containers
resource blobContainers 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = [for containerName in containerNames: {
  parent: blobService
  name: containerName
  properties: {
    publicAccess: containerPublicAccess
    metadata: {}
  }
}]

// Private Endpoint for Blob Storage (conditional)
resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-09-01' = if (createPrivateEndpoint) {
  name: '${storageAccountName}-pe'
  location: location
  tags: tags
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${storageAccountName}-pe-connection'
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: [
            'blob'
          ]
        }
      }
    ]
  }
}

// DNS Records for Private Endpoint (conditional)
resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-09-01' = if (createPrivateEndpoint) {
  name: '${storageAccountName}-pe-dns-group'
  parent: privateEndpoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-blob-core-windows-net'
        properties: {
          privateDnsZoneId: privateDnsZoneId
        }
      }
    ]
  }
}

// Role Assignments
resource storageRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for (assignment, index) in roleAssignments: if (!empty(assignment.principalId)) {
  name: guid(storageAccount.id, assignment.principalId, assignment.roleDefinitionId)
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', assignment.roleDefinitionId)
    principalId: assignment.principalId
    principalType: 'ServicePrincipal'
  }
}]

// Outputs
output storageAccountId string = storageAccount.id
output storageAccountName string = storageAccount.name
output storageAccountPrimaryEndpoints object = storageAccount.properties.primaryEndpoints
output storageAccountPrimaryBlobEndpoint string = storageAccount.properties.primaryEndpoints.blob
output principalId string = storageAccount.identity.principalId
output containerNames array = containerNames
output hasPrivateEndpoint bool = createPrivateEndpoint
output privateEndpointId string = createPrivateEndpoint ? privateEndpoint.id : ''
output privateEndpointName string = createPrivateEndpoint ? privateEndpoint.name : ''

// Built-in role definitions for easy role assignments
output storageAccountContributorRoleId string = '17d1049b-9a84-46fb-8f53-869881c3d3ab'
output storageBlobDataOwnerRoleId string = 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b'
output storageBlobDataContributorRoleId string = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
output storageBlobDataReaderRoleId string = '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1'
