#!/bin/bash

# deploy-new-app-service.sh
# Deploy a new App Service (Web App) using Bicep template

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Default values
LOCATION=""
APP_SERVICE_PLAN_RESOURCE_GROUP=""
RUNTIME_STACK="DOTNETCORE|8.0"
NET_FRAMEWORK_VERSION="v8.0"
HTTPS_ONLY="true"
CLIENT_AFFINITY_ENABLED="false"
ENABLE_SYSTEM_ASSIGNED_IDENTITY="true"
ENABLE_APPLICATION_INSIGHTS="true"
EXISTING_APPLICATION_INSIGHTS_NAME=""
ENABLE_VNET_INTEGRATION="false"
VNET_NAME="PracticalPrivateEndpoints-vnet"
VNET_INTEGRATION_SUBNET_NAME="default"
CREATE_PRIVATE_ENDPOINT="false"
PRIVATE_ENDPOINT_SUBNET_NAME="private-endpoints"
PUBLIC_NETWORK_ACCESS="true"
APP_SETTINGS="[]"
CONNECTION_STRINGS="[]"
TAGS="{}"

# Valid runtime stacks
VALID_RUNTIME_STACKS=("DOTNETCORE|8.0" "DOTNETCORE|6.0" "DOTNET|8.0" "DOTNET|6.0" "NODE|20-lts" "NODE|18-lts" "PYTHON|3.11" "PYTHON|3.10" "JAVA|17-java17" "JAVA|11-java11" "PHP|8.2" "PHP|8.1")

# Valid .NET Framework versions
VALID_NET_FRAMEWORK_VERSIONS=("v4.0" "v6.0" "v8.0")

# Function to show usage
show_usage() {
    echo "Usage: $0 -g RESOURCE_GROUP -n APP_SERVICE_NAME -p APP_SERVICE_PLAN_NAME [OPTIONS]"
    echo ""
    echo "Required parameters:"
    echo "  -g, --resource-group           Name of the resource group"
    echo "  -n, --app-service-name         Name of the App Service to create"
    echo "  -p, --app-service-plan-name    Name of the existing App Service Plan"
    echo ""
    echo "Optional parameters:"
    echo "  -r, --app-service-plan-rg      Resource group containing the App Service Plan"
    echo "  -l, --location                 Azure region for deployment"
    echo "  -s, --runtime-stack            Runtime stack (default: DOTNETCORE|8.0)"
    echo "  -f, --net-framework-version    .NET Framework version (default: v8.0)"
    echo "  --https-only                   Enable HTTPS only (default: true)"
    echo "  --client-affinity              Enable client affinity (default: false)"
    echo "  --system-identity              Enable system-assigned identity (default: true)"
    echo "  --app-insights                 Enable Application Insights (default: true)"
    echo "  --existing-app-insights        Name of existing Application Insights"
    echo "  --vnet-integration             Enable VNet integration (default: false)"
    echo "  --vnet-name                    VNet name for integration (default: PracticalPrivateEndpoints-vnet)"
    echo "  --vnet-subnet                  Subnet name for VNet integration (default: default)"
    echo "  --private-endpoint             Create private endpoint (default: false)"
    echo "  --pe-subnet                    Subnet name for private endpoint (default: private-endpoints)"
    echo "  --public-access                Allow public network access (default: true)"
    echo "  --app-settings                 App settings as JSON array"
    echo "  --connection-strings           Connection strings as JSON array"
    echo "  --tags                         Tags as JSON object"
    echo "  -h, --help                     Show this help message"
    echo ""
    echo "Valid runtime stacks:"
    for stack in "${VALID_RUNTIME_STACKS[@]}"; do
        echo "  - $stack"
    done
    echo ""
    echo "Examples:"
    echo "  $0 -g MyRG -n my-web-app -p my-plan -s DOTNETCORE|8.0"
    echo "  $0 -g MyRG -n my-node-app -p my-plan -s NODE|20-lts --vnet-integration true --private-endpoint true"
    echo "  $0 -g MyRG -n my-api -p my-plan --app-settings '[{\"name\":\"ENV\",\"value\":\"prod\"}]'"
}

# Function to validate runtime stack
validate_runtime_stack() {
    local stack=$1
    for valid_stack in "${VALID_RUNTIME_STACKS[@]}"; do
        if [[ "$stack" == "$valid_stack" ]]; then
            return 0
        fi
    done
    echo -e "${RED}❌ Invalid runtime stack: $stack${NC}"
    echo "Valid runtime stacks:"
    for valid_stack in "${VALID_RUNTIME_STACKS[@]}"; do
        echo "  - $valid_stack"
    done
    exit 1
}

# Function to validate .NET Framework version
validate_net_framework_version() {
    local version=$1
    for valid_version in "${VALID_NET_FRAMEWORK_VERSIONS[@]}"; do
        if [[ "$version" == "$valid_version" ]]; then
            return 0
        fi
    done
    echo -e "${RED}❌ Invalid .NET Framework version: $version${NC}"
    echo "Valid versions: ${VALID_NET_FRAMEWORK_VERSIONS[*]}"
    exit 1
}

# Function to validate JSON
validate_json() {
    local json_string=$1
    local field_name=$2
    if ! echo "$json_string" | jq empty 2>/dev/null; then
        echo -e "${RED}❌ Invalid JSON format for $field_name${NC}"
        exit 1
    fi
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -g|--resource-group)
            RESOURCE_GROUP="$2"
            shift 2
            ;;
        -n|--app-service-name)
            APP_SERVICE_NAME="$2"
            shift 2
            ;;
        -p|--app-service-plan-name)
            APP_SERVICE_PLAN_NAME="$2"
            shift 2
            ;;
        -r|--app-service-plan-rg)
            APP_SERVICE_PLAN_RESOURCE_GROUP="$2"
            shift 2
            ;;
        -l|--location)
            LOCATION="$2"
            shift 2
            ;;
        -s|--runtime-stack)
            RUNTIME_STACK="$2"
            shift 2
            ;;
        -f|--net-framework-version)
            NET_FRAMEWORK_VERSION="$2"
            shift 2
            ;;
        --https-only)
            HTTPS_ONLY="$2"
            shift 2
            ;;
        --client-affinity)
            CLIENT_AFFINITY_ENABLED="$2"
            shift 2
            ;;
        --system-identity)
            ENABLE_SYSTEM_ASSIGNED_IDENTITY="$2"
            shift 2
            ;;
        --app-insights)
            ENABLE_APPLICATION_INSIGHTS="$2"
            shift 2
            ;;
        --existing-app-insights)
            EXISTING_APPLICATION_INSIGHTS_NAME="$2"
            shift 2
            ;;
        --vnet-integration)
            ENABLE_VNET_INTEGRATION="$2"
            shift 2
            ;;
        --vnet-name)
            VNET_NAME="$2"
            shift 2
            ;;
        --vnet-subnet)
            VNET_INTEGRATION_SUBNET_NAME="$2"
            shift 2
            ;;
        --private-endpoint)
            CREATE_PRIVATE_ENDPOINT="$2"
            shift 2
            ;;
        --pe-subnet)
            PRIVATE_ENDPOINT_SUBNET_NAME="$2"
            shift 2
            ;;
        --public-access)
            PUBLIC_NETWORK_ACCESS="$2"
            shift 2
            ;;
        --app-settings)
            APP_SETTINGS="$2"
            shift 2
            ;;
        --connection-strings)
            CONNECTION_STRINGS="$2"
            shift 2
            ;;
        --tags)
            TAGS="$2"
            shift 2
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            echo -e "${RED}❌ Unknown parameter: $1${NC}"
            show_usage
            exit 1
            ;;
    esac
done

# Validate required parameters
if [[ -z "$RESOURCE_GROUP" ]]; then
    echo -e "${RED}❌ Resource group is required${NC}"
    show_usage
    exit 1
fi

if [[ -z "$APP_SERVICE_NAME" ]]; then
    echo -e "${RED}❌ App Service name is required${NC}"
    show_usage
    exit 1
fi

if [[ -z "$APP_SERVICE_PLAN_NAME" ]]; then
    echo -e "${RED}❌ App Service Plan name is required${NC}"
    show_usage
    exit 1
fi

# Validate runtime stack
validate_runtime_stack "$RUNTIME_STACK"

# Validate .NET Framework version
validate_net_framework_version "$NET_FRAMEWORK_VERSION"

# Validate JSON parameters
validate_json "$APP_SETTINGS" "app-settings"
validate_json "$CONNECTION_STRINGS" "connection-strings"
validate_json "$TAGS" "tags"

# Set default values
if [[ -z "$APP_SERVICE_PLAN_RESOURCE_GROUP" ]]; then
    APP_SERVICE_PLAN_RESOURCE_GROUP="$RESOURCE_GROUP"
fi

# Validate logical dependencies
if [[ "$CREATE_PRIVATE_ENDPOINT" == "true" && "$ENABLE_VNET_INTEGRATION" != "true" ]]; then
    echo -e "${YELLOW}⚠️  Private endpoint requires VNet integration. Enabling VNet integration...${NC}"
    ENABLE_VNET_INTEGRATION="true"
fi

if [[ "$PUBLIC_NETWORK_ACCESS" == "false" && "$CREATE_PRIVATE_ENDPOINT" != "true" ]]; then
    echo -e "${YELLOW}⚠️  Disabling public network access without private endpoint will make the app inaccessible!${NC}"
fi

echo -e "${GREEN}🚀 Starting App Service deployment...${NC}"

# Build parameters JSON
PARAMS_JSON=$(cat <<EOF
{
  "appServiceName": {"value": "$APP_SERVICE_NAME"},
  "existingAppServicePlanName": {"value": "$APP_SERVICE_PLAN_NAME"},
  "appServicePlanResourceGroup": {"value": "$APP_SERVICE_PLAN_RESOURCE_GROUP"},
  "linuxFxVersion": {"value": "$RUNTIME_STACK"},
  "netFrameworkVersion": {"value": "$NET_FRAMEWORK_VERSION"},
  "httpsOnly": {"value": $HTTPS_ONLY},
  "clientAffinityEnabled": {"value": $CLIENT_AFFINITY_ENABLED},
  "enableSystemAssignedIdentity": {"value": $ENABLE_SYSTEM_ASSIGNED_IDENTITY},
  "enableApplicationInsights": {"value": $ENABLE_APPLICATION_INSIGHTS},
  "existingApplicationInsightsName": {"value": "$EXISTING_APPLICATION_INSIGHTS_NAME"},
  "enableVNetIntegration": {"value": $ENABLE_VNET_INTEGRATION},
  "existingVnetName": {"value": "$VNET_NAME"},
  "vnetIntegrationSubnetName": {"value": "$VNET_INTEGRATION_SUBNET_NAME"},
  "createPrivateEndpoint": {"value": $CREATE_PRIVATE_ENDPOINT},
  "privateEndpointSubnetName": {"value": "$PRIVATE_ENDPOINT_SUBNET_NAME"},
  "publicNetworkAccess": {"value": $PUBLIC_NETWORK_ACCESS},
  "appSettings": {"value": $APP_SETTINGS},
  "connectionStrings": {"value": $CONNECTION_STRINGS},
  "tags": {"value": $TAGS}
}
EOF
)

# Add location if specified
if [[ -n "$LOCATION" ]]; then
    PARAMS_JSON=$(echo "$PARAMS_JSON" | jq --arg loc "$LOCATION" '. + {"location": {"value": $loc}}')
fi

echo -e "${YELLOW}📋 Deployment Parameters:${NC}"
echo -e "${WHITE}  Resource Group: $RESOURCE_GROUP${NC}"
echo -e "${WHITE}  App Service Name: $APP_SERVICE_NAME${NC}"
echo -e "${WHITE}  App Service Plan: $APP_SERVICE_PLAN_NAME${NC}"
echo -e "${WHITE}  Runtime Stack: $RUNTIME_STACK${NC}"
echo -e "${WHITE}  VNet Integration: $ENABLE_VNET_INTEGRATION${NC}"
echo -e "${WHITE}  Private Endpoint: $CREATE_PRIVATE_ENDPOINT${NC}"
echo -e "${WHITE}  Application Insights: $ENABLE_APPLICATION_INSIGHTS${NC}"

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_PATH="$SCRIPT_DIR/../modules/new-app-service.bicep"

if [[ ! -f "$TEMPLATE_PATH" ]]; then
    echo -e "${RED}❌ Template file not found: $TEMPLATE_PATH${NC}"
    exit 1
fi

echo -e "${BLUE}🔨 Deploying App Service...${NC}"

# Deploy the template
DEPLOYMENT_OUTPUT=$(az deployment group create \
    --resource-group "$RESOURCE_GROUP" \
    --template-file "$TEMPLATE_PATH" \
    --parameters "$PARAMS_JSON" \
    --output json)

if [[ $? -ne 0 ]]; then
    echo -e "${RED}❌ Deployment failed${NC}"
    exit 1
fi

# Extract outputs
APP_SERVICE_ID=$(echo "$DEPLOYMENT_OUTPUT" | jq -r '.properties.outputs.appServiceId.value')
APP_SERVICE_NAME_OUTPUT=$(echo "$DEPLOYMENT_OUTPUT" | jq -r '.properties.outputs.appServiceName.value')
DEFAULT_HOSTNAME=$(echo "$DEPLOYMENT_OUTPUT" | jq -r '.properties.outputs.defaultHostName.value')
APP_SERVICE_URL=$(echo "$DEPLOYMENT_OUTPUT" | jq -r '.properties.outputs.appServiceUrl.value')
PRINCIPAL_ID=$(echo "$DEPLOYMENT_OUTPUT" | jq -r '.properties.outputs.principalId.value // empty')
APPLICATION_INSIGHTS_ID=$(echo "$DEPLOYMENT_OUTPUT" | jq -r '.properties.outputs.applicationInsightsId.value // empty')
PRIVATE_ENDPOINT_ID=$(echo "$DEPLOYMENT_OUTPUT" | jq -r '.properties.outputs.privateEndpointId.value // empty')
IS_LINUX=$(echo "$DEPLOYMENT_OUTPUT" | jq -r '.properties.outputs.isLinux.value')

echo -e "${GREEN}✅ App Service deployment completed successfully!${NC}"
echo ""
echo -e "${YELLOW}📊 Deployment Results:${NC}"
echo -e "${WHITE}  App Service ID: $APP_SERVICE_ID${NC}"
echo -e "${WHITE}  App Service Name: $APP_SERVICE_NAME_OUTPUT${NC}"
echo -e "${WHITE}  Default Hostname: $DEFAULT_HOSTNAME${NC}"
echo -e "${WHITE}  App Service URL: $APP_SERVICE_URL${NC}"
echo -e "${WHITE}  Is Linux: $IS_LINUX${NC}"

if [[ -n "$PRINCIPAL_ID" ]]; then
    echo -e "${WHITE}  Managed Identity Principal ID: $PRINCIPAL_ID${NC}"
fi

if [[ -n "$APPLICATION_INSIGHTS_ID" ]]; then
    echo -e "${WHITE}  Application Insights ID: $APPLICATION_INSIGHTS_ID${NC}"
fi

if [[ -n "$PRIVATE_ENDPOINT_ID" ]]; then
    echo -e "${WHITE}  Private Endpoint ID: $PRIVATE_ENDPOINT_ID${NC}"
fi

echo ""
echo -e "${CYAN}🎯 Next Steps:${NC}"
echo -e "${WHITE}  1. Deploy your application code to the App Service${NC}"
echo -e "${WHITE}  2. Configure any additional app settings in the Azure portal${NC}"
echo -e "${WHITE}  3. Set up custom domains and SSL certificates if needed${NC}"
echo -e "${WHITE}  4. Configure deployment slots for production workloads${NC}"

if [[ "$ENABLE_VNET_INTEGRATION" == "true" ]]; then
    echo -e "${WHITE}  5. Verify VNet integration connectivity${NC}"
fi

if [[ "$CREATE_PRIVATE_ENDPOINT" == "true" ]]; then
    echo -e "${WHITE}  6. Update DNS settings for private endpoint resolution${NC}"
fi

echo ""
echo -e "${MAGENTA}🌐 Access your App Service:${NC}"
echo -e "${CYAN}  $APP_SERVICE_URL${NC}"
