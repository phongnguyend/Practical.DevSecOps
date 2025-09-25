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
param privateDnsZoneIds object = {
  blob: ''
  file: ''
  queue: ''
  table: ''
}

// VNet integration configuration
param allowedSubnetIds array = []

// Network access configuration
param allowedIpRanges array = []
param bypassAzureServices bool = true

// Tags
param tags object = {}

// Role Assignment Parameters
param roleAssignments array = []

// Generate virtual network rules from allowed subnets
var virtualNetworkRules = [for subnetId in allowedSubnetIds: {
  id: subnetId
  action: 'Allow'
}]

// Security configuration parameters
param enableDefenderForStorage bool = true

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
      defaultAction: (length(allowedIpRanges) > 0 || length(allowedSubnetIds) > 0) ? 'Deny' : 'Allow'
      ipRules: [for ipRange in allowedIpRanges: {
        value: ipRange
        action: 'Allow'
      }]
      virtualNetworkRules: length(allowedSubnetIds) > 0 ? virtualNetworkRules : []
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

// Microsoft Defender for Storage (requires Defender for Storage Scanner Operator role at subscription level to enable malware scanning)
resource defenderForStorage 'Microsoft.Security/defenderForStorageSettings@2025-02-01-preview' = if (enableDefenderForStorage) {
  name: 'current'
  scope: storageAccount
  properties: {
    isEnabled: true
    malwareScanning: {
      blobScanResultsOptions: 'blobIndexTags'
      onUpload: {
        isEnabled: true
        capGBPerMonth: 10000
      }
    }
    sensitiveDataDiscovery: {
      isEnabled: true
    }
    overrideSubscriptionLevelSettings: true
  }
}

// Lifecycle Management Policy - Delete documents after 30 days
resource lifecyclePolicy 'Microsoft.Storage/storageAccounts/managementPolicies@2023-01-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    policy: {
      rules: [
        {
          enabled: true
          name: 'DocumentsRetentionPolicy'
          type: 'Lifecycle'
          definition: {
            filters: {
              blobTypes: [
                'blockBlob'
              ]
              prefixMatch: [
                'documents/'
              ]
            }
            actions: {
              baseBlob: {
                delete: {
                  daysAfterModificationGreaterThan: 30
                }
              }
            }
          }
        }
      ]
    }
  }
}

// Define storage services for private endpoints
var storageServices = [
  {
    name: 'blob'
    dnsZoneId: privateDnsZoneIds.blob
  }
  {
    name: 'file'
    dnsZoneId: privateDnsZoneIds.file
  }
  {
    name: 'queue'
    dnsZoneId: privateDnsZoneIds.queue
  }
  {
    name: 'table'
    dnsZoneId: privateDnsZoneIds.table
  }
]

// Private Endpoints for Storage Account (one for each service)
resource privateEndpoints 'Microsoft.Network/privateEndpoints@2023-09-01' = [for (service, index) in storageServices: if (createPrivateEndpoint && !empty(service.dnsZoneId)) {
  name: '${storageAccountName}-${service.name}-pe'
  location: location
  tags: tags
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${storageAccountName}-${service.name}-pe-connection'
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: [
            service.name
          ]
        }
      }
    ]
  }
}]

// Private DNS Zone Groups (one for each private endpoint)
resource privateDnsZoneGroups 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-09-01' = [for (service, index) in storageServices: if (createPrivateEndpoint && !empty(service.dnsZoneId)) {
  parent: privateEndpoints[index]
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: '${service.name}-config'
        properties: {
          privateDnsZoneId: service.dnsZoneId
        }
      }
    ]
  }
}]

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
output hasPrivateEndpoints bool = createPrivateEndpoint
output privateEndpoints array = [for (service, index) in storageServices: {
  name: service.name
  id: createPrivateEndpoint && !empty(service.dnsZoneId) ? privateEndpoints[index].id : ''
  hasPrivateEndpoint: createPrivateEndpoint && !empty(service.dnsZoneId)
}]

// Built-in role definitions for easy role assignments
output storageAccountContributorRoleId string = '17d1049b-9a84-46fb-8f53-869881c3d3ab'
output storageBlobDataOwnerRoleId string = 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b'
output storageBlobDataContributorRoleId string = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
output storageBlobDataReaderRoleId string = '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1'
