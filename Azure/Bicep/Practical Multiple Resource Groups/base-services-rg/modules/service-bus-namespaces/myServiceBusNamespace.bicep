// Service Bus Namespace Module
param location string
param namespaceName string
param sku string
param capacity int
param zoneRedundant bool
param createPrivateEndpoint bool
param privateEndpointSubnetId string
param privateDnsZoneId string
param tags object

// Service Bus Topics, Queues, and Subscriptions
param topicNames array
param queueNames array
// subscriptions parameter expects an array of objects with the following structure:
// [
//   {
//     topicName: 'topic1'
//     subscriptionName: 'subscription1'
//     requiresSession: true
//   },
//   {
//     topicName: 'topic2'
//     subscriptionName: 'subscription2'
//     requiresSession: false
//   }
// ]
param subscriptions array

// Role Assignments for Service Bus access
param roleAssignments array

// Network access configuration  
param allowedSubnetIds array
param allowedIpRanges array

// Service Bus Namespace
resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' = {
  name: namespaceName
  location: location
  tags: tags
  sku: {
    name: sku
    tier: sku
    capacity: capacity
  }
  properties: {
    minimumTlsVersion: '1.2'
    publicNetworkAccess: createPrivateEndpoint ? 'Disabled' : 'Enabled'
    zoneRedundant: zoneRedundant
    disableLocalAuth: false
  }
}

// Service Bus Network Rule Set
resource serviceBusNetworkRuleSet 'Microsoft.ServiceBus/namespaces/networkRuleSets@2022-10-01-preview' = if (length(allowedSubnetIds) > 0 || length(allowedIpRanges) > 0) {
  parent: serviceBusNamespace
  name: 'default'
  properties: {
    defaultAction: 'Deny'
    virtualNetworkRules: [
      for subnetId in allowedSubnetIds: {
        subnet: {
          id: subnetId
        }
        ignoreMissingVnetServiceEndpoint: false
      }
    ]
    ipRules: [
      for ipRange in allowedIpRanges: {
        ipMask: ipRange
        action: 'Allow'
      }
    ]
    trustedServiceAccessEnabled: true
  }
}

// Service Bus Topics
resource serviceBusTopics 'Microsoft.ServiceBus/namespaces/topics@2022-10-01-preview' = [
  for topicName in topicNames: {
    parent: serviceBusNamespace
    name: topicName
    properties: {
      maxMessageSizeInKilobytes: 256
      defaultMessageTimeToLive: 'P14D'
      maxSizeInMegabytes: 1024
      requiresDuplicateDetection: false
      duplicateDetectionHistoryTimeWindow: 'PT10M'
      enableBatchedOperations: true
      status: 'Active'
      supportOrdering: false
      autoDeleteOnIdle: 'P10675199DT2H48M5.4775807S'
      enablePartitioning: false
      enableExpress: false
    }
  }
]

// Service Bus Queues  
resource serviceBusQueues 'Microsoft.ServiceBus/namespaces/queues@2022-10-01-preview' = [
  for queueName in queueNames: {
    parent: serviceBusNamespace
    name: queueName
    properties: {
      maxSizeInMegabytes: 1024
      maxDeliveryCount: 10
      defaultMessageTimeToLive: 'P14D' // 14 days
      duplicateDetectionHistoryTimeWindow: 'PT10M' // 10 minutes
      lockDuration: 'PT1M' // 1 minute
      enableBatchedOperations: true
      enablePartitioning: false
      requiresDuplicateDetection: false
      requiresSession: false
      deadLetteringOnMessageExpiration: false
      autoDeleteOnIdle: 'P10675199DT2H48M5.4775807S' // Max value
    }
  }
]

// Service Bus Subscriptions
resource serviceBusSubscriptions 'Microsoft.ServiceBus/namespaces/topics/subscriptions@2022-10-01-preview' = [
  for subscription in subscriptions: {
    parent: serviceBusTopics[indexOf(topicNames, subscription.topicName)]
    name: subscription.subscriptionName
    properties: {
      isClientAffine: false
      lockDuration: 'PT1M'
      requiresSession: subscription.requiresSession
      defaultMessageTimeToLive: 'P14D'
      deadLetteringOnMessageExpiration: false
      deadLetteringOnFilterEvaluationExceptions: false
      maxDeliveryCount: 10
      status: 'Active'
      enableBatchedOperations: true
      autoDeleteOnIdle: 'P10675198DT2H48M5S'
    }
  }
]

// Role Assignments for Service Bus access
resource serviceBusRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for assignment in roleAssignments: {
    name: guid(serviceBusNamespace.id, assignment.principalId, assignment.roleDefinitionId)
    scope: serviceBusNamespace
    properties: {
      roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', assignment.roleDefinitionId)
      principalId: assignment.principalId
      principalType: 'ServicePrincipal'
    }
  }
]

// Private Endpoint for Service Bus Namespace (conditional)
resource serviceBusPrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-09-01' = if (createPrivateEndpoint && !empty(privateEndpointSubnetId)) {
  name: '${namespaceName}-pe'
  location: location
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${namespaceName}-psc'
        properties: {
          privateLinkServiceId: serviceBusNamespace.id
          groupIds: [
            'namespace'
          ]
        }
      }
    ]
  }
  tags: tags
}

// Private DNS Zone Group for Private Endpoint (conditional)
resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-09-01' = if (createPrivateEndpoint && !empty(privateDnsZoneId)) {
  parent: serviceBusPrivateEndpoint
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'servicebus-config'
        properties: {
          privateDnsZoneId: privateDnsZoneId
        }
      }
    ]
  }
}

// Outputs
output serviceBusNamespaceId string = serviceBusNamespace.id
output serviceBusNamespaceName string = serviceBusNamespace.name
output serviceBusNamespaceHostName string = serviceBusNamespace.properties.serviceBusEndpoint
output hasPrivateEndpoint bool = createPrivateEndpoint && !empty(privateEndpointSubnetId)
output privateEndpointId string = createPrivateEndpoint ? serviceBusPrivateEndpoint.id : ''
output privateEndpointName string = createPrivateEndpoint ? serviceBusPrivateEndpoint.name : ''

// Role Definition IDs for Service Bus
output serviceBusDataOwnerRoleId string = '090c5cfd-751d-490a-894a-3ce6f1109419'
output serviceBusDataReceiverRoleId string = '4f6d3b9b-027b-4f4c-9142-0e5a2a2247e0'
output serviceBusDataSenderRoleId string = '69a216fc-b8fb-44d8-bc22-1f3c2cd27a39'
output serviceBusDataContributorRoleId string = '8d3b2e04-d1a1-4c5b-90ae-ff1c3a4de2f6'
