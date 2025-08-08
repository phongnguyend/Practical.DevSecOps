// Admin Public Web App Application Insights Module
param location string
param webAppName string
param logAnalyticsWorkspaceId string
param tags object = {}

// Application Insights for Admin Public Web App
resource adminPublicAppInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${webAppName}-ai'
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
output appInsightsId string = adminPublicAppInsights.id
output appInsightsName string = adminPublicAppInsights.name
output appInsightsInstrumentationKey string = adminPublicAppInsights.properties.InstrumentationKey
output appInsightsConnectionString string = adminPublicAppInsights.properties.ConnectionString
