// Customer Public Web App Application Insights Module
param location string
param webAppName string
param logAnalyticsWorkspaceId string
param tags object = {}

resource customerPublicAppInsights 'Microsoft.Insights/components@2020-02-02' = {
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
output appInsightsId string = customerPublicAppInsights.id
output appInsightsName string = customerPublicAppInsights.name
output appInsightsInstrumentationKey string = customerPublicAppInsights.properties.InstrumentationKey
output appInsightsConnectionString string = customerPublicAppInsights.properties.ConnectionString
