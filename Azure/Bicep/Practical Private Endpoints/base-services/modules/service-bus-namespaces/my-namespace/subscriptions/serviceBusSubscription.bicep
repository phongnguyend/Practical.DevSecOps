// Service Bus Subscription Module
param namespaceName string
param topicName string
param subscriptionName string
param maxDeliveryCount int = 10
param defaultMessageTimeToLive string = 'P14D' // 14 days
param lockDuration string = 'PT1M' // 1 minute
param enableBatchedOperations bool = true
param deadLetteringOnMessageExpiration bool = false
param deadLetteringOnFilterEvaluationExceptions bool = true
param autoDeleteOnIdle string = 'P10675199DT2H48M5.4775807S' // Max value

// Reference to existing Service Bus Namespace
resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' existing = {
  name: namespaceName
}

// Reference to existing Service Bus Topic
resource serviceBusTopic 'Microsoft.ServiceBus/namespaces/topics@2022-10-01-preview' existing = {
  name: topicName
  parent: serviceBusNamespace
}

// Service Bus Subscription
resource serviceBusSubscription 'Microsoft.ServiceBus/namespaces/topics/subscriptions@2022-10-01-preview' = {
  parent: serviceBusTopic
  name: subscriptionName
  properties: {
    maxDeliveryCount: maxDeliveryCount
    defaultMessageTimeToLive: defaultMessageTimeToLive
    lockDuration: lockDuration
    enableBatchedOperations: enableBatchedOperations
    deadLetteringOnMessageExpiration: deadLetteringOnMessageExpiration
    deadLetteringOnFilterEvaluationExceptions: deadLetteringOnFilterEvaluationExceptions
    autoDeleteOnIdle: autoDeleteOnIdle
  }
}

// Outputs
output subscriptionId string = serviceBusSubscription.id
output subscriptionName string = serviceBusSubscription.name
output subscriptionResourceId string = serviceBusSubscription.id
