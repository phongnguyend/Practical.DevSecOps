# deploy-vnet-peering.ps1
# PowerShell script to create VNet peering between two Virtual Networks
# Use this to connect new VNets to existing infrastructure

param(
    [Parameter(Mandatory=$true)]
    [string]$LocalVnetName,
    
    [Parameter(Mandatory=$true)]
    [string]$RemoteVnetId,
    
    [string]$ResourceGroupName = "PracticalPrivateEndpoints",
    [bool]$AllowVirtualNetworkAccess = $true,
    [bool]$AllowForwardedTraffic = $false,
    [bool]$AllowGatewayTransit = $false,
    [bool]$UseRemoteGateways = $false,
    [bool]$CreateBidirectionalPeering = $true
)

# Extract remote VNet name from resource ID
$remoteVnetName = ($RemoteVnetId -split '/')[-1]
$remoteResourceGroup = ($RemoteVnetId -split '/')[4]
$remoteSubscription = ($RemoteVnetId -split '/')[2]

Write-Host "Creating VNet peering between:" -ForegroundColor Green
Write-Host "Local VNet: $LocalVnetName (in $ResourceGroupName)" -ForegroundColor White
Write-Host "Remote VNet: $remoteVnetName (in $remoteResourceGroup)" -ForegroundColor White

# Deploy peering from local to remote
$deploymentName = "peering-$LocalVnetName-to-$remoteVnetName-$(Get-Date -Format 'yyyyMMdd-HHmmss')"

try {
    az deployment group create `
        --resource-group $ResourceGroupName `
        --template-file "modules/vnet-peering.bicep" `
        --name $deploymentName `
        --parameters `
            localVnetName=$LocalVnetName `
            remoteVnetName=$remoteVnetName `
            remoteVnetId=$RemoteVnetId `
            allowVirtualNetworkAccess=$AllowVirtualNetworkAccess `
            allowForwardedTraffic=$AllowForwardedTraffic `
            allowGatewayTransit=$AllowGatewayTransit `
            useRemoteGateways=$UseRemoteGateways
    
    Write-Host "Peering from $LocalVnetName to $remoteVnetName created successfully!" -ForegroundColor Green
    
    # Get deployment outputs
    $outputs = az deployment group show --resource-group $ResourceGroupName --name $deploymentName --query properties.outputs --output json | ConvertFrom-Json
    
    Write-Host "`nPeering Details:" -ForegroundColor Yellow
    Write-Host "Peering Name: $($outputs.peeringName.value)" -ForegroundColor White
    Write-Host "Peering State: $($outputs.peeringState.value)" -ForegroundColor White
    Write-Host "Local VNet ID: $($outputs.localVnetId.value)" -ForegroundColor White
    Write-Host "Remote VNet ID: $($outputs.remoteVnetId.value)" -ForegroundColor White
    
    # Create bidirectional peering if requested
    if ($CreateBidirectionalPeering) {
        Write-Host "`nCreating reverse peering..." -ForegroundColor Yellow
        
        $reverseDeploymentName = "peering-$remoteVnetName-to-$LocalVnetName-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        $localVnetId = $outputs.localVnetId.value
        
        # Deploy reverse peering in remote resource group
        az deployment group create `
            --resource-group $remoteResourceGroup `
            --subscription $remoteSubscription `
            --template-file "modules/vnet-peering.bicep" `
            --name $reverseDeploymentName `
            --parameters `
                localVnetName=$remoteVnetName `
                remoteVnetName=$LocalVnetName `
                remoteVnetId=$localVnetId `
                allowVirtualNetworkAccess=$AllowVirtualNetworkAccess `
                allowForwardedTraffic=$AllowForwardedTraffic `
                allowGatewayTransit=$UseRemoteGateways `
                useRemoteGateways=$AllowGatewayTransit
        
        Write-Host "Reverse peering from $remoteVnetName to $LocalVnetName created successfully!" -ForegroundColor Green
    }
    
    Write-Host "`nPeering Configuration:" -ForegroundColor Yellow
    Write-Host "• Virtual Network Access: $(if($AllowVirtualNetworkAccess){'Enabled'}else{'Disabled'})" -ForegroundColor White
    Write-Host "• Forwarded Traffic: $(if($AllowForwardedTraffic){'Enabled'}else{'Disabled'})" -ForegroundColor White
    Write-Host "• Gateway Transit: $(if($AllowGatewayTransit){'Enabled'}else{'Disabled'})" -ForegroundColor White
    Write-Host "• Use Remote Gateways: $(if($UseRemoteGateways){'Enabled'}else{'Disabled'})" -ForegroundColor White
    
    Write-Host "`nNext Steps:" -ForegroundColor Yellow
    Write-Host "1. Verify connectivity between VNets" -ForegroundColor White
    Write-Host "2. Update route tables if needed" -ForegroundColor White
    Write-Host "3. Configure private DNS zones for cross-VNet name resolution" -ForegroundColor White
    Write-Host "4. Test network connectivity between resources" -ForegroundColor White
    
} catch {
    Write-Host "Error creating VNet peering: $_" -ForegroundColor Red
    exit 1
}

Write-Host "`nVNet peering completed successfully!" -ForegroundColor Green
