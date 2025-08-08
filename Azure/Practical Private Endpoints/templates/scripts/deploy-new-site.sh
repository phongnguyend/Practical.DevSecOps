#!/bin/bash
# deploy-new-site.sh
# Bash script to deploy a new website/site without modifying existing infrastructure
# Sites are automatically integrated with Application Gateway

SITE_NAME=$1
RESOURCE_GROUP=${2:-"PracticalPrivateEndpoints"}
LOCATION=${3:-"southeastasia"}
CREATE_PRIVATE_ENDPOINT=${4:-true}
ENABLE_PUBLIC_ACCESS=${5:-true}
ADD_TO_APPLICATION_GATEWAY=${6:-true}
PATH_PATTERN=${7:-""}
PRIORITY=${8:-100}

if [ -z "$SITE_NAME" ]; then
    echo "Usage: $0 <SITE_NAME> [RESOURCE_GROUP] [LOCATION] [CREATE_PRIVATE_ENDPOINT] [ENABLE_PUBLIC_ACCESS] [ADD_TO_APPLICATION_GATEWAY] [PATH_PATTERN] [PRIORITY]"
    echo "Example: $0 CUSTOMER-PORTAL"
    exit 1
fi

# Set default path pattern if not provided
if [ -z "$PATH_PATTERN" ]; then
    PATH_PATTERN="/$(echo $SITE_NAME | tr '[:upper:]' '[:lower:]')/*"
fi

echo "Deploying new site: $SITE_NAME"

# Deploy the new site
DEPLOYMENT_NAME="site-$SITE_NAME-$(date +%Y%m%d-%H%M%S)"

az deployment group create \
    --resource-group "$RESOURCE_GROUP" \
    --template-file "modules/new-site.bicep" \
    --name "$DEPLOYMENT_NAME" \
    --parameters \
        siteName="$SITE_NAME" \
        location="$LOCATION" \
        createPrivateEndpoint="$CREATE_PRIVATE_ENDPOINT" \
        enablePublicAccess="$ENABLE_PUBLIC_ACCESS" \
        addToApplicationGateway="$ADD_TO_APPLICATION_GATEWAY" \
        applicationGatewayPathPattern="$PATH_PATTERN" \
        applicationGatewayPriority="$PRIORITY"

if [ $? -eq 0 ]; then
    echo "Site $SITE_NAME deployed successfully!"
    
    # Get deployment outputs
    OUTPUTS=$(az deployment group show --resource-group "$RESOURCE_GROUP" --name "$DEPLOYMENT_NAME" --query properties.outputs --output json)
    
    echo ""
    echo "Deployment Details:"
    echo "Web App Name: $(echo "$OUTPUTS" | jq -r '.webAppName.value')"
    echo "Web App URL: $(echo "$OUTPUTS" | jq -r '.webAppUrl.value')"
    echo "Database Name: $(echo "$OUTPUTS" | jq -r '.databaseName.value')"
    
    APPGW_INTEGRATED=$(echo "$OUTPUTS" | jq -r '.applicationGatewayIntegrated.value')
    if [ "$APPGW_INTEGRATED" = "true" ]; then
        echo ""
        echo "Application Gateway Integration:"
        echo "Path Pattern: $(echo "$OUTPUTS" | jq -r '.applicationGatewayPathPattern.value')"
        echo "Application Gateway URL: http://[APPGW-FQDN]$(echo "$OUTPUTS" | jq -r '.applicationGatewayPathPattern.value')"
        echo "Note: Replace [APPGW-FQDN] with your Application Gateway's FQDN"
    fi
    
    PRIVATE_ENDPOINT_ID=$(echo "$OUTPUTS" | jq -r '.privateEndpointId.value')
    if [ "$PRIVATE_ENDPOINT_ID" != "" ] && [ "$PRIVATE_ENDPOINT_ID" != "null" ]; then
        echo "Private Endpoint: Created"
    fi
    
    echo ""
    echo "Next Steps:"
    echo "1. Deploy your website code to: $(echo "$OUTPUTS" | jq -r '.webAppName.value')"
    echo "2. Test site access through Application Gateway"
    echo "3. Configure custom domains if needed"
    
    echo ""
    echo "Site deployment completed successfully!"
else
    echo "Error deploying site $SITE_NAME"
    exit 1
fi
