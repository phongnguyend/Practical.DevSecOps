// App Service Plan Module
param location string
param appServicePlanName string
param skuName string = 'B1'
param skuTier string = 'Basic'

// App Service Plan for all web applications
resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: skuName
    tier: skuTier
  }
  kind: 'app' // Windows
  properties: {
    reserved: false
  }
}

// Outputs
output appServicePlanId string = appServicePlan.id
output appServicePlanName string = appServicePlan.name
