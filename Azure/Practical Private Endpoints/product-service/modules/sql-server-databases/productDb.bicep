param location string
param sqlServerName string
param productDbName string
param tags object = {}

// Reference to existing SQL Server
resource sqlServer 'Microsoft.Sql/servers@2023-05-01-preview' existing = {
  name: sqlServerName
}

// Product Database
resource productDatabase 'Microsoft.Sql/servers/databases@2023-05-01-preview' = {
  parent: sqlServer
  name: productDbName
  location: location
  sku: {
    name: 'Basic'
    tier: 'Basic'
    capacity: 5
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 2147483648 // 2GB
  }
  tags: tags
}

// Outputs
output productDatabaseId string = productDatabase.id
output productDatabaseName string = productDatabase.name
