param cosmosAccountName string
param productCosmosDbName string
param tags object = {}

// Reference to existing Cosmos Account
resource cosmosAccount 'Microsoft.DocumentDB/databaseAccounts@2023-09-15' existing = {
  name: cosmosAccountName
}

// Cosmos DB Database
resource cosmosDatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2023-09-15' = {
  parent: cosmosAccount
  name: productCosmosDbName
  properties: {
    resource: {
      id: productCosmosDbName
    }
    options: {
      throughput: 400
    }
  }
}

// Product Container
resource productContainer 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2023-09-15' = {
  parent: cosmosDatabase
  name: 'products'
  properties: {
    resource: {
      id: 'products'
      partitionKey: {
        paths: ['/productId']
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

// Categories Container
resource categoriesContainer 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2023-09-15' = {
  parent: cosmosDatabase
  name: 'categories'
  properties: {
    resource: {
      id: 'categories'
      partitionKey: {
        paths: ['/categoryId']
        kind: 'Hash'
      }
    }
    options: {
      throughput: 400
    }
  }
}

// Outputs
output productDatabaseId string = cosmosDatabase.id
output productDatabaseName string = cosmosDatabase.name
output containerNames array = [
  productContainer.name
  categoriesContainer.name
]
