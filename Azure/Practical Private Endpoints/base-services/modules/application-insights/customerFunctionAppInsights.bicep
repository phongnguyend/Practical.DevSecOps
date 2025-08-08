// Customer Function App Application Insights Module
param location string
param functionAppName string
param logAnalyticsWorkspaceId string
param tags object = {}

// Application Insights for Customer Function App
resource customerFunctionAppInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${functionAppName}-ai'
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspaceId
    IngestionMode: 'LogAnalytics'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

// Outputs
output appInsightsId string = customerFunctionAppInsights.id
output appInsightsName string = customerFunctionAppInsights.name
output appInsightsInstrumentationKey string = customerFunctionAppInsights.properties.InstrumentationKey
output appInsightsConnectionString string = customerFunctionAppInsights.properties.ConnectionString
