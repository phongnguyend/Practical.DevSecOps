// Music API Web App Application Insights Module
param location string
param name string
param logAnalyticsWorkspaceId string
param tags object = {}

// Application Insights for Music API Web App
resource musicApiAppInsights 'Microsoft.Insights/components@2020-02-02' = {
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
output appInsightsId string = musicApiAppInsights.id
output appInsightsName string = musicApiAppInsights.name
output appInsightsInstrumentationKey string = musicApiAppInsights.properties.InstrumentationKey
output appInsightsConnectionString string = musicApiAppInsights.properties.ConnectionString
