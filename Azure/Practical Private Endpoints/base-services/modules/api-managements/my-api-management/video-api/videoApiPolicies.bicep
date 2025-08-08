// Video API Policies Module
// This module creates policies for the Video API

@description('The name of the API Management service')
param apiManagementName string

@description('The name of the Video API')
param videoApiName string

// Reference to existing API Management service
resource apiManagement 'Microsoft.ApiManagement/service@2023-05-01-preview' existing = {
  name: apiManagementName
}

// Reference to existing Video API
resource videoApi 'Microsoft.ApiManagement/service/apis@2023-05-01-preview' existing = {
  parent: apiManagement
  name: videoApiName
}

// API Management Policies for Video API
resource videoApiPolicy 'Microsoft.ApiManagement/service/apis/policies@2023-05-01-preview' = {
  parent: videoApi
  name: 'policy'
  properties: {
    value: '''
    <policies>
      <inbound>
        <base />
        <set-backend-service backend-id="video-api-backend" />
        <rate-limit calls="100" renewal-period="60" />
        <cors allow-credentials="true">
          <allowed-origins>
            <origin>*</origin>
          </allowed-origins>
          <allowed-methods>
            <method>GET</method>
            <method>POST</method>
            <method>PUT</method>
            <method>DELETE</method>
            <method>OPTIONS</method>
          </allowed-methods>
          <allowed-headers>
            <header>*</header>
          </allowed-headers>
        </cors>
      </inbound>
      <backend>
        <base />
      </backend>
      <outbound>
        <base />
        <set-header name="X-Powered-By" exists-action="override">
          <value>Azure API Management</value>
        </set-header>
      </outbound>
      <on-error>
        <base />
        <set-header name="ErrorSource" exists-action="override">
          <value>video-api-gateway</value>
        </set-header>
      </on-error>
    </policies>
    '''
    format: 'xml'
  }
}

// Outputs
output videoApiPolicyName string = videoApiPolicy.name
