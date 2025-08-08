// Database Module for new microservices
param location string
param existingSqlServerName string
param databaseName string

// Reference existing SQL Server
resource existingSqlServer 'Microsoft.Sql/servers@2023-08-01' existing = {
  name: existingSqlServerName
}

// New Database
resource database 'Microsoft.Sql/servers/databases@2023-08-01' = {
  parent: existingSqlServer
  name: databaseName
  location: location
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 2147483648
    requestedBackupStorageRedundancy: 'Local'
  }
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
}

// Outputs
output databaseId string = database.id
output databaseName string = database.name
