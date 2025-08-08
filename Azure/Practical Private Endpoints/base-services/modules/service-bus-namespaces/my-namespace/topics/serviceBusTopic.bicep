// Service Bus Topic Module
param namespaceName string
param topicName string
param maxSizeInMegabytes int = 1024
param defaultMessageTimeToLive string = 'P14D' // 14 days
param duplicateDetectionHistoryTimeWindow string = 'PT10M' // 10 minutes
param enableBatchedOperations bool = true
param enablePartitioning bool = false
param requiresDuplicateDetection bool = false
param supportOrdering bool = false
param autoDeleteOnIdle string = 'P10675199DT2H48M5.4775807S' // Max value

// Reference to existing Service Bus Namespace
resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' existing = {
  name: namespaceName
}

// Service Bus Topic
resource serviceBusTopic 'Microsoft.ServiceBus/namespaces/topics@2022-10-01-preview' = {
  parent: serviceBusNamespace
  name: topicName
  properties: {
    maxSizeInMegabytes: maxSizeInMegabytes
    defaultMessageTimeToLive: defaultMessageTimeToLive
    duplicateDetectionHistoryTimeWindow: duplicateDetectionHistoryTimeWindow
    enableBatchedOperations: enableBatchedOperations
    enablePartitioning: enablePartitioning
    requiresDuplicateDetection: requiresDuplicateDetection
    supportOrdering: supportOrdering
    autoDeleteOnIdle: autoDeleteOnIdle
  }
}

// Outputs
output topicId string = serviceBusTopic.id
output topicName string = serviceBusTopic.name
output topicResourceId string = serviceBusTopic.id
