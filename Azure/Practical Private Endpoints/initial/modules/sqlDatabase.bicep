// Individual SQL Database Module
param location string
param sqlServerName string
param databaseName string
param collation string = 'SQL_Latin1_General_CP1_CI_AS'
param maxSizeBytes int = 2147483648
param backupStorageRedundancy string = 'Local'
param skuName string = 'Basic'
param skuTier string = 'Basic'

// Reference to existing SQL Server
resource sqlServer 'Microsoft.Sql/servers@2023-08-01' existing = {
  name: sqlServerName
}

// SQL Database
resource database 'Microsoft.Sql/servers/databases@2023-08-01' = {
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
}

// Outputs
output databaseId string = database.id
output databaseName string = database.name
