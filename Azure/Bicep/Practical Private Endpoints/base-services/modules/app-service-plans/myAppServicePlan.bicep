// App Service Plan Module - Clean version for App Service Plan only
param location string
param appServicePlanName string
param skuName string = 'B1'
param skuTier string = 'Basic'

param tags object = {}

// App Service Plan
resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: appServicePlanName
  location: location
  kind: 'app'
  tags: tags
  sku: {
    name: skuName
    tier: skuTier
  }
}

// Outputs
output appServicePlanId string = appServicePlan.id
output appServicePlanName string = appServicePlan.name
