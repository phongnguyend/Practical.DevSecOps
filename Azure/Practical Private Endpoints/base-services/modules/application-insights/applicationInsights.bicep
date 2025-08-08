// Application Insights Orchestrator Module - Coordinates all Application Insights for apps
param location string
param logAnalyticsWorkspaceId string
param tags object = {}

// Web App Names
param customerPublicWebAppName string
param customerSiteWebAppName string
param adminPublicWebAppName string
param adminSiteWebAppName string
param videoApiWebAppName string
param musicApiWebAppName string

// Function App Names
param enableFunctionApps bool = false
param adminFunctionAppName string = ''
param customerFunctionAppName string = ''
param musicFunctionAppName string = ''
param videoFunctionAppName string = ''

// Web App Application Insights Modules
module customerPublicAppInsightsModule 'customerPublicAppInsights.bicep' = {
  name: 'customerPublicAppInsightsDeployment'
  params: {
    location: location
    webAppName: customerPublicWebAppName
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    tags: tags
  }
}

module customerSiteAppInsightsModule 'customerSiteAppInsights.bicep' = {
  name: 'customerSiteAppInsightsDeployment'
  params: {
    location: location
    webAppName: customerSiteWebAppName
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    tags: tags
  }
}

module adminPublicAppInsightsModule 'adminPublicAppInsights.bicep' = {
  name: 'adminPublicAppInsightsDeployment'
  params: {
    location: location
    webAppName: adminPublicWebAppName
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    tags: tags
  }
}

module adminSiteAppInsightsModule 'adminSiteAppInsights.bicep' = {
  name: 'adminSiteAppInsightsDeployment'
  params: {
    location: location
    webAppName: adminSiteWebAppName
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    tags: tags
  }
}

module videoApiAppInsightsModule 'videoApiAppInsights.bicep' = {
  name: 'videoApiAppInsightsDeployment'
  params: {
    location: location
    webAppName: videoApiWebAppName
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    tags: tags
  }
}

module musicApiAppInsightsModule 'musicApiAppInsights.bicep' = {
  name: 'musicApiAppInsightsDeployment'
  params: {
    location: location
    webAppName: musicApiWebAppName
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    tags: tags
  }
}

// Function App Application Insights Modules (conditional)
module adminFunctionAppInsightsModule 'adminFunctionAppInsights.bicep' = if (enableFunctionApps) {
  name: 'adminFunctionAppInsightsDeployment'
  params: {
    location: location
    functionAppName: adminFunctionAppName
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    tags: tags
  }
}

module customerFunctionAppInsightsModule 'customerFunctionAppInsights.bicep' = if (enableFunctionApps) {
  name: 'customerFunctionAppInsightsDeployment'
  params: {
    location: location
    functionAppName: customerFunctionAppName
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    tags: tags
  }
}

module musicFunctionAppInsightsModule 'musicFunctionAppInsights.bicep' = if (enableFunctionApps) {
  name: 'musicFunctionAppInsightsDeployment'
  params: {
    location: location
    functionAppName: musicFunctionAppName
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    tags: tags
  }
}

module videoFunctionAppInsightsModule 'videoFunctionAppInsights.bicep' = if (enableFunctionApps) {
  name: 'videoFunctionAppInsightsDeployment'
  params: {
    location: location
    functionAppName: videoFunctionAppName
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    tags: tags
  }
}

// Outputs - Web Apps
output customerPublicWebApp object = {
  applicationInsightsId: customerPublicAppInsightsModule.outputs.appInsightsId
  applicationInsightsName: customerPublicAppInsightsModule.outputs.appInsightsName
  instrumentationKey: customerPublicAppInsightsModule.outputs.appInsightsInstrumentationKey
  connectionString: customerPublicAppInsightsModule.outputs.appInsightsConnectionString
}

output customerSiteWebApp object = {
  applicationInsightsId: customerSiteAppInsightsModule.outputs.appInsightsId
  applicationInsightsName: customerSiteAppInsightsModule.outputs.appInsightsName
  instrumentationKey: customerSiteAppInsightsModule.outputs.appInsightsInstrumentationKey
  connectionString: customerSiteAppInsightsModule.outputs.appInsightsConnectionString
}

output adminPublicWebApp object = {
  applicationInsightsId: adminPublicAppInsightsModule.outputs.appInsightsId
  applicationInsightsName: adminPublicAppInsightsModule.outputs.appInsightsName
  instrumentationKey: adminPublicAppInsightsModule.outputs.appInsightsInstrumentationKey
  connectionString: adminPublicAppInsightsModule.outputs.appInsightsConnectionString
}

output adminSiteWebApp object = {
  applicationInsightsId: adminSiteAppInsightsModule.outputs.appInsightsId
  applicationInsightsName: adminSiteAppInsightsModule.outputs.appInsightsName
  instrumentationKey: adminSiteAppInsightsModule.outputs.appInsightsInstrumentationKey
  connectionString: adminSiteAppInsightsModule.outputs.appInsightsConnectionString
}

output videoApiWebApp object = {
  applicationInsightsId: videoApiAppInsightsModule.outputs.appInsightsId
  applicationInsightsName: videoApiAppInsightsModule.outputs.appInsightsName
  instrumentationKey: videoApiAppInsightsModule.outputs.appInsightsInstrumentationKey
  connectionString: videoApiAppInsightsModule.outputs.appInsightsConnectionString
}

output musicApiWebApp object = {
  applicationInsightsId: musicApiAppInsightsModule.outputs.appInsightsId
  applicationInsightsName: musicApiAppInsightsModule.outputs.appInsightsName
  instrumentationKey: musicApiAppInsightsModule.outputs.appInsightsInstrumentationKey
  connectionString: musicApiAppInsightsModule.outputs.appInsightsConnectionString
}

// Outputs - Function Apps (conditional)
output adminFunctionApp object = enableFunctionApps ? {
  applicationInsightsId: adminFunctionAppInsightsModule!.outputs.appInsightsId
  applicationInsightsName: adminFunctionAppInsightsModule!.outputs.appInsightsName
  instrumentationKey: adminFunctionAppInsightsModule!.outputs.appInsightsInstrumentationKey
  connectionString: adminFunctionAppInsightsModule!.outputs.appInsightsConnectionString
} : {}

output customerFunctionApp object = enableFunctionApps ? {
  applicationInsightsId: customerFunctionAppInsightsModule!.outputs.appInsightsId
  applicationInsightsName: customerFunctionAppInsightsModule!.outputs.appInsightsName
  instrumentationKey: customerFunctionAppInsightsModule!.outputs.appInsightsInstrumentationKey
  connectionString: customerFunctionAppInsightsModule!.outputs.appInsightsConnectionString
} : {}

output musicFunctionApp object = enableFunctionApps ? {
  applicationInsightsId: musicFunctionAppInsightsModule!.outputs.appInsightsId
  applicationInsightsName: musicFunctionAppInsightsModule!.outputs.appInsightsName
  instrumentationKey: musicFunctionAppInsightsModule!.outputs.appInsightsInstrumentationKey
  connectionString: musicFunctionAppInsightsModule!.outputs.appInsightsConnectionString
} : {}

output videoFunctionApp object = enableFunctionApps ? {
  applicationInsightsId: videoFunctionAppInsightsModule!.outputs.appInsightsId
  applicationInsightsName: videoFunctionAppInsightsModule!.outputs.appInsightsName
  instrumentationKey: videoFunctionAppInsightsModule!.outputs.appInsightsInstrumentationKey
  connectionString: videoFunctionAppInsightsModule!.outputs.appInsightsConnectionString
} : {}
