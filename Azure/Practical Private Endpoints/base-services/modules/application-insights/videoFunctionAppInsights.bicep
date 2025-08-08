// Video Function App Application Insights Module
param location string
param functionAppName string
param logAnalyticsWorkspaceId string
param tags object = {}

// Application Insights for Video Function App
resource videoFunctionAppInsights 'Microsoft.Insights/components@2020-02-02' = {
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
output appInsightsId string = videoFunctionAppInsights.id
output appInsightsName string = videoFunctionAppInsights.name
output appInsightsInstrumentationKey string = videoFunctionAppInsights.properties.InstrumentationKey
output appInsightsConnectionString string = videoFunctionAppInsights.properties.ConnectionString
