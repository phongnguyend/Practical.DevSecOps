#!/bin/bash
# deploy-vnet-peering.sh
# Bash script to create VNet peering between two Virtual Networks
# Use this to connect new VNets to existing infrastructure

# Function to display usage
usage() {
    echo "Usage: $0 -l LOCAL_VNET_NAME -i REMOTE_VNET_ID [-r RESOURCE_GROUP] [OPTIONS]"
    echo "  -l LOCAL_VNET_NAME     (required) Name of the local VNet"
    echo "  -i REMOTE_VNET_ID      (required) Full resource ID of remote VNet"
    echo "  -r RESOURCE_GROUP      Resource group name (default: PracticalPrivateEndpoints)"
    echo "  -v                     Disable virtual network access"
    echo "  -f                     Enable forwarded traffic"
    echo "  -g                     Enable gateway transit"
    echo "  -u                     Use remote gateways"
    echo "  -s                     Skip bidirectional peering"
    echo "  -h                     Show this help message"
    exit 1
}

# Set defaults
RESOURCE_GROUP_NAME="PracticalPrivateEndpoints"
ALLOW_VIRTUAL_NETWORK_ACCESS=true
ALLOW_FORWARDED_TRAFFIC=false
ALLOW_GATEWAY_TRANSIT=false
USE_REMOTE_GATEWAYS=false
CREATE_BIDIRECTIONAL_PEERING=true

# Parse command line arguments
while getopts "l:i:r:vfgush" opt; do
    case $opt in
        l) LOCAL_VNET_NAME="$OPTARG" ;;
        i) REMOTE_VNET_ID="$OPTARG" ;;
        r) RESOURCE_GROUP_NAME="$OPTARG" ;;
        v) ALLOW_VIRTUAL_NETWORK_ACCESS=false ;;
        f) ALLOW_FORWARDED_TRAFFIC=true ;;
        g) ALLOW_GATEWAY_TRANSIT=true ;;
        u) USE_REMOTE_GATEWAYS=true ;;
        s) CREATE_BIDIRECTIONAL_PEERING=false ;;
        h) usage ;;
        \?) echo "Invalid option -$OPTARG" >&2; usage ;;
    esac
done

# Check if required parameters are provided
if [ -z "$LOCAL_VNET_NAME" ] || [ -z "$REMOTE_VNET_ID" ]; then
    echo "Error: Local VNet name and remote VNet ID are required"
    usage
fi

# Extract remote VNet details from resource ID
IFS='/' read -ra ID_PARTS <<< "$REMOTE_VNET_ID"
REMOTE_VNET_NAME="${ID_PARTS[-1]}"
REMOTE_RESOURCE_GROUP="${ID_PARTS[4]}"
REMOTE_SUBSCRIPTION="${ID_PARTS[2]}"

echo "Creating VNet peering between:"
echo "Local VNet: $LOCAL_VNET_NAME (in $RESOURCE_GROUP_NAME)"
echo "Remote VNet: $REMOTE_VNET_NAME (in $REMOTE_RESOURCE_GROUP)"

# Deploy peering from local to remote
DEPLOYMENT_NAME="peering-$LOCAL_VNET_NAME-to-$REMOTE_VNET_NAME-$(date +%Y%m%d-%H%M%S)"

if az deployment group create \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --template-file "modules/vnet-peering.bicep" \
    --name "$DEPLOYMENT_NAME" \
    --parameters \
        localVnetName="$LOCAL_VNET_NAME" \
        remoteVnetName="$REMOTE_VNET_NAME" \
        remoteVnetId="$REMOTE_VNET_ID" \
        allowVirtualNetworkAccess="$ALLOW_VIRTUAL_NETWORK_ACCESS" \
        allowForwardedTraffic="$ALLOW_FORWARDED_TRAFFIC" \
        allowGatewayTransit="$ALLOW_GATEWAY_TRANSIT" \
        useRemoteGateways="$USE_REMOTE_GATEWAYS"; then
    
    echo "Peering from $LOCAL_VNET_NAME to $REMOTE_VNET_NAME created successfully!"
    
    # Get deployment outputs
    OUTPUTS=$(az deployment group show --resource-group "$RESOURCE_GROUP_NAME" --name "$DEPLOYMENT_NAME" --query properties.outputs --output json)
    PEERING_NAME=$(echo "$OUTPUTS" | jq -r '.peeringName.value')
    PEERING_STATE=$(echo "$OUTPUTS" | jq -r '.peeringState.value')
    LOCAL_VNET_ID=$(echo "$OUTPUTS" | jq -r '.localVnetId.value')
    REMOTE_VNET_ID_OUTPUT=$(echo "$OUTPUTS" | jq -r '.remoteVnetId.value')
    
    echo ""
    echo "Peering Details:"
    echo "Peering Name: $PEERING_NAME"
    echo "Peering State: $PEERING_STATE"
    echo "Local VNet ID: $LOCAL_VNET_ID"
    echo "Remote VNet ID: $REMOTE_VNET_ID_OUTPUT"
    
    # Create bidirectional peering if requested
    if [ "$CREATE_BIDIRECTIONAL_PEERING" = true ]; then
        echo ""
        echo "Creating reverse peering..."
        
        REVERSE_DEPLOYMENT_NAME="peering-$REMOTE_VNET_NAME-to-$LOCAL_VNET_NAME-$(date +%Y%m%d-%H%M%S)"
        
        # Deploy reverse peering in remote resource group
        if az deployment group create \
            --resource-group "$REMOTE_RESOURCE_GROUP" \
            --subscription "$REMOTE_SUBSCRIPTION" \
            --template-file "modules/vnet-peering.bicep" \
            --name "$REVERSE_DEPLOYMENT_NAME" \
            --parameters \
                localVnetName="$REMOTE_VNET_NAME" \
                remoteVnetName="$LOCAL_VNET_NAME" \
                remoteVnetId="$LOCAL_VNET_ID" \
                allowVirtualNetworkAccess="$ALLOW_VIRTUAL_NETWORK_ACCESS" \
                allowForwardedTraffic="$ALLOW_FORWARDED_TRAFFIC" \
                allowGatewayTransit="$USE_REMOTE_GATEWAYS" \
                useRemoteGateways="$ALLOW_GATEWAY_TRANSIT"; then
            
            echo "Reverse peering from $REMOTE_VNET_NAME to $LOCAL_VNET_NAME created successfully!"
        else
            echo "Warning: Failed to create reverse peering. You may need to create it manually."
        fi
    fi
    
    echo ""
    echo "Peering Configuration:"
    echo "• Virtual Network Access: $([ "$ALLOW_VIRTUAL_NETWORK_ACCESS" = true ] && echo "Enabled" || echo "Disabled")"
    echo "• Forwarded Traffic: $([ "$ALLOW_FORWARDED_TRAFFIC" = true ] && echo "Enabled" || echo "Disabled")"
    echo "• Gateway Transit: $([ "$ALLOW_GATEWAY_TRANSIT" = true ] && echo "Enabled" || echo "Disabled")"
    echo "• Use Remote Gateways: $([ "$USE_REMOTE_GATEWAYS" = true ] && echo "Enabled" || echo "Disabled")"
    
    echo ""
    echo "Next Steps:"
    echo "1. Verify connectivity between VNets"
    echo "2. Update route tables if needed"
    echo "3. Configure private DNS zones for cross-VNet name resolution"
    echo "4. Test network connectivity between resources"
    
else
    echo "Error creating VNet peering"
    exit 1
fi

echo ""
echo "VNet peering completed successfully!"
