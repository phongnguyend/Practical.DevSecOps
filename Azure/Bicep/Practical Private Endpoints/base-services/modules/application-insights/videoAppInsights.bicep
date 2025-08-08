// Video API Web App Application Insights Module
param location string
param name string
param logAnalyticsWorkspaceId string
param tags object = {}

// Application Insights for Video API Web App
resource videoApiAppInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: name
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
output appInsightsId string = videoApiAppInsights.id
output appInsightsName string = videoApiAppInsights.name
output appInsightsInstrumentationKey string = videoApiAppInsights.properties.InstrumentationKey
output appInsightsConnectionString string = videoApiAppInsights.properties.ConnectionString
