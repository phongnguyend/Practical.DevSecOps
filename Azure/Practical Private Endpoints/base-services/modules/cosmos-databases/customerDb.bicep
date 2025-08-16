param cosmosAccountName string
param cosmosCustomerDbName string
param tags object = {}

// Reference to existing Cosmos Account
resource cosmosAccount 'Microsoft.DocumentDB/databaseAccounts@2023-09-15' existing = {
  name: cosmosAccountName
}

// Cosmos DB Database
resource cosmosDatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2023-09-15' = {
  parent: cosmosAccount
  name: cosmosCustomerDbName
  properties: {
    resource: {
      id: cosmosCustomerDbName
    }
    options: {
      throughput: 400
    }
  }
}

// Customer Container
resource customerContainer 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2023-09-15' = {
  parent: cosmosDatabase
  name: 'customers'
  properties: {
    resource: {
      id: 'customers'
      partitionKey: {
        paths: ['/customerId']
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
output customerContainerId string = customerContainer.id
output customerContainerName string = customerContainer.name
