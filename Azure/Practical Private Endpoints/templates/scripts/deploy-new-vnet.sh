#!/bin/bash
# deploy-new-vnet.sh
# Bash script to create a new Virtual Network
# Use this when you need separate network environments or regions

# Function to display usage
usage() {
    echo "Usage: $0 -n VNET_NAME -a ADDRESS_SPACE [-r RESOURCE_GROUP] [-l LOCATION] [OPTIONS]"
    echo "  -n VNET_NAME           (required) Name of the new VNet"
    echo "  -a ADDRESS_SPACE       (required) Address space (e.g., 10.1.0.0/16)"
    echo "  -r RESOURCE_GROUP      Resource group name (default: PracticalPrivateEndpoints)"
    echo "  -l LOCATION            Azure location (default: southeastasia)"
    echo "  -g                     Skip NSG creation"
    echo "  -d                     Enable DDoS protection"
    echo "  -p DDOS_PLAN_ID        DDoS protection plan resource ID"
    echo "  -s DNS_SERVERS         Comma-separated DNS servers"
    echo "  -h                     Show this help message"
    exit 1
}

# Set defaults
RESOURCE_GROUP_NAME="PracticalPrivateEndpoints"
LOCATION="southeastasia"
CREATE_NSGS=true
ENABLE_DDOS_PROTECTION=false
DDOS_PROTECTION_PLAN_ID=""
DNS_SERVERS=""

# Parse command line arguments
while getopts "n:a:r:l:gdp:s:h" opt; do
    case $opt in
        n) VNET_NAME="$OPTARG" ;;
        a) VNET_ADDRESS_SPACE="$OPTARG" ;;
        r) RESOURCE_GROUP_NAME="$OPTARG" ;;
        l) LOCATION="$OPTARG" ;;
        g) CREATE_NSGS=false ;;
        d) ENABLE_DDOS_PROTECTION=true ;;
        p) DDOS_PROTECTION_PLAN_ID="$OPTARG" ;;
        s) DNS_SERVERS="$OPTARG" ;;
        h) usage ;;
        \?) echo "Invalid option -$OPTARG" >&2; usage ;;
    esac
done

# Check if required parameters are provided
if [ -z "$VNET_NAME" ] || [ -z "$VNET_ADDRESS_SPACE" ]; then
    echo "Error: VNet name and address space are required"
    usage
fi

echo "Creating new Virtual Network: $VNET_NAME"
echo "Address space: $VNET_ADDRESS_SPACE"

# Create default subnets based on address space
IFS='/' read -r BASE_ADDRESS CIDR <<< "$VNET_ADDRESS_SPACE"
IFS='.' read -ra ADDR_PARTS <<< "$BASE_ADDRESS"
BASE_ADDRESS="${ADDR_PARTS[0]}.${ADDR_PARTS[1]}.${ADDR_PARTS[2]}"

# Create subnets JSON
SUBNETS_JSON="[
{
  \"name\": \"default\",
  \"addressPrefix\": \"$BASE_ADDRESS.1.0/24\",
  \"serviceEndpoints\": [],
  \"delegations\": [],
  \"privateEndpointNetworkPolicies\": \"Disabled\",
  \"privateLinkServiceNetworkPolicies\": \"Enabled\"
},
{
  \"name\": \"private-endpoints\",
  \"addressPrefix\": \"$BASE_ADDRESS.2.0/24\",
  \"serviceEndpoints\": [],
  \"delegations\": [],
  \"privateEndpointNetworkPolicies\": \"Disabled\",
  \"privateLinkServiceNetworkPolicies\": \"Enabled\"
}
]"

# Build parameters
PARAMS="vnetName=$VNET_NAME vnetAddressSpace=$VNET_ADDRESS_SPACE location=$LOCATION"
PARAMS="$PARAMS subnets=$SUBNETS_JSON createNSGs=$CREATE_NSGS"
PARAMS="$PARAMS enableDdosProtection=$ENABLE_DDOS_PROTECTION"

# Add optional parameters
if [ -n "$DNS_SERVERS" ]; then
    DNS_SERVERS_JSON="["
    IFS=',' read -ra DNS_ARRAY <<< "$DNS_SERVERS"
    for i in "${!DNS_ARRAY[@]}"; do
        if [ $i -gt 0 ]; then
            DNS_SERVERS_JSON="$DNS_SERVERS_JSON,"
        fi
        DNS_SERVERS_JSON="$DNS_SERVERS_JSON\"${DNS_ARRAY[i]}\""
    done
    DNS_SERVERS_JSON="$DNS_SERVERS_JSON]"
    PARAMS="$PARAMS dnsServers=$DNS_SERVERS_JSON"
fi

if [ "$ENABLE_DDOS_PROTECTION" = true ] && [ -n "$DDOS_PROTECTION_PLAN_ID" ]; then
    PARAMS="$PARAMS ddosProtectionPlanId=$DDOS_PROTECTION_PLAN_ID"
fi

# Deploy the new VNet
DEPLOYMENT_NAME="vnet-$VNET_NAME-$(date +%Y%m%d-%H%M%S)"

if az deployment group create \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --template-file "modules/new-vnet.bicep" \
    --name "$DEPLOYMENT_NAME" \
    --parameters $PARAMS; then
    
    echo "VNet $VNET_NAME created successfully!"
    
    # Get deployment outputs
    OUTPUTS=$(az deployment group show --resource-group "$RESOURCE_GROUP_NAME" --name "$DEPLOYMENT_NAME" --query properties.outputs --output json)
    VNET_NAME_OUTPUT=$(echo "$OUTPUTS" | jq -r '.vnetName.value')
    VNET_ID_OUTPUT=$(echo "$OUTPUTS" | jq -r '.vnetId.value')
    VNET_ADDRESS_OUTPUT=$(echo "$OUTPUTS" | jq -r '.vnetAddressSpace.value')
    
    echo ""
    echo "VNet Details:"
    echo "VNet Name: $VNET_NAME_OUTPUT"
    echo "VNet ID: $VNET_ID_OUTPUT"
    echo "Address Space: $VNET_ADDRESS_OUTPUT"
    
    echo ""
    echo "Subnets Created:"
    echo "$OUTPUTS" | jq -r '.subnetIds.value[] | "• \(.name): \(.addressPrefix)"'
    
    if [ "$CREATE_NSGS" = true ]; then
        echo ""
        echo "Network Security Groups:"
        echo "$OUTPUTS" | jq -r '.nsgIds.value[] | select(.nsgName != "") | "• \(.name): \(.nsgName)"'
    fi
    
    echo ""
    echo "Common Next Steps:"
    echo "1. Create VNet peering if connecting to existing networks"
    echo "2. Deploy services to appropriate subnets"
    echo "3. Configure additional NSG rules if needed"
    echo "4. Set up private DNS zones for name resolution"
    
    echo ""
    echo "VNet Peering Command:"
    echo "./deploy-vnet-peering.sh -l '$VNET_NAME' -i '/subscriptions/.../resourceGroups/.../providers/Microsoft.Network/virtualNetworks/REMOTE-VNET'"
    
else
    echo "Error creating VNet $VNET_NAME"
    exit 1
fi

echo ""
echo "VNet creation completed successfully!"
