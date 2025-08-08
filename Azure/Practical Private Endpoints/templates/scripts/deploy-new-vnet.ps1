# deploy-new-vnet.ps1
# PowerShell script to create a new Virtual Network
# Use this when you need separate network environments or regions

param(
    [Parameter(Mandatory=$true)]
    [string]$VnetName,
    
    [Parameter(Mandatory=$true)]
    [string]$VnetAddressSpace,
    
    [string]$ResourceGroupName = "PracticalPrivateEndpoints",
    [string]$Location = "southeastasia",
    [bool]$CreateNSGs = $true,
    [bool]$EnableDdosProtection = $false,
    [string]$DdosProtectionPlanId = "",
    [string[]]$DnsServers = @(),
    [array]$Subnets = @()
)

# Default subnets if none provided
if ($Subnets.Count -eq 0) {
    # Extract first three octets from VNet address space
    $addressParts = $VnetAddressSpace.Split('/')[0].Split('.')
    $baseAddress = "$($addressParts[0]).$($addressParts[1]).$($addressParts[2])"
    
    $Subnets = @(
        @{
            name = "default"
            addressPrefix = "$baseAddress.1.0/24"
            serviceEndpoints = @()
            delegations = @()
            privateEndpointNetworkPolicies = "Disabled"
            privateLinkServiceNetworkPolicies = "Enabled"
        },
        @{
            name = "private-endpoints"
            addressPrefix = "$baseAddress.2.0/24"
            serviceEndpoints = @()
            delegations = @()
            privateEndpointNetworkPolicies = "Disabled"
            privateLinkServiceNetworkPolicies = "Enabled"
        }
    )
}

Write-Host "Creating new Virtual Network: $VnetName" -ForegroundColor Green
Write-Host "Address space: $VnetAddressSpace" -ForegroundColor White
Write-Host "Subnets: $($Subnets.Count)" -ForegroundColor White

# Deploy the new VNet
$deploymentName = "vnet-$VnetName-$(Get-Date -Format 'yyyyMMdd-HHmmss')"

try {
    $parameters = @{
        vnetName = $VnetName
        vnetAddressSpace = $VnetAddressSpace
        location = $Location
        subnets = $Subnets
        createNSGs = $CreateNSGs
        enableDdosProtection = $EnableDdosProtection
    }
    
    # Add optional parameters
    if ($DnsServers.Count -gt 0) {
        $parameters.dnsServers = $DnsServers
    }
    
    if ($EnableDdosProtection -and $DdosProtectionPlanId) {
        $parameters.ddosProtectionPlanId = $DdosProtectionPlanId
    }
    
    # Convert parameters to JSON for Azure CLI
    $parametersJson = $parameters | ConvertTo-Json -Depth 5 | Out-String
    $tempFile = [System.IO.Path]::GetTempFileName() + ".json"
    $parametersJson | Out-File -FilePath $tempFile -Encoding UTF8
    
    az deployment group create `
        --resource-group $ResourceGroupName `
        --template-file "modules/new-vnet.bicep" `
        --name $deploymentName `
        --parameters "@$tempFile"
    
    # Clean up temp file
    Remove-Item $tempFile -Force
    
    Write-Host "VNet $VnetName created successfully!" -ForegroundColor Green
    
    # Get deployment outputs
    $outputs = az deployment group show --resource-group $ResourceGroupName --name $deploymentName --query properties.outputs --output json | ConvertFrom-Json
    
    Write-Host "`nVNet Details:" -ForegroundColor Yellow
    Write-Host "VNet Name: $($outputs.vnetName.value)" -ForegroundColor White
    Write-Host "VNet ID: $($outputs.vnetId.value)" -ForegroundColor White
    Write-Host "Address Space: $($outputs.vnetAddressSpace.value)" -ForegroundColor White
    
    Write-Host "`nSubnets Created:" -ForegroundColor Yellow
    foreach ($subnet in $outputs.subnetIds.value) {
        Write-Host "• $($subnet.name): $($subnet.addressPrefix)" -ForegroundColor White
    }
    
    if ($CreateNSGs) {
        Write-Host "`nNetwork Security Groups:" -ForegroundColor Yellow
        foreach ($nsg in $outputs.nsgIds.value) {
            if ($nsg.nsgName) {
                Write-Host "• $($nsg.name): $($nsg.nsgName)" -ForegroundColor White
            }
        }
    }
    
    Write-Host "`nCommon Next Steps:" -ForegroundColor Yellow
    Write-Host "1. Create VNet peering if connecting to existing networks" -ForegroundColor White
    Write-Host "2. Deploy services to appropriate subnets" -ForegroundColor White
    Write-Host "3. Configure additional NSG rules if needed" -ForegroundColor White
    Write-Host "4. Set up private DNS zones for name resolution" -ForegroundColor White
    
    Write-Host "`nVNet Peering Command:" -ForegroundColor Yellow
    Write-Host ".\deploy-vnet-peering.ps1 -LocalVnetName '$VnetName' -RemoteVnetId '/subscriptions/.../resourceGroups/.../providers/Microsoft.Network/virtualNetworks/REMOTE-VNET'" -ForegroundColor Cyan
    
} catch {
    Write-Host "Error creating VNet $VnetName : $_" -ForegroundColor Red
    exit 1
}

Write-Host "`nVNet creation completed successfully!" -ForegroundColor Green
