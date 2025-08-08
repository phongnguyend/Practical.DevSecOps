#!/bin/bash
# deploy-new-subnet.sh
# Bash script to create a new subnet in existing VNet
# Use this when you need additional network isolation or dedicated subnets

# Function to display usage
usage() {
    echo "Usage: $0 -n SUBNET_NAME -p ADDRESS_PREFIX [-r RESOURCE_GROUP] [-v VNET_NAME] [OPTIONS]"
    echo "  -n SUBNET_NAME          (required) Name of the new subnet"
    echo "  -p ADDRESS_PREFIX       (required) Address prefix (e.g., 10.0.3.0/24)"
    echo "  -r RESOURCE_GROUP       Resource group name (default: PracticalPrivateEndpoints)"
    echo "  -v VNET_NAME           Existing VNet name (default: PracticalPrivateEndpoints-vnet)"
    echo "  -e                     Enable private endpoint network policies"
    echo "  -l                     Enable private link service network policies"
    echo "  -s SERVICE_ENDPOINTS   Comma-separated service endpoints (e.g., Microsoft.Storage,Microsoft.Sql)"
    echo "  -d DELEGATIONS         Comma-separated delegations (e.g., Microsoft.Web/serverFarms)"
    echo "  -h                     Show this help message"
    exit 1
}

# Set defaults
RESOURCE_GROUP_NAME="PracticalPrivateEndpoints"
EXISTING_VNET_NAME="PracticalPrivateEndpoints-vnet"
ENABLE_PRIVATE_ENDPOINT_POLICIES=false
ENABLE_PRIVATE_LINK_POLICIES=false
SERVICE_ENDPOINTS=""
DELEGATIONS=""

# Parse command line arguments
while getopts "n:p:r:v:els:d:h" opt; do
    case $opt in
        n) SUBNET_NAME="$OPTARG" ;;
        p) SUBNET_ADDRESS_PREFIX="$OPTARG" ;;
        r) RESOURCE_GROUP_NAME="$OPTARG" ;;
        v) EXISTING_VNET_NAME="$OPTARG" ;;
        e) ENABLE_PRIVATE_ENDPOINT_POLICIES=true ;;
        l) ENABLE_PRIVATE_LINK_POLICIES=true ;;
        s) SERVICE_ENDPOINTS="$OPTARG" ;;
        d) DELEGATIONS="$OPTARG" ;;
        h) usage ;;
        \?) echo "Invalid option -$OPTARG" >&2; usage ;;
    esac
done

# Check if required parameters are provided
if [ -z "$SUBNET_NAME" ] || [ -z "$SUBNET_ADDRESS_PREFIX" ]; then
    echo "Error: Subnet name and address prefix are required"
    usage
fi

echo "Creating new subnet: $SUBNET_NAME"
echo "Address prefix: $SUBNET_ADDRESS_PREFIX"

# Build parameters
PARAMS="subnetName=$SUBNET_NAME subnetAddressPrefix=$SUBNET_ADDRESS_PREFIX existingVnetName=$EXISTING_VNET_NAME"
PARAMS="$PARAMS enablePrivateEndpointNetworkPolicies=$ENABLE_PRIVATE_ENDPOINT_POLICIES"
PARAMS="$PARAMS enablePrivateLinkServiceNetworkPolicies=$ENABLE_PRIVATE_LINK_POLICIES"

# Add service endpoints if provided
if [ -n "$SERVICE_ENDPOINTS" ]; then
    SERVICE_ENDPOINTS_JSON="["
    IFS=',' read -ra ENDPOINTS <<< "$SERVICE_ENDPOINTS"
    for i in "${!ENDPOINTS[@]}"; do
        if [ $i -gt 0 ]; then
            SERVICE_ENDPOINTS_JSON="$SERVICE_ENDPOINTS_JSON,"
        fi
        SERVICE_ENDPOINTS_JSON="$SERVICE_ENDPOINTS_JSON{\"service\":\"${ENDPOINTS[i]}\"}"
    done
    SERVICE_ENDPOINTS_JSON="$SERVICE_ENDPOINTS_JSON]"
    PARAMS="$PARAMS serviceEndpoints=$SERVICE_ENDPOINTS_JSON"
fi

# Add delegations if provided
if [ -n "$DELEGATIONS" ]; then
    DELEGATIONS_JSON="["
    IFS=',' read -ra DELEGATION_ARRAY <<< "$DELEGATIONS"
    for i in "${!DELEGATION_ARRAY[@]}"; do
        if [ $i -gt 0 ]; then
            DELEGATIONS_JSON="$DELEGATIONS_JSON,"
        fi
        DELEGATIONS_JSON="$DELEGATIONS_JSON{\"name\":\"${DELEGATION_ARRAY[i]}\",\"properties\":{\"serviceName\":\"${DELEGATION_ARRAY[i]}\"}}"
    done
    DELEGATIONS_JSON="$DELEGATIONS_JSON]"
    PARAMS="$PARAMS delegations=$DELEGATIONS_JSON"
fi

# Deploy the new subnet
DEPLOYMENT_NAME="subnet-$SUBNET_NAME-$(date +%Y%m%d-%H%M%S)"

if az deployment group create \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --template-file "modules/new-subnet.bicep" \
    --name "$DEPLOYMENT_NAME" \
    --parameters $PARAMS; then
    
    echo "Subnet $SUBNET_NAME created successfully!"
    
    # Get deployment outputs
    OUTPUTS=$(az deployment group show --resource-group "$RESOURCE_GROUP_NAME" --name "$DEPLOYMENT_NAME" --query properties.outputs --output json)
    SUBNET_NAME_OUTPUT=$(echo "$OUTPUTS" | jq -r '.subnetName.value')
    SUBNET_PREFIX_OUTPUT=$(echo "$OUTPUTS" | jq -r '.subnetAddressPrefix.value')
    VNET_NAME_OUTPUT=$(echo "$OUTPUTS" | jq -r '.vnetName.value')
    SUBNET_ID_OUTPUT=$(echo "$OUTPUTS" | jq -r '.subnetId.value')
    
    echo ""
    echo "Subnet Details:"
    echo "Subnet Name: $SUBNET_NAME_OUTPUT"
    echo "Address Prefix: $SUBNET_PREFIX_OUTPUT"
    echo "VNet Name: $VNET_NAME_OUTPUT"
    echo "Subnet ID: $SUBNET_ID_OUTPUT"
    
    echo ""
    echo "Common Use Cases:"
    echo "• Use this subnet for new Web Apps with VNet integration"
    echo "• Create private endpoints in this subnet"
    echo "• Deploy additional services requiring network isolation"
    
    echo ""
    echo "Next Steps:"
    echo "1. Update your templates to reference this subnet when needed"
    echo "2. Configure NSG rules if required"
    echo "3. Use subnet ID: $SUBNET_ID_OUTPUT"
    
else
    echo "Error creating subnet $SUBNET_NAME"
    exit 1
fi

echo ""
echo "Subnet creation completed successfully!"
