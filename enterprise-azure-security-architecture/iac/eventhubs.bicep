targetScope = 'resourceGroup'

// Source snapshot aligned with the deployed Event Hubs Standard tier.
// Review against the current Azure environment before any redeployment.
@description('Azure region.')
param location string = 'japaneast'

@description('Globally unique Event Hubs namespace name.')
param namespaceName string

@description('Event Hub name.')
param eventHubName string = 'azure-firewall-logs'

resource namespace 'Microsoft.EventHub/namespaces@2024-01-01' = {
  name: namespaceName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Standard'
    capacity: 1
  }
  properties: {
    publicNetworkAccess: 'Enabled'
    minimumTlsVersion: '1.2'
  }
}

resource eventHub 'Microsoft.EventHub/namespaces/eventhubs@2024-01-01' = {
  parent: namespace
  name: eventHubName
  properties: {
    messageRetentionInDays: 1
    partitionCount: 2
  }
}

resource diagnosticsSend 'Microsoft.EventHub/namespaces/authorizationRules@2024-01-01' = {
  parent: namespace
  name: 'azure-diagnostics-send'
  properties: {
    rights: [
      'Manage'
      'Send'
      'Listen'
    ]
  }
}

output eventHubName string = eventHub.name
output diagnosticsAuthorizationRuleId string = diagnosticsSend.id
