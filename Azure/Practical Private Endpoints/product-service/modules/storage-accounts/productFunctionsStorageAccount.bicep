param location string
param storageAccountName string
param createPrivateEndpoint bool = false
param privateEndpointSubnetId string = ''
param allowBlobPublicAccess bool = true
param tags object = {}

// Storage Account for Function App runtime
resource functionStorageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: allowBlobPublicAccess
    allowSharedKeyAccess: true
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    publicNetworkAccess: createPrivateEndpoint ? 'Disabled' : 'Enabled'
  }
  tags: tags
}

// Blob Service
resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  parent: functionStorageAccount
  name: 'default'
  properties: {
    cors: {
      corsRules: [
        {
          allowedOrigins: ['*']
          allowedMethods: ['GET', 'HEAD', 'POST', 'PUT', 'DELETE', 'OPTIONS']
          allowedHeaders: ['*']
          exposedHeaders: ['*']
          maxAgeInSeconds: 3600
        }
      ]
    }
  }
}

// File Service
resource fileService 'Microsoft.Storage/storageAccounts/fileServices@2023-01-01' = {
  parent: functionStorageAccount
  name: 'default'
}

// Function-specific containers
var functionContainers = [
  'azure-webjobs-hosts'
  'azure-webjobs-secrets'
  'scm-releases'
  'deployments'
]

resource functionContainerResources 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = [for containerName in functionContainers: {
  parent: blobService
  name: containerName
  properties: {
    publicAccess: 'None'
  }
}]

// Private Endpoint for Blob Storage (if enabled)
resource storagePrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-04-01' = if (createPrivateEndpoint && privateEndpointSubnetId != '') {
  name: '${storageAccountName}-blob-pe'
  location: location
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${storageAccountName}-blob-pe-connection'
        properties: {
          privateLinkServiceId: functionStorageAccount.id
          groupIds: ['blob']
        }
      }
    ]
  }
  tags: tags
}

// Outputs
output storageAccountId string = functionStorageAccount.id
output storageAccountName string = functionStorageAccount.name
output primaryEndpoints object = functionStorageAccount.properties.primaryEndpoints
output hasPrivateEndpoint bool = createPrivateEndpoint && privateEndpointSubnetId != ''
output privateEndpointId string = createPrivateEndpoint && privateEndpointSubnetId != '' ? storagePrivateEndpoint.id : ''
