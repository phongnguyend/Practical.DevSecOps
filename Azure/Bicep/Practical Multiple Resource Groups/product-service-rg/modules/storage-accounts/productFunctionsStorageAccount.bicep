// Function Apps Storage Account Module - Dedicated storage for Azure Functions
param location string
param storageAccountName string
param storageAccountType string
param accessTier string
param allowBlobPublicAccess bool
param minimumTlsVersion string

// Private Endpoint Parameters
param createPrivateEndpoint bool
param privateEndpointSubnetId string
param privateDnsZoneIds object = {
  blob: ''
  file: ''
  queue: ''
  table: ''
}

// Network access configuration
param allowedIpRanges array
param bypassAzureServices bool
param allowedSubnetIds array

// Tags
param tags object

// Role Assignment Parameters for Function Apps
param roleAssignments array

// Function Apps Storage Account
resource functionAppsStorageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
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
      virtualNetworkRules: [for subnetId in allowedSubnetIds: {
        id: subnetId
        action: 'Allow'
      }]
    }
  }
}

// Blob Service for Function Apps
resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  parent: functionAppsStorageAccount
  name: 'default'
  properties: {
    cors: {
      corsRules: [
        {
          allowedOrigins: ['*']
          allowedMethods: ['GET', 'POST', 'PUT', 'DELETE', 'HEAD', 'OPTIONS']
          maxAgeInSeconds: 3600
          exposedHeaders: ['*']
          allowedHeaders: ['*']
        }
      ]
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

// Function-specific containers
var functionContainers = [
  'azure-webjobs-hosts'
  'azure-webjobs-secrets'
  'scm-releases'
  'deployments'
]

// Create containers for Function Apps
resource functionContainers_resource 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = [for containerName in functionContainers: {
  parent: blobService
  name: containerName
  properties: {
    publicAccess: 'None'
    metadata: {
      purpose: 'function-apps'
    }
  }
}]

// File Service for Function Apps (required for function app content share)
resource fileService 'Microsoft.Storage/storageAccounts/fileServices@2023-01-01' = {
  parent: functionAppsStorageAccount
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
    shareDeleteRetentionPolicy: {
      enabled: true
      days: 7
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

// Private Endpoints for Function Apps Storage Account (one for each service)
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
          privateLinkServiceId: functionAppsStorageAccount.id
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

// Role Assignments for Function Apps (Storage Blob Data Contributor)
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for assignment in roleAssignments: {
  name: guid(functionAppsStorageAccount.id, assignment.principalId, 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')
  scope: functionAppsStorageAccount
  properties: {
    principalId: assignment.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe') // Storage Blob Data Contributor
  }
}]

// Outputs
output storageAccountId string = functionAppsStorageAccount.id
output storageAccountName string = functionAppsStorageAccount.name
output primaryEndpoints object = functionAppsStorageAccount.properties.primaryEndpoints
output privateEndpoints array = [for (service, index) in storageServices: {
  name: service.name
  id: createPrivateEndpoint && !empty(service.dnsZoneId) ? privateEndpoints[index].id : ''
  hasPrivateEndpoint: createPrivateEndpoint && !empty(service.dnsZoneId)
}]
output hasPrivateEndpoints bool = createPrivateEndpoint
