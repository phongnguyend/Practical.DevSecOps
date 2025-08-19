param location string
param appServicePlanName string
param tags object = {}

// App Service Plan
resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: 'S1'
    tier: 'Standard'
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
  tags: tags
}

// Outputs
output appServicePlanId string = appServicePlan.id
output appServicePlanName string = appServicePlan.name
