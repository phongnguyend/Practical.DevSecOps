# deploy-new-api.ps1
# PowerShell script to deploy a new API without modifying existing infrastructure
# APIs are automatically integrated with API Management

param(
    [Parameter(Mandatory=$true)]
    [string]$ApiName,
    
    [string]$ResourceGroupName = "PracticalPrivateEndpoints",
    [string]$Location = "southeastasia",
    [bool]$CreatePrivateEndpoint = $true,
    [bool]$EnablePublicAccess = $false,
    [bool]$AddToApiManagement = $true
)

Write-Host "Deploying new API: $ApiName" -ForegroundColor Green

# Deploy the new API
$deploymentName = "api-$ApiName-$(Get-Date -Format 'yyyyMMdd-HHmmss')"

try {
    az deployment group create `
        --resource-group $ResourceGroupName `
        --template-file "modules/new-api.bicep" `
        --name $deploymentName `
        --parameters `
            apiName=$ApiName `
            location=$Location `
            createPrivateEndpoint=$CreatePrivateEndpoint `
            enablePublicAccess=$EnablePublicAccess `
            addToApiManagement=$AddToApiManagement
    
    Write-Host "API $ApiName deployed successfully!" -ForegroundColor Green
    
    # Get deployment outputs
    $outputs = az deployment group show --resource-group $ResourceGroupName --name $deploymentName --query properties.outputs --output json | ConvertFrom-Json
    
    Write-Host "`nDeployment Details:" -ForegroundColor Yellow
    Write-Host "Web App Name: $($outputs.webAppName.value)" -ForegroundColor White
    Write-Host "Web App URL: $($outputs.webAppUrl.value)" -ForegroundColor White
    
    if ($outputs.apiManagementIntegrated.value -eq $true) {
        Write-Host "`nAPI Management Integration:" -ForegroundColor Yellow
        Write-Host "API added to API Management: PracticalPrivateEndpoints-apim" -ForegroundColor White
        Write-Host "API Backend: $($outputs.webAppName.value)" -ForegroundColor White
        Write-Host "Access via: https://[APIM-GATEWAY-URL]/api/$($ApiName.ToLower())" -ForegroundColor White
        Write-Host "Note: Replace [APIM-GATEWAY-URL] with your API Management gateway URL" -ForegroundColor Cyan
    }
    
    if ($outputs.privateEndpointId.value) {
        Write-Host "Private Endpoint: Created" -ForegroundColor White
    }
    
    Write-Host "`nNext Steps:" -ForegroundColor Yellow
    Write-Host "1. Create database separately using new-database.bicep if needed" -ForegroundColor White
    Write-Host "2. Deploy your API application code to: $($outputs.webAppName.value)" -ForegroundColor White
    Write-Host "3. Configure API policies in API Management if needed" -ForegroundColor White
    Write-Host "4. Test API access through API Management gateway" -ForegroundColor White
    
} catch {
    Write-Host "Error deploying API $ApiName : $_" -ForegroundColor Red
    exit 1
}

Write-Host "`nAPI deployment completed successfully!" -ForegroundColor Green
