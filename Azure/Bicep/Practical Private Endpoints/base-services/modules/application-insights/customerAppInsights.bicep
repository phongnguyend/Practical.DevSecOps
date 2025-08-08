// Customer Site Web App Application Insights Module
param location string
param name string
param logAnalyticsWorkspaceId string
param tags object = {}

// Application Insights for Customer Site Web App
resource customerSiteAppInsights 'Microsoft.Insights/components@2020-02-02' = {
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
output appInsightsId string = customerSiteAppInsights.id
output appInsightsName string = customerSiteAppInsights.name
output appInsightsInstrumentationKey string = customerSiteAppInsights.properties.InstrumentationKey
output appInsightsConnectionString string = customerSiteAppInsights.properties.ConnectionString
