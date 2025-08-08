# deploy-new-subnet.ps1
# PowerShell script to create a new subnet in existing VNet
# Use this when you need additional network isolation or dedicated subnets

param(
    [Parameter(Mandatory=$true)]
    [string]$SubnetName,
    
    [Parameter(Mandatory=$true)]
    [string]$SubnetAddressPrefix,
    
    [string]$ResourceGroupName = "PracticalPrivateEndpoints",
    [string]$ExistingVnetName = "PracticalPrivateEndpoints-vnet",
    [bool]$EnablePrivateEndpointNetworkPolicies = $false,
    [bool]$EnablePrivateLinkServiceNetworkPolicies = $false,
    [string[]]$ServiceEndpoints = @(),
    [string[]]$Delegations = @()
)

Write-Host "Creating new subnet: $SubnetName" -ForegroundColor Green
Write-Host "Address prefix: $SubnetAddressPrefix" -ForegroundColor White

# Deploy the new subnet
$deploymentName = "subnet-$SubnetName-$(Get-Date -Format 'yyyyMMdd-HHmmss')"

try {
    $parameters = @{
        subnetName = $SubnetName
        subnetAddressPrefix = $SubnetAddressPrefix
        existingVnetName = $ExistingVnetName
        enablePrivateEndpointNetworkPolicies = $EnablePrivateEndpointNetworkPolicies
        enablePrivateLinkServiceNetworkPolicies = $EnablePrivateLinkServiceNetworkPolicies
    }
    
    # Add service endpoints if provided
    if ($ServiceEndpoints.Count -gt 0) {
        $serviceEndpointObjects = @()
        foreach ($endpoint in $ServiceEndpoints) {
            $serviceEndpointObjects += @{ service = $endpoint }
        }
        $parameters.serviceEndpoints = $serviceEndpointObjects
    }
    
    # Add delegations if provided
    if ($Delegations.Count -gt 0) {
        $delegationObjects = @()
        foreach ($delegation in $Delegations) {
            $delegationObjects += @{
                name = $delegation
                properties = @{
                    serviceName = $delegation
                }
            }
        }
        $parameters.delegations = $delegationObjects
    }
    
    # Convert parameters to JSON for Azure CLI
    $parametersJson = $parameters | ConvertTo-Json -Depth 5 | Out-String
    $tempFile = [System.IO.Path]::GetTempFileName() + ".json"
    $parametersJson | Out-File -FilePath $tempFile -Encoding UTF8
    
    az deployment group create `
        --resource-group $ResourceGroupName `
        --template-file "modules/new-subnet.bicep" `
        --name $deploymentName `
        --parameters "@$tempFile"
    
    # Clean up temp file
    Remove-Item $tempFile -Force
    
    Write-Host "Subnet $SubnetName created successfully!" -ForegroundColor Green
    
    # Get deployment outputs
    $outputs = az deployment group show --resource-group $ResourceGroupName --name $deploymentName --query properties.outputs --output json | ConvertFrom-Json
    
    Write-Host "`nSubnet Details:" -ForegroundColor Yellow
    Write-Host "Subnet Name: $($outputs.subnetName.value)" -ForegroundColor White
    Write-Host "Address Prefix: $($outputs.subnetAddressPrefix.value)" -ForegroundColor White
    Write-Host "VNet Name: $($outputs.vnetName.value)" -ForegroundColor White
    Write-Host "Subnet ID: $($outputs.subnetId.value)" -ForegroundColor White
    
    Write-Host "`nCommon Use Cases:" -ForegroundColor Yellow
    Write-Host "• Use this subnet for new Web Apps with VNet integration" -ForegroundColor White
    Write-Host "• Create private endpoints in this subnet" -ForegroundColor White
    Write-Host "• Deploy additional services requiring network isolation" -ForegroundColor White
    
    Write-Host "`nNext Steps:" -ForegroundColor Yellow
    Write-Host "1. Update your templates to reference this subnet when needed" -ForegroundColor White
    Write-Host "2. Configure NSG rules if required" -ForegroundColor White
    Write-Host "3. Use subnet ID: $($outputs.subnetId.value)" -ForegroundColor White
    
} catch {
    Write-Host "Error creating subnet $SubnetName : $_" -ForegroundColor Red
    exit 1
}

Write-Host "`nSubnet creation completed successfully!" -ForegroundColor Green
