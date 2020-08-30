### Learning Paths:
- [Microsoft Certified: Azure Data Fundamentals](https://docs.microsoft.com/en-us/learn/certifications/azure-data-fundamentals#two-ways-to-prepare)
- [Microsoft Certified: Azure Database Administrator Associate](https://docs.microsoft.com/en-us/learn/certifications/azure-database-administrator-associate#two-ways-to-prepare)
- [Microsoft Certified: Azure Data Engineer Associate](https://docs.microsoft.com/en-us/learn/certifications/azure-data-engineer#two-ways-to-prepare)
- [AZ-303, AZ-304: Architect a data platform in Azure](https://docs.microsoft.com/en-us/learn/paths/architect-data-platform/)

### Tools:
- [Azure Data Studio](https://docs.microsoft.com/en-us/sql/azure-data-studio/download-azure-data-studio?view=sql-server-ver15)
- [sqlcmd](https://docs.microsoft.com/en-us/sql/tools/sqlcmd-utility?view=sql-server-ver15)
- [Data Migration Assistant](https://www.microsoft.com/en-us/download/details.aspx?id=53595)
- [Data Migration Tool](https://docs.microsoft.com/en-us/azure/cosmos-db/import-data)
- [Azure Data Factory](https://docs.microsoft.com/en-us/azure/data-factory/connector-azure-cosmos-db)
- [Azure Cosmos DB SQL API .NET SDK Bulk Import](https://docs.microsoft.com/en-us/azure/cosmos-db/tutorial-sql-api-dotnet-bulk-import)

### Useful Links:
- [Azure Cosmos DB: Consistency Levels](https://docs.microsoft.com/en-us/azure/cosmos-db/consistency-levels)
- [Azure Cosmos DB: Common Use Cases](https://docs.microsoft.com/en-us/azure/cosmos-db/use-cases)
- [Azure Cosmos DB: Indexing](https://docs.microsoft.com/en-us/azure/cosmos-db/index-overview)
- [Migrate an on-premises SQL Server database to an Azure SQL database](https://www.sqlshack.com/migrate-an-on-premises-sql-server-database-to-the-azure-sql-database/)
- [Azure Database Migration Guide](https://datamigration.microsoft.com/scenario/sql-to-azuresqldb?step=1)
- [Azure Database Migration Service](https://docs.microsoft.com/en-us/azure/dms/tutorial-sql-server-to-azure-sql)

### Common Scripts:
<details>
  <summary><b>Create a Storage account</b></summary>
  
  ```
az storage account create \
  --name <storage-account-name> \
  --resource-group <resource-group> \
  --location <your-location> \
  --sku <sku> \
  --kind <kind> \
  --access-tier <tier>
  ```
</details>

<details>
  <summary><b>Create a Data Lake storage account</b></summary>
  
  ```
az storage account create \
  --name <storage-account-name> \
  --resource-group <resource-group> \
  --location <your-location> \
  --sku <sku> \
  --kind <kind> \
  --access-tier <tier> \
  --enable-hierarchical-namespace true
  ```
</details>

<details>
  <summary><b>Create Blob storage in a storage account</b></summary>
  
  ```
az storage container create \
  --name <container-name> \
  --account-name <storage-account-name> \
  --public-access <access>
  ```
</details>

<details>
  <summary><b>Create File storage in a storage account</b></summary>
  
  ```
az storage share create \
  --name <share-name> \
  --account-name <storage-account-name>
  ```
</details>

<details>
  <summary><b>Provision a Cosmos DB account</b></summary>
  
  ```
az cosmosdb create \
  --subscription <your-subscription> \
  --resource-group <resource-group-name> \
  --name <cosmosdb-account-name> \
  --locations regionName=eastus failoverPriority=0 \
  --locations regionName=westus failoverPriority=1 \
  --enable-multiple-write-locations
  ```
</details>

<details>
  <summary><b>Create a Database and a Container in a Cosmos DB account</b></summary>
  
  ```
## Azure CLI - create a database

az cosmosdb sql database create \
  --account-name <cosmos-db-account-name> \
  --name <database-name> \
  --resource-group <resource-group-name> \
  --subscription <your-subscription> \
  --throughput <number-of-RU/s>

## Azure CLI - create a container

az cosmosdb sql container create \
  --account-name <cosmos-db-account-name> \
  --database-name <database-name> \
  --name <container-name> \
  --resource-group <resource-group-name> \
  --partition-key-path <key-field-in-documents>
  ```
</details>

<details>
  <summary><b>Upload (a) blob(s) to Azure Storage</b></summary>
  
  ```
az storage blob upload \
  --container-name images \
  --account-name contosodata \
  --file "\data\racer_black_large.gif" \
  --name "bikes\racer_black"

az storage blob upload-batch \
    --account-name <storage account name> \
    --source 'images' \
    --pattern '*.gif' \
    --destination 'images'
  ```
</details>

<details>
  <summary><b>List the blobs in a container</b></summary>
  
  ```
az storage blob list \
  --account-name contosodata \
  --container-name "images"
  ```
</details>

<details>
  <summary><b>Download a blob from a container</b></summary>
  
  ```
az storage blob download \
  --container-name images \
  --account-name contosodata \
  --file "racer_black_large.gif" \
  --name "bikes\racer_black"
  ```
</details>

<details>
  <summary><b>Delete a blob from a container</b></summary>
  
  ```
az storage blob delete \
  --account-name contosodata \
  --container-name "images" \
  --name "bikes\racer_black"
  ```
</details>

<details>
  <summary><b>Delete an Azure Storage container</b></summary>
  
  ```
az storage container delete \
  --account-name contosodata \
  --name "images"
  ```
</details>

<details>
  <summary><b>Create a database and container in Azure Cosmos DB</b></summary>
  
  ```
export NAME=cosmos$RANDOM

az cosmosdb create \
    --name $NAME \
    --kind GlobalDocumentDB \
    --resource-group learn-54e9e86a-9435-4558-a6a0-e10b85000821

az cosmosdb sql database create \
    --account-name $NAME \
    --name "Products" \
    --resource-group learn-54e9e86a-9435-4558-a6a0-e10b85000821

az cosmosdb sql container create \
    --account-name $NAME \
    --database-name "Products" \
    --name "Clothing" \
    --partition-key-path "/productId" \
    --throughput 1000 \
    --resource-group learn-54e9e86a-9435-4558-a6a0-e10b85000821
  ```
</details>
