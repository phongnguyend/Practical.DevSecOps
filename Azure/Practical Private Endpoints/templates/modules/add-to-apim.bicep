// add-to-apim.bicep - Template to add new API to existing API Management
param apiName string
param existingApiManagementName string
param apiUrl string = 'https://PracticalPrivateEndpoints-${apiName}.azurewebsites.net'

// Reference existing API Management
resource existingApiManagement 'Microsoft.ApiManagement/service@2023-05-01-preview' existing = {
  name: existingApiManagementName
}

// New Backend for the API
resource newBackend 'Microsoft.ApiManagement/service/backends@2023-05-01-preview' = {
  parent: existingApiManagement
  name: '${toLower(apiName)}-backend'
  properties: {
    protocol: 'http'
    url: apiUrl
    description: '${apiName} Backend'
  }
}

// New API
resource newApi 'Microsoft.ApiManagement/service/apis@2023-05-01-preview' = {
  parent: existingApiManagement
  name: toLower(apiName)
  properties: {
    displayName: '${apiName} API'
    apiRevision: '1'
    subscriptionRequired: false
    path: toLower(apiName)
    protocols: ['https']
  }
}

// API Operation
resource newApiOperation 'Microsoft.ApiManagement/service/apis/operations@2023-05-01-preview' = {
  parent: newApi
  name: 'get-all'
  properties: {
    displayName: 'Get All'
    method: 'GET'
    urlTemplate: '/'
    description: 'Get all items from ${apiName}'
  }
}

// API Policy to route to backend
resource newApiPolicy 'Microsoft.ApiManagement/service/apis/policies@2023-05-01-preview' = {
  parent: newApi
  name: 'policy'
  properties: {
    value: '''
      <policies>
        <inbound>
          <base />
          <set-backend-service backend-id="${toLower(apiName)}-backend" />
        </inbound>
        <backend>
          <base />
        </backend>
        <outbound>
          <base />
        </outbound>
        <on-error>
          <base />
        </on-error>
      </policies>
    '''
    format: 'xml'
  }
}

// Outputs
output apiName string = newApi.name
output backendName string = newBackend.name
output apiUrl string = 'https://${existingApiManagement.properties.gatewayUrl}/${toLower(apiName)}'
