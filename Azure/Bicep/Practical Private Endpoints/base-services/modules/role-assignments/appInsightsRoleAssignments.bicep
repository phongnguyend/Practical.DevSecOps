// Application Insights Role Assignment Module
// This module assigns multiple RBAC roles to managed identities for Application Insights access
// Deployed at the Application Insights resource scope

targetScope = 'resourceGroup'

param applicationInsightsName string
param roleAssignments array

// Available Application Insights RBAC roles:
// - Monitoring Reader: '43d0d8ad-25c7-4714-9337-8ba259a9fe05'
// - Monitoring Contributor: '749f88d5-cbae-40b8-bcfc-e573ddc772fa'
// - Monitoring Metrics Publisher: '3913510d-42f4-4e42-8a64-420c390055eb'

// Reference to existing Application Insights
resource applicationInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: applicationInsightsName
}

// RBAC Role Assignments scoped to the Application Insights resource
resource appInsightsRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for (assignment, index) in roleAssignments: {
  name: guid(applicationInsights.id, assignment.principalId, assignment.roleDefinitionId)
  scope: applicationInsights
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', assignment.roleDefinitionId)
    principalId: assignment.principalId
    principalType: assignment.?principalType ?? 'ServicePrincipal'
  }
}]

// Outputs
output roleAssignmentIds array = [for i in range(0, length(roleAssignments)): appInsightsRoleAssignment[i].id]
output roleAssignmentNames array = [for i in range(0, length(roleAssignments)): appInsightsRoleAssignment[i].name]
output applicationInsightsId string = applicationInsights.id
