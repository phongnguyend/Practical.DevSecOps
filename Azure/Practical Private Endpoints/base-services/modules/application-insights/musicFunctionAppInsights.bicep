// Music Function App Application Insights Module
param location string
param functionAppName string
param logAnalyticsWorkspaceId string
param tags object = {}

// Application Insights for Music Function App
resource musicFunctionAppInsights 'Microsoft.Insights/components@2020-02-02' = {
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
output appInsightsId string = musicFunctionAppInsights.id
output appInsightsName string = musicFunctionAppInsights.name
output appInsightsInstrumentationKey string = musicFunctionAppInsights.properties.InstrumentationKey
output appInsightsConnectionString string = musicFunctionAppInsights.properties.ConnectionString
