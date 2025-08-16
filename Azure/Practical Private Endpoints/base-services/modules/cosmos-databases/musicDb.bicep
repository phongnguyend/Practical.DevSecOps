param cosmosAccountName string
param cosmosMusicDbName string
param tags object = {}

// Reference to existing Cosmos Account
resource cosmosAccount 'Microsoft.DocumentDB/databaseAccounts@2023-09-15' existing = {
  name: cosmosAccountName
}

// Cosmos DB Database
resource cosmosDatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2023-09-15' = {
  parent: cosmosAccount
  name: cosmosMusicDbName
  properties: {
    resource: {
      id: cosmosMusicDbName
    }
    options: {
      throughput: 400
    }
  }
}

// Music Container
resource musicContainer 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2023-09-15' = {
  parent: cosmosDatabase
  name: 'music'
  properties: {
    resource: {
      id: 'music'
      partitionKey: {
        paths: ['/musicId']
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
output musicContainerId string = musicContainer.id
output musicContainerName string = musicContainer.name
