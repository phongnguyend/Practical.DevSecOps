# deploy-new-site.ps1
# PowerShell script to deploy a new website/site without modifying existing infrastructure
# Sites are automatically integrated with Application Gateway

param(
    [Parameter(Mandatory=$true)]
    [string]$SiteName,
    
    [string]$ResourceGroupName = "PracticalPrivateEndpoints",
    [string]$Location = "southeastasia",
    [bool]$CreatePrivateEndpoint = $true,
    [bool]$EnablePublicAccess = $true,
    [bool]$AddToApplicationGateway = $true,
    [string]$PathPattern = "",
    [int]$Priority = 100
)

Write-Host "Deploying new site: $SiteName" -ForegroundColor Green

# Set default path pattern if not provided
if ([string]::IsNullOrEmpty($PathPattern)) {
    $PathPattern = "/$($SiteName.ToLower())/*"
}

# Deploy the new site
$deploymentName = "site-$SiteName-$(Get-Date -Format 'yyyyMMdd-HHmmss')"

try {
    az deployment group create `
        --resource-group $ResourceGroupName `
        --template-file "modules/new-site.bicep" `
        --name $deploymentName `
        --parameters `
            siteName=$SiteName `
            location=$Location `
            createPrivateEndpoint=$CreatePrivateEndpoint `
            enablePublicAccess=$EnablePublicAccess `
            addToApplicationGateway=$AddToApplicationGateway `
            applicationGatewayPathPattern=$PathPattern `
            applicationGatewayPriority=$Priority
    
    Write-Host "Site $SiteName deployed successfully!" -ForegroundColor Green
    
    # Get deployment outputs
    $outputs = az deployment group show --resource-group $ResourceGroupName --name $deploymentName --query properties.outputs --output json | ConvertFrom-Json
    
    Write-Host "`nDeployment Details:" -ForegroundColor Yellow
    Write-Host "Web App Name: $($outputs.webAppName.value)" -ForegroundColor White
    Write-Host "Web App URL: $($outputs.webAppUrl.value)" -ForegroundColor White
    
    if ($outputs.applicationGatewayIntegrated.value -eq $true) {
        Write-Host "`nApplication Gateway Integration:" -ForegroundColor Yellow
        Write-Host "Path Pattern: $($outputs.applicationGatewayPathPattern.value)" -ForegroundColor White
        Write-Host "Application Gateway URL: http://[APPGW-FQDN]$($outputs.applicationGatewayPathPattern.value)" -ForegroundColor White
        Write-Host "Note: Replace [APPGW-FQDN] with your Application Gateway's FQDN" -ForegroundColor Cyan
    }
    
    if ($outputs.privateEndpointId.value) {
        Write-Host "Private Endpoint: Created" -ForegroundColor White
    }
    
    Write-Host "`nNext Steps:" -ForegroundColor Yellow
    Write-Host "1. Create database separately using new-database.bicep if needed" -ForegroundColor White
    Write-Host "2. Deploy your website code to: $($outputs.webAppName.value)" -ForegroundColor White
    Write-Host "3. Test site access through Application Gateway" -ForegroundColor White
    Write-Host "4. Configure custom domains if needed" -ForegroundColor White
    
} catch {
    Write-Host "Error deploying site $SiteName : $_" -ForegroundColor Red
    exit 1
}

Write-Host "`nSite deployment completed successfully!" -ForegroundColor Green
