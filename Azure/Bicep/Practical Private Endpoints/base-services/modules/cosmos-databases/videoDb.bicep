param cosmosAccountName string
param cosmosVideoDbName string
param tags object = {}

// Reference to existing Cosmos Account
resource cosmosAccount 'Microsoft.DocumentDB/databaseAccounts@2023-09-15' existing = {
  name: cosmosAccountName
}

// Cosmos DB Database
resource cosmosDatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2023-09-15' = {
  parent: cosmosAccount
  name: cosmosVideoDbName
  properties: {
    resource: {
      id: cosmosVideoDbName
    }
    options: {
      throughput: 400
    }
  }
}

// Video Container
resource videoContainer 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2023-09-15' = {
  parent: cosmosDatabase
  name: 'videos'
  properties: {
    resource: {
      id: 'videos'
      partitionKey: {
        paths: ['/videoId']
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
output videoContainerId string = videoContainer.id
output videoContainerName string = videoContainer.name
