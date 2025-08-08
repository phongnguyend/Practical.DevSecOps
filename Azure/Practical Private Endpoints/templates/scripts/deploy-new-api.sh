#!/bin/bash
# deploy-new-api.sh
# Bash script to deploy a new API without modifying existing infrastructure
# APIs are automatically integrated with API Management

API_NAME=$1
RESOURCE_GROUP=${2:-"PracticalPrivateEndpoints"}
LOCATION=${3:-"southeastasia"}
CREATE_PRIVATE_ENDPOINT=${4:-true}
ENABLE_PUBLIC_ACCESS=${5:-false}
ADD_TO_API_MANAGEMENT=${6:-true}

if [ -z "$API_NAME" ]; then
    echo "Usage: $0 <API_NAME> [RESOURCE_GROUP] [LOCATION] [CREATE_PRIVATE_ENDPOINT] [ENABLE_PUBLIC_ACCESS] [ADD_TO_API_MANAGEMENT]"
    echo "Example: $0 INVENTORY-API"
    exit 1
fi

echo "Deploying new API: $API_NAME"

# Deploy the new API
DEPLOYMENT_NAME="api-$API_NAME-$(date +%Y%m%d-%H%M%S)"

az deployment group create \
    --resource-group "$RESOURCE_GROUP" \
    --template-file "modules/new-api.bicep" \
    --name "$DEPLOYMENT_NAME" \
    --parameters \
        apiName="$API_NAME" \
        location="$LOCATION" \
        createPrivateEndpoint="$CREATE_PRIVATE_ENDPOINT" \
        enablePublicAccess="$ENABLE_PUBLIC_ACCESS" \
        addToApiManagement="$ADD_TO_API_MANAGEMENT"

if [ $? -eq 0 ]; then
    echo "API $API_NAME deployed successfully!"
    
    # Get deployment outputs
    OUTPUTS=$(az deployment group show --resource-group "$RESOURCE_GROUP" --name "$DEPLOYMENT_NAME" --query properties.outputs --output json)
    
    echo ""
    echo "Deployment Details:"
    echo "Web App Name: $(echo "$OUTPUTS" | jq -r '.webAppName.value')"
    echo "Web App URL: $(echo "$OUTPUTS" | jq -r '.webAppUrl.value')"
    echo "Database Name: $(echo "$OUTPUTS" | jq -r '.databaseName.value')"
    
    API_MGMT_INTEGRATED=$(echo "$OUTPUTS" | jq -r '.apiManagementIntegrated.value')
    if [ "$API_MGMT_INTEGRATED" = "true" ]; then
        echo ""
        echo "API Management Integration:"
        echo "API added to API Management: PracticalPrivateEndpoints-apim"
        echo "Access via: https://[APIM-GATEWAY-URL]/api/$(echo $API_NAME | tr '[:upper:]' '[:lower:]')"
        echo "Note: Replace [APIM-GATEWAY-URL] with your API Management gateway URL"
    fi
    
    PRIVATE_ENDPOINT_ID=$(echo "$OUTPUTS" | jq -r '.privateEndpointId.value')
    if [ "$PRIVATE_ENDPOINT_ID" != "" ] && [ "$PRIVATE_ENDPOINT_ID" != "null" ]; then
        echo "Private Endpoint: Created"
    fi
    
    echo ""
    echo "Next Steps:"
    echo "1. Deploy your API application code to: $(echo "$OUTPUTS" | jq -r '.webAppName.value')"
    echo "2. Configure API policies in API Management if needed"
    echo "3. Test API access through API Management gateway"
    
    echo ""
    echo "API deployment completed successfully!"
else
    echo "Error deploying API $API_NAME"
    exit 1
fi
