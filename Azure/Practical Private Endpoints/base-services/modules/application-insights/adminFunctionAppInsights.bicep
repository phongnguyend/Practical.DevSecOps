// Admin Function App Application Insights Module
param location string
param functionAppName string
param logAnalyticsWorkspaceId string
param tags object = {}

// Application Insights for Admin Function App
resource adminFunctionAppInsights 'Microsoft.Insights/components@2020-02-02' = {
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
output appInsightsId string = adminFunctionAppInsights.id
output appInsightsName string = adminFunctionAppInsights.name
output appInsightsInstrumentationKey string = adminFunctionAppInsights.properties.InstrumentationKey
output appInsightsConnectionString string = adminFunctionAppInsights.properties.ConnectionString
