// Service Bus Queue Module
param namespaceName string
param queueName string
param maxSizeInMegabytes int = 1024
param maxDeliveryCount int = 10
param defaultMessageTimeToLive string = 'P14D' // 14 days
param duplicateDetectionHistoryTimeWindow string = 'PT10M' // 10 minutes
param lockDuration string = 'PT1M' // 1 minute
param enableBatchedOperations bool = true
param enablePartitioning bool = false
param requiresDuplicateDetection bool = false
param requiresSession bool = false
param deadLetteringOnMessageExpiration bool = false
param autoDeleteOnIdle string = 'P10675199DT2H48M5.4775807S' // Max value

// Reference to existing Service Bus Namespace
resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' existing = {
  name: namespaceName
}

// Service Bus Queue
resource serviceBusQueue 'Microsoft.ServiceBus/namespaces/queues@2022-10-01-preview' = {
  parent: serviceBusNamespace
  name: queueName
  properties: {
    maxSizeInMegabytes: maxSizeInMegabytes
    maxDeliveryCount: maxDeliveryCount
    defaultMessageTimeToLive: defaultMessageTimeToLive
    duplicateDetectionHistoryTimeWindow: duplicateDetectionHistoryTimeWindow
    lockDuration: lockDuration
    enableBatchedOperations: enableBatchedOperations
    enablePartitioning: enablePartitioning
    requiresDuplicateDetection: requiresDuplicateDetection
    requiresSession: requiresSession
    deadLetteringOnMessageExpiration: deadLetteringOnMessageExpiration
    autoDeleteOnIdle: autoDeleteOnIdle
  }
}

// Outputs
output queueId string = serviceBusQueue.id
output queueName string = serviceBusQueue.name
output queueResourceId string = serviceBusQueue.id
