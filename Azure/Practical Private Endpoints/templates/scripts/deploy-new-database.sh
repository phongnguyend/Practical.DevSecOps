#!/bin/bash
# deploy-new-database.sh
# Bash script to create a new database on existing SQL Server
# Use this when you need a new database for APIs or Sites

# Function to display usage
usage() {
    echo "Usage: $0 -d DATABASE_NAME [-r RESOURCE_GROUP] [-l LOCATION] [-s SQL_SERVER_NAME]"
    echo "  -d DATABASE_NAME        (required) Name of the database to create"
    echo "  -r RESOURCE_GROUP       Resource group name (default: PracticalPrivateEndpoints)"
    echo "  -l LOCATION             Azure location (default: southeastasia)"
    echo "  -s SQL_SERVER_NAME      Existing SQL Server name (default: PracticalPrivateEndpoints)"
    exit 1
}

# Set defaults
RESOURCE_GROUP_NAME="PracticalPrivateEndpoints"
LOCATION="southeastasia"
EXISTING_SQL_SERVER_NAME="PracticalPrivateEndpoints"

# Parse command line arguments
while getopts "d:r:l:s:h" opt; do
    case $opt in
        d) DATABASE_NAME="$OPTARG" ;;
        r) RESOURCE_GROUP_NAME="$OPTARG" ;;
        l) LOCATION="$OPTARG" ;;
        s) EXISTING_SQL_SERVER_NAME="$OPTARG" ;;
        h) usage ;;
        \?) echo "Invalid option -$OPTARG" >&2; usage ;;
    esac
done

# Check if required parameter is provided
if [ -z "$DATABASE_NAME" ]; then
    echo "Error: Database name is required"
    usage
fi

echo "Creating new database: $DATABASE_NAME"

# Deploy the new database
DEPLOYMENT_NAME="database-$DATABASE_NAME-$(date +%Y%m%d-%H%M%S)"

if az deployment group create \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --template-file "modules/new-database.bicep" \
    --name "$DEPLOYMENT_NAME" \
    --parameters \
        databaseName="$DATABASE_NAME" \
        location="$LOCATION" \
        existingSqlServerName="$EXISTING_SQL_SERVER_NAME"; then
    
    echo "Database $DATABASE_NAME created successfully!"
    
    # Get deployment outputs
    OUTPUTS=$(az deployment group show --resource-group "$RESOURCE_GROUP_NAME" --name "$DEPLOYMENT_NAME" --query properties.outputs --output json)
    DATABASE_OUTPUT=$(echo "$OUTPUTS" | jq -r '.databaseName.value')
    
    echo ""
    echo "Database Details:"
    echo "Database Name: $DATABASE_OUTPUT"
    echo "SQL Server: $EXISTING_SQL_SERVER_NAME"
    echo "Resource Group: $RESOURCE_GROUP_NAME"
    
    echo ""
    echo "Connection String Pattern:"
    echo "Server=$EXISTING_SQL_SERVER_NAME.database.windows.net;Database=$DATABASE_OUTPUT;[Authentication]"
    
    echo ""
    echo "Next Steps:"
    echo "1. Configure your applications to use this database"
    echo "2. Set up appropriate connection strings"
    echo "3. Configure database access permissions if needed"
    
else
    echo "Error creating database $DATABASE_NAME"
    exit 1
fi

echo ""
echo "Database creation completed successfully!"
