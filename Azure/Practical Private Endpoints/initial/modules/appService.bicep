// App Service Module
param location string
param webAppName string
param appServicePlanId string
param publicNetworkAccess string = 'Enabled' // 'Enabled' or 'Disabled'
param windowsFxVersion string = 'DOTNET|8.0'

// Web App using .NET 8 on Windows
resource webApp 'Microsoft.Web/sites@2023-01-01' = {
  name: webAppName
  location: location
  kind: 'app' // Windows
  properties: {
    serverFarmId: appServicePlanId
    siteConfig: {
      windowsFxVersion: windowsFxVersion
    }
    publicNetworkAccess: publicNetworkAccess
  }
}

// Outputs
output webAppId string = webApp.id
output webAppName string = webApp.name
output defaultHostName string = webApp.properties.defaultHostName
