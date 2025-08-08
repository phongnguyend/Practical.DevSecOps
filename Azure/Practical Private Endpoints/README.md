# Practical Private Endpoints Infrastructure

This project demonstrates Azure private endpoints implementation with a comprehensive infrastructure including web apps, SQL databases, Application Gateway, and private DNS zones. The project now includes modular templates for extending the infrastructure without modifying existing resources.

## Architecture Overview

The infrastructure includes:

- **Public Web Applications** (accessible through Application Gateway):
  - `PracticalPrivateEndpoints-CUSTOMER-PUBLIC` - Customer-facing public web application
  - `PracticalPrivateEndpoints-ADMIN-PUBLIC` - Admin-facing public web application

- **Private Web Applications** (accessible only via private endpoints):
  - `PracticalPrivateEndpoints-CUSTOMER-SITE` - Customer-facing private application  
  - `PracticalPrivateEndpoints-ADMIN-SITE` - Admin-facing private application

- **API Applications** (accessible through API Management with private network access):
  - `PracticalPrivateEndpoints-VIDEO-API` - Video content API
  - `PracticalPrivateEndpoints-MUSIC-API` - Music content API

- **Supporting Infrastructure**:
  - Virtual Network with subnets for Application Gateway, Private Endpoints, API Management, and Test VM
  - SQL Server with databases for customer, admin, video, and music applications
  - Application Gateway for load balancing public web apps
  - API Management service for managing and securing APIs (internal VNet deployment)
  - Private endpoints for CUSTOMER-SITE and ADMIN-SITE
  - Private DNS zones for internal domain resolution
  - Test VM for accessing private endpoints

## Extensible Infrastructure

### Modular Templates for Growth

The infrastructure now supports adding new services without modifying existing resources:

- **APIs**: Deploy new APIs with automatic API Management integration
- **Sites**: Deploy new Sites with automatic Application Gateway integration  
- **Databases**: Create databases separately for sharing between services
- **Subnets**: Add new subnets for network isolation and organization

## Project Structure

The infrastructure is organized using Bicep modules for better maintainability and separated into two main areas:

### Initial Infrastructure
```
initial/
├── main.bicep                    # Main template with core infrastructure
└── modules/
    ├── virtualNetwork.bicep      # Virtual Network module
    ├── apiManagement.bicep       # API Management module
    ├── testVM.bicep              # Test Virtual Machine module
    └── sqlDatabase.bicep         # SQL Server and Databases module
```

### Extensible Microservice Templates
```
templates/
├── modules/
│   ├── new-api.bicep             # Deploy new APIs with APIM integration
│   ├── new-site.bicep            # Deploy new Sites with App Gateway integration
│   ├── new-database.bicep        # Create new databases on existing SQL Server
│   ├── new-app-service-plan.bicep # Create new App Service Plans
│   ├── new-app-service.bicep     # Create new App Services (Web Apps)
│   ├── new-subnet.bicep          # Add new subnets to existing VNet
│   ├── new-vnet.bicep            # Create new Virtual Networks
│   ├── vnet-peering.bicep        # Create VNet peering connections
│   ├── add-to-apim.bicep         # API Management integration module
│   └── add-to-application-gateway.bicep  # Application Gateway integration module
└── scripts/
    ├── deploy-new-api.ps1        # PowerShell script for new APIs
    ├── deploy-new-api.sh         # Bash script for new APIs
    ├── deploy-new-site.ps1       # PowerShell script for new Sites
    ├── deploy-new-site.sh        # Bash script for new Sites
    ├── deploy-new-database.ps1   # PowerShell script for new databases
    ├── deploy-new-database.sh    # Bash script for new databases
    ├── deploy-new-app-service-plan.ps1 # PowerShell script for new App Service Plans
    ├── deploy-new-app-service-plan.sh  # Bash script for new App Service Plans
    ├── deploy-new-app-service.ps1 # PowerShell script for new App Services
    ├── deploy-new-app-service.sh  # Bash script for new App Services
    ├── deploy-new-subnet.ps1     # PowerShell script for new subnets
    ├── deploy-new-subnet.sh      # Bash script for new subnets
    ├── deploy-new-vnet.ps1       # PowerShell script for new VNets
    ├── deploy-new-vnet.sh        # Bash script for new VNets
    ├── deploy-vnet-peering.ps1   # PowerShell script for VNet peering
    └── deploy-vnet-peering.sh    # Bash script for VNet peering
```

### Additional Files
```
├── README.md                     # This comprehensive documentation
└── azure-pipelines.infra.yml    # Azure DevOps pipeline for initial infrastructure
```

### Modules

- **virtualNetwork.bicep**: Contains the Virtual Network configuration including:
  - VNet with customizable address space
  - Application Gateway subnet
  - Private Endpoint subnet  
  - Test VM subnet
  - API Management subnet with Network Security Group (NSG)
  - Proper subnet configurations for each use case
  - NSG with API Management-specific security rules

- **apiManagement.bicep**: Contains all API Management resources including:
  - API Management service (Basic tier, parameterized SKU) with internal VNet deployment
  - Configurable SKU (Basic, Standard, Premium) and capacity scaling
  - Video and Music API definitions
  - API operations (GET, POST)
  - Rate limiting and quota policies
  - Backend service configurations

- **testVM.bicep**: Contains the Test Virtual Machine resources including:
  - Windows Server 2022 Virtual Machine
  - Network Interface with optional public IP
  - Network Security Group with RDP and HTTP/HTTPS rules
  - Configurable VM size and credentials
  - Flexible public IP assignment (enabled/disabled)

- **sqlDatabase.bicep**: Contains the SQL Server and database resources including:
  - SQL Server with configurable admin credentials
  - Firewall rule allowing Azure services
  - Multiple SQL databases with Basic tier
  - Proper backup storage redundancy settings
  - Comprehensive outputs for connection information

## Extensible Infrastructure Templates

### Additional Templates for Growth

The project includes modular templates for extending infrastructure without modifying existing resources:

*All extensible templates are located in the `templates/` folder*

### Key Features of Extensible Templates

- **🔒 Security First**: Private endpoints and VNet integration by default
- **🔧 Modular Design**: Add services without modifying existing infrastructure
- **📊 Proper Integration**: APIs→API Management, Sites→Application Gateway
- **🎯 Best Practices**: Dynamic lookups, meaningful parameters, shared databases
- **🌐 Network Flexibility**: Create new VNets and peering connections as needed
- **⚡ Compute Flexibility**: Create dedicated App Service Plans for different workloads
- **🌐 App Service Deployment**: Deploy web applications with multiple runtime stacks (Node.js, .NET, Python, Java, PHP)
- **🔗 Smart Connectivity**: Automatic VNet integration and private endpoint support for App Services

### Quick Examples

#### Deploy New API
```powershell
# PowerShell
.\templates\scripts\deploy-new-api.ps1 -ApiName "INVENTORY-API"

# Bash  
./templates/scripts/deploy-new-api.sh -a "INVENTORY-API"
```

#### Deploy New Site
```powershell
# PowerShell
.\templates\scripts\deploy-new-site.ps1 -SiteName "CUSTOMER-PORTAL" -PathPattern "/customers/*" -Priority 200

# Bash
./templates/scripts/deploy-new-site.sh -s "CUSTOMER-PORTAL" -p "/customers/*" -r 200
```

#### Create New Database
```powershell
# PowerShell
.\templates\scripts\deploy-new-database.ps1 -DatabaseName "InventoryDB"

# Bash
./templates/scripts/deploy-new-database.sh -d "InventoryDB"
```

#### Create New App Service Plan
```powershell
# PowerShell
.\templates\scripts\deploy-new-app-service-plan.ps1 -AppServicePlanName "production-asp" -Sku "P1v3" -Capacity 2

# Bash
./templates/scripts/deploy-new-app-service-plan.sh -n "production-asp" -s "P1v3" -c 2
```

#### Create New App Service (Web App)
```powershell
# PowerShell - Basic .NET app
.\templates\scripts\deploy-new-app-service.ps1 -AppServiceName "my-web-app" -AppServicePlanName "production-asp" -RuntimeStack "DOTNETCORE|8.0"

# PowerShell - Node.js app with VNet integration
.\templates\scripts\deploy-new-app-service.ps1 -AppServiceName "my-node-app" -AppServicePlanName "production-asp" -RuntimeStack "NODE|20-lts" -EnableVNetIntegration $true

# Bash - Python app with private endpoint
./templates/scripts/deploy-new-app-service.sh -n "my-python-app" -p "production-asp" -s "PYTHON|3.11" --vnet-integration true --private-endpoint true

# PowerShell - With custom app settings
$appSettings = @{
    "ENVIRONMENT" = "Production"
    "API_KEY" = "secret-key"
}
.\templates\scripts\deploy-new-app-service.ps1 -AppServiceName "my-api" -AppServicePlanName "production-asp" -AppSettings $appSettings
```

#### Create New Subnet
```powershell
# PowerShell
.\templates\scripts\deploy-new-subnet.ps1 -SubnetName "api-subnet" -SubnetAddressPrefix "10.0.3.0/24"

# Bash
./templates/scripts/deploy-new-subnet.sh -n "api-subnet" -p "10.0.3.0/24"
```

#### Create New VNet
```powershell
# PowerShell
.\templates\scripts\deploy-new-vnet.ps1 -VnetName "dev-vnet" -VnetAddressSpace "10.1.0.0/16"

# Bash
./templates/scripts/deploy-new-vnet.sh -n "dev-vnet" -a "10.1.0.0/16"
```

#### Create VNet Peering
```powershell
# PowerShell
.\templates\scripts\deploy-vnet-peering.ps1 -LocalVnetName "dev-vnet" -RemoteVnetId "/subscriptions/.../resourceGroups/.../providers/Microsoft.Network/virtualNetworks/prod-vnet"

# Bash
./templates/scripts/deploy-vnet-peering.sh -l "dev-vnet" -i "/subscriptions/.../resourceGroups/.../providers/Microsoft.Network/virtualNetworks/prod-vnet"
```

## Deployment Instructions

### Prerequisites

- Azure CLI installed and configured
- PowerShell (Windows) or Bash (Linux/macOS)
- Appropriate Azure subscription permissions to create resources

**Important**: When using the extensible microservice templates, run the deployment scripts from the `templates/scripts/` directory, as the scripts reference modules using relative paths.

### 1. Login to Azure

```powershell
# PowerShell
az login
az account set --subscription "your-subscription-id"
```

```bash
# Bash
az login
az account set --subscription "your-subscription-id"
```

### 2. Create Resource Group

```powershell
# PowerShell
$resourceGroupName = "PracticalPrivateEndpoints"
$location = "southeastasia"

az group create --name $resourceGroupName --location $location
```

```bash
# Bash
RESOURCE_GROUP_NAME="PracticalPrivateEndpoints"
LOCATION="southeastasia"

az group create --name $RESOURCE_GROUP_NAME --location $LOCATION
```

### 3. Deploy Bicep Template

#### Option A: Deploy with Default Parameters

```powershell
# PowerShell
$resourceGroupName = "PracticalPrivateEndpoints"
$deploymentName = "practical-private-endpoints-$(Get-Date -Format 'yyyyMMdd-HHmmss')"

az deployment group create `
  --resource-group $resourceGroupName `
  --template-file initial/main.bicep `
  --name $deploymentName
```

```bash
# Bash
RESOURCE_GROUP_NAME="PracticalPrivateEndpoints"
DEPLOYMENT_NAME="practical-private-endpoints-$(date +%Y%m%d-%H%M%S)"

az deployment group create \
  --resource-group $RESOURCE_GROUP_NAME \
  --template-file initial/main.bicep \
  --name $DEPLOYMENT_NAME
```

#### Option B: Deploy with Custom Parameters

```powershell
# PowerShell
$resourceGroupName = "PracticalPrivateEndpoints"
$deploymentName = "practical-private-endpoints-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
$adminPassword = Read-Host "Enter SQL Admin Password" -AsSecureString
$vmAdminPassword = Read-Host "Enter VM Admin Password" -AsSecureString

az deployment group create `
  --resource-group $resourceGroupName `
  --template-file initial/main.bicep `
  --name $deploymentName `
  --parameters `
    location="southeastasia" `
    sqlServerName="MyPracticalPrivateEndpoints" `
    adminUsername="sqladmin" `
    adminPassword=$adminPassword `
    vmAdminUsername="testadmin" `
    vmAdminPassword=$vmAdminPassword
```

```bash
# Bash
RESOURCE_GROUP_NAME="PracticalPrivateEndpoints"
DEPLOYMENT_NAME="practical-private-endpoints-$(date +%Y%m%d-%H%M%S)"

echo "Enter SQL Admin Password:"
read -s ADMIN_PASSWORD
echo "Enter VM Admin Password:"
read -s VM_ADMIN_PASSWORD

az deployment group create \
  --resource-group $RESOURCE_GROUP_NAME \
  --template-file initial/main.bicep \
  --name $DEPLOYMENT_NAME \
  --parameters \
    location="southeastasia" \
    sqlServerName="MyPracticalPrivateEndpoints" \
    adminUsername="sqladmin" \
    adminPassword="$ADMIN_PASSWORD" \
    vmAdminUsername="testadmin" \
    vmAdminPassword="$VM_ADMIN_PASSWORD"
```

#### Option C: Deploy with Parameters File

Create a `parameters.json` file:

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "location": {
      "value": "southeastasia"
    },
    "sqlServerName": {
      "value": "MyPracticalPrivateEndpoints"
    },
    "adminUsername": {
      "value": "sqladmin"
    },
    "adminPassword": {
      "value": "YourSecurePassword123!@#"
    },
    "vmAdminUsername": {
      "value": "testadmin"
    },
    "vmAdminPassword": {
      "value": "YourVMPassword123!@#"
    }
  }
}
```

Then deploy:

```powershell
# PowerShell
$resourceGroupName = "PracticalPrivateEndpoints"
$deploymentName = "practical-private-endpoints-$(Get-Date -Format 'yyyyMMdd-HHmmss')"

az deployment group create `
  --resource-group $resourceGroupName `
  --template-file initial/main.bicep `
  --parameters parameters.json `
  --name $deploymentName
```

```bash
# Bash
RESOURCE_GROUP_NAME="PracticalPrivateEndpoints"
DEPLOYMENT_NAME="practical-private-endpoints-$(date +%Y%m%d-%H%M%S)"

az deployment group create \
  --resource-group $RESOURCE_GROUP_NAME \
  --template-file initial/main.bicep \
  --parameters parameters.json \
  --name $DEPLOYMENT_NAME
```

## Parameters

| Parameter | Description | Default Value | Required |
|-----------|-------------|---------------|----------|
| `location` | Azure region for resources | `southeastasia` | No |
| `resourceGroupName` | Resource group name | `PracticalPrivateEndpoints` | No |
| `sqlServerName` | SQL Server name | `PracticalPrivateEndpoints` | No |
| `adminUsername` | SQL Server admin username | `PracticalPrivateEndpoints` | No |
| `adminPassword` | SQL Server admin password | `sqladmin123!@#` | Yes (secure) |
| `appServicePlanName` | App Service Plan name | `PracticalPrivateEndpoints` | No |
| `vnetName` | Virtual Network name | `PracticalPrivateEndpoints-vnet` | No |
| `apiManagementName` | API Management service name | `PracticalPrivateEndpoints-apim` | No |
| `apiManagementSku` | API Management SKU tier | `Basic` | No |
| `apiManagementCapacity` | API Management capacity units | `1` | No |
| `publisherEmail` | API Management publisher email | `admin@practical.devsecops` | No |
| `publisherName` | API Management publisher name | `Practical DevSecOps` | No |
| `vmAdminUsername` | Test VM admin username | `testadmin` | No |
| `vmAdminPassword` | Test VM admin password | `TestVM123!@#` | Yes (secure) |

## Post-Deployment Access

### Web Applications

After deployment, you can access the applications through:

1. **Public Web Apps via Application Gateway**:
   - Customer Public Web: `http://{AppGatewayIP}` with Host header: `PracticalPrivateEndpoints-CUSTOMER-PUBLIC.azurewebsites.net`
   - Admin Public Web: `http://{AppGatewayIP}` with Host header: `PracticalPrivateEndpoints-ADMIN-PUBLIC.azurewebsites.net`

2. **Private Web Apps** (from within VNet only):
   - Customer Site: `https://customer-site.rookies.internal`
   - Admin Site: `https://admin-site.rookies.internal`

3. **APIs via API Management** (internal VNet deployment):
   - Video API: `https://{APIManagementName}.azure-api.net/video`
   - Music API: `https://{APIManagementName}.azure-api.net/music`
   - API Management Developer Portal: `https://{APIManagementName}.developer.azure-api.net`
   - API Management Management Portal: `https://{APIManagementName}.management.azure-api.net`

**Note**: 
- The CUSTOMER-SITE, ADMIN-SITE, VIDEO-API, and MUSIC-API applications have public network access disabled
- APIs are only accessible through API Management, which is deployed in internal VNet mode
- API Management includes rate limiting (100 calls/minute) and quotas (1000 calls/day) for both APIs

### Test VM Access

1. Connect to the Test VM using RDP:
   ```
   Computer: {TestVMPublicIP}
   Username: testadmin
   Password: {vmAdminPassword}
   ```

2. From the Test VM, you can access private endpoints and test internal DNS resolution.

### Database Connections

Use the output connection strings to connect to the databases from your applications.

## Monitoring Deployment

### Check Deployment Status

```powershell
# PowerShell
az deployment group show --resource-group $resourceGroupName --name $deploymentName --query "properties.provisioningState"
```

```bash
# Bash
az deployment group show --resource-group $RESOURCE_GROUP_NAME --name $DEPLOYMENT_NAME --query "properties.provisioningState"
```

### Get Deployment Outputs

```powershell
# PowerShell
az deployment group show --resource-group $resourceGroupName --name $deploymentName --query "properties.outputs"
```

```bash
# Bash
az deployment group show --resource-group $RESOURCE_GROUP_NAME --name $DEPLOYMENT_NAME --query "properties.outputs"
```

## Troubleshooting

### Common Issues

1. **Deployment Timeout**: Large deployments may take 15-30 minutes. Check Azure portal for detailed status.

2. **SQL Server Name Conflicts**: SQL Server names must be globally unique. Change `sqlServerName` parameter if conflicts occur.

3. **Resource Quota Limits**: Ensure your subscription has sufficient quota for the resources being created.

4. **Network Security**: Private endpoints may take a few minutes to propagate DNS changes.

### Validation Commands

```powershell
# PowerShell - Test private endpoint connectivity from Test VM
nslookup customer-site.rookies.internal
nslookup admin-site.rookies.internal
```

## Cleanup

To remove all resources:

```powershell
# PowerShell
az group delete --name $resourceGroupName --yes --no-wait
```

```bash
# Bash
az group delete --name $RESOURCE_GROUP_NAME --yes --no-wait
```

## Security Considerations

- Change default passwords before production deployment
- Implement proper network security groups
- Enable Azure SQL Database firewall rules as needed
- Use Azure Key Vault for sensitive configuration
- Enable monitoring and logging for all resources

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test the deployment
5. Submit a pull request

## License

This project is for educational purposes as part of the Practical DevSecOps training.
