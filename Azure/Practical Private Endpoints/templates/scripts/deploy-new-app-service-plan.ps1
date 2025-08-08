# deploy-new-app-service-plan.ps1
# PowerShell script to create a new App Service Plan
# Use this when you need dedicated compute resources for different environments or workloads

param(
    [Parameter(Mandatory=$true)]
    [string]$AppServicePlanName,
    
    [string]$ResourceGroupName = "PracticalPrivateEndpoints",
    [string]$Location = "southeastasia",
    [ValidateSet("F1", "D1", "B1", "B2", "B3", "S1", "S2", "S3", "P1", "P2", "P3", "P1v2", "P2v2", "P3v2", "P1v3", "P2v3", "P3v3")]
    [string]$Sku = "S1",
    [ValidateRange(1, 30)]
    [int]$Capacity = 1,
    [ValidateSet("Windows", "Linux")]
    [string]$Os = "Windows",
    [bool]$ZoneRedundant = $false,
    [ValidateRange(1, 30)]
    [int]$MaximumElasticWorkerCount = 1,
    [hashtable]$Tags = @{}
)

Write-Host "Creating new App Service Plan: $AppServicePlanName" -ForegroundColor Green
Write-Host "SKU: $Sku, Capacity: $Capacity, OS: $Os" -ForegroundColor White

# Validate zone redundancy for non-premium SKUs
$premiumSkus = @("P1v2", "P2v2", "P3v2", "P1v3", "P2v3", "P3v3")
if ($ZoneRedundant -and $Sku -notin $premiumSkus) {
    Write-Host "Warning: Zone redundancy is only supported on Premium V2/V3 SKUs. Disabling zone redundancy." -ForegroundColor Yellow
    $ZoneRedundant = $false
}

# Deploy the new App Service Plan
$deploymentName = "asp-$AppServicePlanName-$(Get-Date -Format 'yyyyMMdd-HHmmss')"

try {
    $parameters = @{
        appServicePlanName = $AppServicePlanName
        location = $Location
        sku = $Sku
        capacity = $Capacity
        os = $Os
        zoneRedundant = $ZoneRedundant
        maximumElasticWorkerCount = $MaximumElasticWorkerCount
        tags = $Tags
    }
    
    # Convert parameters to JSON for Azure CLI
    $parametersJson = $parameters | ConvertTo-Json -Depth 3 | Out-String
    $tempFile = [System.IO.Path]::GetTempFileName() + ".json"
    $parametersJson | Out-File -FilePath $tempFile -Encoding UTF8
    
    az deployment group create `
        --resource-group $ResourceGroupName `
        --template-file "modules/new-app-service-plan.bicep" `
        --name $deploymentName `
        --parameters "@$tempFile"
    
    # Clean up temp file
    Remove-Item $tempFile -Force
    
    Write-Host "App Service Plan $AppServicePlanName created successfully!" -ForegroundColor Green
    
    # Get deployment outputs
    $outputs = az deployment group show --resource-group $ResourceGroupName --name $deploymentName --query properties.outputs --output json | ConvertFrom-Json
    
    Write-Host "`nApp Service Plan Details:" -ForegroundColor Yellow
    Write-Host "Name: $($outputs.appServicePlanName.value)" -ForegroundColor White
    Write-Host "ID: $($outputs.appServicePlanId.value)" -ForegroundColor White
    Write-Host "SKU: $($outputs.skuName.value)" -ForegroundColor White
    Write-Host "Capacity: $($outputs.skuCapacity.value)" -ForegroundColor White
    Write-Host "Operating System: $($outputs.operatingSystem.value)" -ForegroundColor White
    Write-Host "Zone Redundant: $($outputs.zoneRedundant.value)" -ForegroundColor White
    Write-Host "Location: $($outputs.location.value)" -ForegroundColor White
    
    Write-Host "`nSKU Information:" -ForegroundColor Yellow
    switch ($Sku) {
        "F1" { Write-Host "• Free tier - Limited to 60 minutes/day, 1GB RAM" -ForegroundColor White }
        "D1" { Write-Host "• Shared tier - 240 minutes/day, 1GB RAM" -ForegroundColor White }
        { $_ -like "B*" } { Write-Host "• Basic tier - Dedicated compute, custom domains, SSL" -ForegroundColor White }
        { $_ -like "S*" } { Write-Host "• Standard tier - Auto-scaling, staging slots, daily backups" -ForegroundColor White }
        { $_ -like "P*" } { Write-Host "• Premium tier - Enhanced performance, VNet integration, advanced scaling" -ForegroundColor White }
    }
    
    Write-Host "`nCommon Use Cases:" -ForegroundColor Yellow
    Write-Host "• Host web applications and APIs" -ForegroundColor White
    Write-Host "• Dedicated compute for production workloads" -ForegroundColor White
    Write-Host "• Environment separation (dev/test/prod)" -ForegroundColor White
    Write-Host "• Auto-scaling for variable workloads" -ForegroundColor White
    
    Write-Host "`nNext Steps:" -ForegroundColor Yellow
    Write-Host "1. Deploy web apps to this App Service Plan" -ForegroundColor White
    Write-Host "2. Configure auto-scaling rules if needed" -ForegroundColor White
    Write-Host "3. Set up monitoring and alerts" -ForegroundColor White
    Write-Host "4. Configure networking (VNet integration, private endpoints)" -ForegroundColor White
    
    Write-Host "`nApp Service Plan ID for reference:" -ForegroundColor Cyan
    Write-Host "$($outputs.appServicePlanId.value)" -ForegroundColor White
    
} catch {
    Write-Host "Error creating App Service Plan $AppServicePlanName : $_" -ForegroundColor Red
    exit 1
}

Write-Host "`nApp Service Plan creation completed successfully!" -ForegroundColor Green
