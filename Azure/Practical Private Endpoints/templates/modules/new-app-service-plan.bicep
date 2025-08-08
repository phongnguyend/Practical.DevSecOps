// new-app-service-plan.bicep
// Template for creating a new App Service Plan
// Use this when you need dedicated compute resources for different environments or workloads

@description('Name of the App Service Plan')
param appServicePlanName string

@description('Location for the App Service Plan')
param location string = resourceGroup().location

@description('App Service Plan SKU')
@allowed([
  'F1'    // Free
  'D1'    // Shared
  'B1'    // Basic Small
  'B2'    // Basic Medium
  'B3'    // Basic Large
  'S1'    // Standard Small
  'S2'    // Standard Medium
  'S3'    // Standard Large
  'P1'    // Premium Small
  'P2'    // Premium Medium
  'P3'    // Premium Large
  'P1v2'  // Premium V2 Small
  'P2v2'  // Premium V2 Medium
  'P3v2'  // Premium V2 Large
  'P1v3'  // Premium V3 Small
  'P2v3'  // Premium V3 Medium
  'P3v3'  // Premium V3 Large
])
param sku string = 'S1'

@description('Number of instances')
@minValue(1)
@maxValue(30)
param capacity int = 1

@description('Operating system (Windows or Linux)')
@allowed([
  'Windows'
  'Linux'
])
param os string = 'Windows'

@description('Whether to enable zone redundancy (requires Premium V2/V3)')
param zoneRedundant bool = false

@description('Maximum number of instances for auto-scaling')
@minValue(1)
@maxValue(30)
param maximumElasticWorkerCount int = 1

@description('Tags to apply to the App Service Plan')
param tags object = {}

// Determine if the SKU supports zone redundancy
var supportsZoneRedundancy = contains(['P1v2', 'P2v2', 'P3v2', 'P1v3', 'P2v3', 'P3v3'], sku)

// Create the App Service Plan
resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: appServicePlanName
  location: location
  tags: tags
  sku: {
    name: sku
    capacity: capacity
  }
  kind: os == 'Linux' ? 'linux' : ''
  properties: {
    reserved: os == 'Linux' ? true : false
    zoneRedundant: supportsZoneRedundancy ? zoneRedundant : false
    maximumElasticWorkerCount: maximumElasticWorkerCount
  }
}

// Outputs
output appServicePlanId string = appServicePlan.id
output appServicePlanName string = appServicePlan.name
output skuName string = appServicePlan.sku.name
output skuCapacity int = appServicePlan.sku.capacity
output operatingSystem string = os
output zoneRedundant bool = appServicePlan.properties.zoneRedundant
output resourceGroupName string = resourceGroup().name
output location string = location
