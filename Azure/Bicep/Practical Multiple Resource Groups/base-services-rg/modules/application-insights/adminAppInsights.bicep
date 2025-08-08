// Admin Site Web App Application Insights Module
param location string
param name string
param logAnalyticsWorkspaceId string
param tags object = {}

// Application Insights for Admin Site Web App
resource adminSiteAppInsights 'Microsoft.Insights/components@2020-02-02' = {
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
output appInsightsId string = adminSiteAppInsights.id
output appInsightsName string = adminSiteAppInsights.name
output appInsightsInstrumentationKey string = adminSiteAppInsights.properties.InstrumentationKey
output appInsightsConnectionString string = adminSiteAppInsights.properties.ConnectionString
