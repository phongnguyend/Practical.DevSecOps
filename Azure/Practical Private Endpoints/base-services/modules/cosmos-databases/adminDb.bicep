param cosmosAccountName string
param cosmosAdminDbName string
param tags object = {}

// Reference to existing Cosmos Account
resource cosmosAccount 'Microsoft.DocumentDB/databaseAccounts@2023-09-15' existing = {
  name: cosmosAccountName
}

// Cosmos DB Database
resource cosmosDatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2023-09-15' = {
  parent: cosmosAccount
  name: cosmosAdminDbName
  properties: {
    resource: {
      id: cosmosAdminDbName
    }
    options: {
      throughput: 400
    }
  }
}

// Admin Container
resource adminContainer 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2023-09-15' = {
  parent: cosmosDatabase
  name: 'admin'
  properties: {
    resource: {
      id: 'admin'
      partitionKey: {
        paths: ['/adminId']
        kind: 'Hash'
      }
      indexingPolicy: {
        indexingMode: 'consistent'
        includedPaths: [
          {
            path: '/*'
          }
        ]
        excludedPaths: [
          {
            path: '/"_etag"/?'
          }
        ]
      }
    }
    options: {
      throughput: 400
    }
  }
}

// Outputs
output databaseId string = cosmosDatabase.id
output databaseName string = cosmosDatabase.name
output adminContainerId string = adminContainer.id
output adminContainerName string = adminContainer.name
