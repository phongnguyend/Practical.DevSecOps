// Product API Policies Module
// This module creates policies for the Product API

@description('The name of the API Management service')
param apiManagementName string

@description('The name of the Product API')
param productApiName string

// Reference to existing API Management service (from base-services)
resource apiManagement 'Microsoft.ApiManagement/service@2023-05-01-preview' existing = {
  name: apiManagementName
}

// Reference to existing Product API
resource productApi 'Microsoft.ApiManagement/service/apis@2023-05-01-preview' existing = {
  parent: apiManagement
  name: productApiName
}

// API Management Policies for Product API
resource productApiPolicy 'Microsoft.ApiManagement/service/apis/policies@2023-05-01-preview' = {
  parent: productApi
  name: 'policy'
  properties: {
    value: '''
    <policies>
      <inbound>
        <base />
        <set-backend-service backend-id="product-api-backend" />
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
        <set-header name="X-API-Service" exists-action="override">
          <value>product-service</value>
        </set-header>
      </inbound>
      <backend>
        <base />
      </backend>
      <outbound>
        <base />
        <set-header name="X-Powered-By" exists-action="override">
          <value>Azure API Management - Product Service</value>
        </set-header>
        <set-header name="X-API-Version" exists-action="override">
          <value>v1.0</value>
        </set-header>
      </outbound>
      <on-error>
        <base />
        <set-header name="ErrorSource" exists-action="override">
          <value>product-api-gateway</value>
        </set-header>
        <set-header name="X-Error-Service" exists-action="override">
          <value>product-service</value>
        </set-header>
      </on-error>
    </policies>
    '''
    format: 'xml'
  }
}

// Outputs
output productApiPolicyName string = productApiPolicy.name
