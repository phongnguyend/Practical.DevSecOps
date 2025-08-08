// Application Insights Orchestrator Module - Coordinates all Application Insights for apps
param location string
param logAnalyticsWorkspaceId string
param tags object = {}

// App Insights Names
param customerAppInsightsName string
param adminAppInsightsName string
param videoAppInsightsName string
param musicAppInsightsName string

// Web App Application Insights Modules

module customerAppInsightsModule 'customerAppInsights.bicep' = {
  name: 'customerAppInsightsDeployment'
  params: {
    location: location
    name: customerAppInsightsName
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    tags: tags
  }
}

module adminAppInsightsModule 'adminAppInsights.bicep' = {
  name: 'adminAppInsightsDeployment'
  params: {
    location: location
    name: adminAppInsightsName
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    tags: tags
  }
}

module videoAppInsightsModule 'videoAppInsights.bicep' = {
  name: 'videoAppInsightsDeployment'
  params: {
    location: location
    name: videoAppInsightsName
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    tags: tags
  }
}

module musicAppInsightsModule 'musicAppInsights.bicep' = {
  name: 'musicAppInsightsDeployment'
  params: {
    location: location
    name: musicAppInsightsName
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    tags: tags
  }
}

// Outputs - Web Apps

output customerAppInsights object = {
  applicationInsightsId: customerAppInsightsModule.outputs.appInsightsId
  applicationInsightsName: customerAppInsightsModule.outputs.appInsightsName
  instrumentationKey: customerAppInsightsModule.outputs.appInsightsInstrumentationKey
  connectionString: customerAppInsightsModule.outputs.appInsightsConnectionString
}

output adminAppInsights object = {
  applicationInsightsId: adminAppInsightsModule.outputs.appInsightsId
  applicationInsightsName: adminAppInsightsModule.outputs.appInsightsName
  instrumentationKey: adminAppInsightsModule.outputs.appInsightsInstrumentationKey
  connectionString: adminAppInsightsModule.outputs.appInsightsConnectionString
}

output videoAppInsights object = {
  applicationInsightsId: videoAppInsightsModule.outputs.appInsightsId
  applicationInsightsName: videoAppInsightsModule.outputs.appInsightsName
  instrumentationKey: videoAppInsightsModule.outputs.appInsightsInstrumentationKey
  connectionString: videoAppInsightsModule.outputs.appInsightsConnectionString
}

output musicAppInsights object = {
  applicationInsightsId: musicAppInsightsModule.outputs.appInsightsId
  applicationInsightsName: musicAppInsightsModule.outputs.appInsightsName
  instrumentationKey: musicAppInsightsModule.outputs.appInsightsInstrumentationKey
  connectionString: musicAppInsightsModule.outputs.appInsightsConnectionString
}
