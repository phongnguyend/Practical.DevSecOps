// Function Apps Storage Account Module - Dedicated storage for Azure Functions
param location string
param storageAccountName string
param storageAccountType string = 'Standard_LRS'
param accessTier string = 'Hot'
param allowBlobPublicAccess bool = false
param minimumTlsVersion string = 'TLS1_2'

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

// Role Assignment Parameters for Function Apps
param roleAssignments array = []

// Generate virtual network rules from allowed subnets
var virtualNetworkRules = [for subnetId in allowedSubnets: {
  id: subnetId
  action: 'Allow'
}]

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
      defaultAction: (length(allowedIpRanges) > 0 || length(allowedSubnets) > 0) ? 'Deny' : 'Allow'
      ipRules: [for ipRange in allowedIpRanges: {
        value: ipRange
        action: 'Allow'
      }]
      virtualNetworkRules: length(allowedSubnets) > 0 ? virtualNetworkRules : []
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

// Private Endpoint for Function Apps Storage Account (conditional)
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
          privateLinkServiceId: functionAppsStorageAccount.id
          groupIds: [
            'blob'
          ]
        }
      }
    ]
  }
}

// Private DNS Zone Group (conditional)
resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-09-01' = if (createPrivateEndpoint) {
  parent: privateEndpoint
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'blob-config'
        properties: {
          privateDnsZoneId: privateDnsZoneId
        }
      }
    ]
  }
}

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
output privateEndpointId string = createPrivateEndpoint ? privateEndpoint.id : ''
output hasPrivateEndpoint bool = createPrivateEndpoint
