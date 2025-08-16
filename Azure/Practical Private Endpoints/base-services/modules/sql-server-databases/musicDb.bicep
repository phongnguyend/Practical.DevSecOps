// Music Database Module - Stores music metadata and streaming information
param location string
param sqlServerName string
param databaseName string

// Music database specific settings
param collation string = 'SQL_Latin1_General_CP1_CI_AS'
param maxSizeBytes int = 2147483648
param backupStorageRedundancy string = 'Local'
param skuName string = 'Basic'
param skuTier string = 'Basic'
param tags object = {}

// Reference to existing SQL Server
resource sqlServer 'Microsoft.Sql/servers@2023-08-01' existing = {
  name: sqlServerName
}

// Music SQL Database optimized for streaming metadata
resource musicDatabase 'Microsoft.Sql/servers/databases@2023-08-01' = {
  parent: sqlServer
  name: databaseName
  location: location
  properties: {
    collation: collation
    maxSizeBytes: maxSizeBytes
    requestedBackupStorageRedundancy: backupStorageRedundancy
  }
  sku: {
    name: skuName
    tier: skuTier
  }
  tags: tags
}

// Outputs
output databaseId string = musicDatabase.id
output databaseName string = musicDatabase.name
