#!/bin/bash
# deploy-new-app-service-plan.sh
# Bash script to create a new App Service Plan
# Use this when you need dedicated compute resources for different environments or workloads

# Function to display usage
usage() {
    echo "Usage: $0 -n APP_SERVICE_PLAN_NAME [-r RESOURCE_GROUP] [-l LOCATION] [OPTIONS]"
    echo "  -n APP_SERVICE_PLAN_NAME (required) Name of the App Service Plan"
    echo "  -r RESOURCE_GROUP        Resource group name (default: PracticalPrivateEndpoints)"
    echo "  -l LOCATION              Azure location (default: southeastasia)"
    echo "  -s SKU                   SKU (F1,D1,B1,B2,B3,S1,S2,S3,P1,P2,P3,P1v2,P2v2,P3v2,P1v3,P2v3,P3v3) (default: S1)"
    echo "  -c CAPACITY              Number of instances (1-30) (default: 1)"
    echo "  -o OS                    Operating system (Windows/Linux) (default: Windows)"
    echo "  -z                       Enable zone redundancy (Premium V2/V3 only)"
    echo "  -m MAX_WORKERS           Maximum elastic worker count (1-30) (default: 1)"
    echo "  -t TAGS                  Tags in JSON format (optional)"
    echo "  -h                       Show this help message"
    exit 1
}

# Set defaults
RESOURCE_GROUP_NAME="PracticalPrivateEndpoints"
LOCATION="southeastasia"
SKU="S1"
CAPACITY=1
OS="Windows"
ZONE_REDUNDANT=false
MAX_ELASTIC_WORKER_COUNT=1
TAGS="{}"

# Valid SKUs
VALID_SKUS=("F1" "D1" "B1" "B2" "B3" "S1" "S2" "S3" "P1" "P2" "P3" "P1v2" "P2v2" "P3v2" "P1v3" "P2v3" "P3v3")
PREMIUM_SKUS=("P1v2" "P2v2" "P3v2" "P1v3" "P2v3" "P3v3")

# Function to check if SKU is valid
is_valid_sku() {
    local sku=$1
    for valid_sku in "${VALID_SKUS[@]}"; do
        if [[ "$sku" == "$valid_sku" ]]; then
            return 0
        fi
    done
    return 1
}

# Function to check if SKU supports zone redundancy
supports_zone_redundancy() {
    local sku=$1
    for premium_sku in "${PREMIUM_SKUS[@]}"; do
        if [[ "$sku" == "$premium_sku" ]]; then
            return 0
        fi
    done
    return 1
}

# Parse command line arguments
while getopts "n:r:l:s:c:o:zm:t:h" opt; do
    case $opt in
        n) APP_SERVICE_PLAN_NAME="$OPTARG" ;;
        r) RESOURCE_GROUP_NAME="$OPTARG" ;;
        l) LOCATION="$OPTARG" ;;
        s) SKU="$OPTARG" ;;
        c) CAPACITY="$OPTARG" ;;
        o) OS="$OPTARG" ;;
        z) ZONE_REDUNDANT=true ;;
        m) MAX_ELASTIC_WORKER_COUNT="$OPTARG" ;;
        t) TAGS="$OPTARG" ;;
        h) usage ;;
        \?) echo "Invalid option -$OPTARG" >&2; usage ;;
    esac
done

# Check if required parameters are provided
if [ -z "$APP_SERVICE_PLAN_NAME" ]; then
    echo "Error: App Service Plan name is required"
    usage
fi

# Validate SKU
if ! is_valid_sku "$SKU"; then
    echo "Error: Invalid SKU '$SKU'. Valid SKUs are: ${VALID_SKUS[*]}"
    exit 1
fi

# Validate capacity
if [ "$CAPACITY" -lt 1 ] || [ "$CAPACITY" -gt 30 ]; then
    echo "Error: Capacity must be between 1 and 30"
    exit 1
fi

# Validate OS
if [[ "$OS" != "Windows" && "$OS" != "Linux" ]]; then
    echo "Error: OS must be 'Windows' or 'Linux'"
    exit 1
fi

# Validate zone redundancy
if [ "$ZONE_REDUNDANT" = true ] && ! supports_zone_redundancy "$SKU"; then
    echo "Warning: Zone redundancy is only supported on Premium V2/V3 SKUs. Disabling zone redundancy."
    ZONE_REDUNDANT=false
fi

# Validate max elastic worker count
if [ "$MAX_ELASTIC_WORKER_COUNT" -lt 1 ] || [ "$MAX_ELASTIC_WORKER_COUNT" -gt 30 ]; then
    echo "Error: Maximum elastic worker count must be between 1 and 30"
    exit 1
fi

echo "Creating new App Service Plan: $APP_SERVICE_PLAN_NAME"
echo "SKU: $SKU, Capacity: $CAPACITY, OS: $OS"

# Build parameters
PARAMS="appServicePlanName=$APP_SERVICE_PLAN_NAME location=$LOCATION sku=$SKU capacity=$CAPACITY"
PARAMS="$PARAMS os=$OS zoneRedundant=$ZONE_REDUNDANT maximumElasticWorkerCount=$MAX_ELASTIC_WORKER_COUNT"

# Add tags if provided
if [ "$TAGS" != "{}" ]; then
    PARAMS="$PARAMS tags=$TAGS"
fi

# Deploy the new App Service Plan
DEPLOYMENT_NAME="asp-$APP_SERVICE_PLAN_NAME-$(date +%Y%m%d-%H%M%S)"

if az deployment group create \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --template-file "modules/new-app-service-plan.bicep" \
    --name "$DEPLOYMENT_NAME" \
    --parameters $PARAMS; then
    
    echo "App Service Plan $APP_SERVICE_PLAN_NAME created successfully!"
    
    # Get deployment outputs
    OUTPUTS=$(az deployment group show --resource-group "$RESOURCE_GROUP_NAME" --name "$DEPLOYMENT_NAME" --query properties.outputs --output json)
    ASP_NAME=$(echo "$OUTPUTS" | jq -r '.appServicePlanName.value')
    ASP_ID=$(echo "$OUTPUTS" | jq -r '.appServicePlanId.value')
    SKU_NAME=$(echo "$OUTPUTS" | jq -r '.skuName.value')
    SKU_CAPACITY=$(echo "$OUTPUTS" | jq -r '.skuCapacity.value')
    OPERATING_SYSTEM=$(echo "$OUTPUTS" | jq -r '.operatingSystem.value')
    ZONE_REDUNDANT_OUTPUT=$(echo "$OUTPUTS" | jq -r '.zoneRedundant.value')
    LOCATION_OUTPUT=$(echo "$OUTPUTS" | jq -r '.location.value')
    
    echo ""
    echo "App Service Plan Details:"
    echo "Name: $ASP_NAME"
    echo "ID: $ASP_ID"
    echo "SKU: $SKU_NAME"
    echo "Capacity: $SKU_CAPACITY"
    echo "Operating System: $OPERATING_SYSTEM"
    echo "Zone Redundant: $ZONE_REDUNDANT_OUTPUT"
    echo "Location: $LOCATION_OUTPUT"
    
    echo ""
    echo "SKU Information:"
    case $SKU in
        F1) echo "• Free tier - Limited to 60 minutes/day, 1GB RAM" ;;
        D1) echo "• Shared tier - 240 minutes/day, 1GB RAM" ;;
        B*) echo "• Basic tier - Dedicated compute, custom domains, SSL" ;;
        S*) echo "• Standard tier - Auto-scaling, staging slots, daily backups" ;;
        P*) echo "• Premium tier - Enhanced performance, VNet integration, advanced scaling" ;;
    esac
    
    echo ""
    echo "Common Use Cases:"
    echo "• Host web applications and APIs"
    echo "• Dedicated compute for production workloads"
    echo "• Environment separation (dev/test/prod)"
    echo "• Auto-scaling for variable workloads"
    
    echo ""
    echo "Next Steps:"
    echo "1. Deploy web apps to this App Service Plan"
    echo "2. Configure auto-scaling rules if needed"
    echo "3. Set up monitoring and alerts"
    echo "4. Configure networking (VNet integration, private endpoints)"
    
    echo ""
    echo "App Service Plan ID for reference:"
    echo "$ASP_ID"
    
else
    echo "Error creating App Service Plan $APP_SERVICE_PLAN_NAME"
    exit 1
fi

echo ""
echo "App Service Plan creation completed successfully!"
