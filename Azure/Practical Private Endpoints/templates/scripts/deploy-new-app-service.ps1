#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Deploy a new App Service (Web App) using Bicep template

.DESCRIPTION
    This script deploys a new App Service to an existing App Service Plan with configurable settings including:
    - Runtime stack selection (Node.js, .NET, Python, Java, PHP)
    - VNet integration support
    - Application Insights integration
    - Private endpoint creation
    - System-assigned managed identity
    - Custom app settings and connection strings

.PARAMETER ResourceGroupName
    Name of the resource group to deploy to

.PARAMETER AppServiceName
    Name of the App Service to create

.PARAMETER AppServicePlanName
    Name of the existing App Service Plan

.PARAMETER AppServicePlanResourceGroup
    Resource group containing the App Service Plan (defaults to main resource group)

.PARAMETER Location
    Azure region for deployment (defaults to resource group location)

.PARAMETER RuntimeStack
    Runtime stack for the application (e.g., 'DOTNETCORE|8.0', 'NODE|20-lts')

.PARAMETER NetFrameworkVersion
    .NET Framework version for Windows apps (v4.0, v6.0, v8.0)

.PARAMETER EnableApplicationInsights
    Whether to enable Application Insights

.PARAMETER ExistingApplicationInsightsName
    Name of existing Application Insights to use

.PARAMETER EnableVNetIntegration
    Whether to enable VNet integration

.PARAMETER VNetName
    Name of the VNet for integration

.PARAMETER VNetIntegrationSubnetName
    Name of the subnet for VNet integration

.PARAMETER CreatePrivateEndpoint
    Whether to create a private endpoint

.PARAMETER PrivateEndpointSubnetName
    Name of the subnet for private endpoint

.PARAMETER AppSettings
    Hashtable of application settings

.PARAMETER ConnectionStrings
    Array of connection string objects

.PARAMETER Tags
    Hashtable of tags to apply

.EXAMPLE
    .\deploy-new-app-service.ps1 -ResourceGroupName "MyRG" -AppServiceName "my-web-app" -AppServicePlanName "my-plan" -RuntimeStack "DOTNETCORE|8.0"

.EXAMPLE
    .\deploy-new-app-service.ps1 -ResourceGroupName "MyRG" -AppServiceName "my-node-app" -AppServicePlanName "my-plan" -RuntimeStack "NODE|20-lts" -EnableVNetIntegration $true -CreatePrivateEndpoint $true

.EXAMPLE
    $appSettings = @{
        "ENVIRONMENT" = "Production"
        "API_KEY" = "secret-key"
    }
    .\deploy-new-app-service.ps1 -ResourceGroupName "MyRG" -AppServiceName "my-api" -AppServicePlanName "my-plan" -AppSettings $appSettings
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    
    [Parameter(Mandatory = $true)]
    [string]$AppServiceName,
    
    [Parameter(Mandatory = $true)]
    [string]$AppServicePlanName,
    
    [Parameter(Mandatory = $false)]
    [string]$AppServicePlanResourceGroup = "",
    
    [Parameter(Mandatory = $false)]
    [string]$Location = "",
    
    [Parameter(Mandatory = $false)]
    [ValidateSet('DOTNETCORE|8.0', 'DOTNETCORE|6.0', 'DOTNET|8.0', 'DOTNET|6.0', 'NODE|20-lts', 'NODE|18-lts', 'PYTHON|3.11', 'PYTHON|3.10', 'JAVA|17-java17', 'JAVA|11-java11', 'PHP|8.2', 'PHP|8.1')]
    [string]$RuntimeStack = "DOTNETCORE|8.0",
    
    [Parameter(Mandatory = $false)]
    [ValidateSet('v4.0', 'v6.0', 'v8.0')]
    [string]$NetFrameworkVersion = "v8.0",
    
    [Parameter(Mandatory = $false)]
    [bool]$HttpsOnly = $true,
    
    [Parameter(Mandatory = $false)]
    [bool]$ClientAffinityEnabled = $false,
    
    [Parameter(Mandatory = $false)]
    [bool]$EnableSystemAssignedIdentity = $true,
    
    [Parameter(Mandatory = $false)]
    [bool]$EnableApplicationInsights = $true,
    
    [Parameter(Mandatory = $false)]
    [string]$ExistingApplicationInsightsName = "",
    
    [Parameter(Mandatory = $false)]
    [bool]$EnableVNetIntegration = $false,
    
    [Parameter(Mandatory = $false)]
    [string]$VNetName = "PracticalPrivateEndpoints-vnet",
    
    [Parameter(Mandatory = $false)]
    [string]$VNetIntegrationSubnetName = "default",
    
    [Parameter(Mandatory = $false)]
    [bool]$CreatePrivateEndpoint = $false,
    
    [Parameter(Mandatory = $false)]
    [string]$PrivateEndpointSubnetName = "private-endpoints",
    
    [Parameter(Mandatory = $false)]
    [bool]$PublicNetworkAccess = $true,
    
    [Parameter(Mandatory = $false)]
    [hashtable]$AppSettings = @{},
    
    [Parameter(Mandatory = $false)]
    [array]$ConnectionStrings = @(),
    
    [Parameter(Mandatory = $false)]
    [hashtable]$Tags = @{}
)

# Set error action preference
$ErrorActionPreference = "Stop"

try {
    Write-Host "🚀 Starting App Service deployment..." -ForegroundColor Green
    
    # Validate parameters
    if ($CreatePrivateEndpoint -and -not $EnableVNetIntegration) {
        Write-Warning "Private endpoint requires VNet integration. Enabling VNet integration..."
        $EnableVNetIntegration = $true
    }
    
    if ($PublicNetworkAccess -eq $false -and -not $CreatePrivateEndpoint) {
        Write-Warning "Disabling public network access without private endpoint will make the app inaccessible!"
    }
    
    # Convert hashtable to array for app settings
    $appSettingsArray = @()
    foreach ($key in $AppSettings.Keys) {
        $appSettingsArray += @{
            name = $key
            value = $AppSettings[$key]
        }
    }
    
    # Set default values
    if ([string]::IsNullOrEmpty($AppServicePlanResourceGroup)) {
        $AppServicePlanResourceGroup = $ResourceGroupName
    }
    
    # Build parameters
    $templateParams = @{
        appServiceName = $AppServiceName
        existingAppServicePlanName = $AppServicePlanName
        appServicePlanResourceGroup = $AppServicePlanResourceGroup
        linuxFxVersion = $RuntimeStack
        netFrameworkVersion = $NetFrameworkVersion
        httpsOnly = $HttpsOnly
        clientAffinityEnabled = $ClientAffinityEnabled
        enableSystemAssignedIdentity = $EnableSystemAssignedIdentity
        enableApplicationInsights = $EnableApplicationInsights
        existingApplicationInsightsName = $ExistingApplicationInsightsName
        enableVNetIntegration = $EnableVNetIntegration
        existingVnetName = $VNetName
        vnetIntegrationSubnetName = $VNetIntegrationSubnetName
        createPrivateEndpoint = $CreatePrivateEndpoint
        privateEndpointSubnetName = $PrivateEndpointSubnetName
        publicNetworkAccess = $PublicNetworkAccess
        appSettings = $appSettingsArray
        connectionStrings = $ConnectionStrings
        tags = $Tags
    }
    
    # Add location if specified
    if (-not [string]::IsNullOrEmpty($Location)) {
        $templateParams.location = $Location
    }
    
    Write-Host "📋 Deployment Parameters:" -ForegroundColor Yellow
    Write-Host "  Resource Group: $ResourceGroupName" -ForegroundColor White
    Write-Host "  App Service Name: $AppServiceName" -ForegroundColor White
    Write-Host "  App Service Plan: $AppServicePlanName" -ForegroundColor White
    Write-Host "  Runtime Stack: $RuntimeStack" -ForegroundColor White
    Write-Host "  VNet Integration: $EnableVNetIntegration" -ForegroundColor White
    Write-Host "  Private Endpoint: $CreatePrivateEndpoint" -ForegroundColor White
    Write-Host "  Application Insights: $EnableApplicationInsights" -ForegroundColor White
    
    # Get the directory of this script
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    $templatePath = Join-Path $scriptDir "..\modules\new-app-service.bicep"
    
    if (-not (Test-Path $templatePath)) {
        throw "Template file not found: $templatePath"
    }
    
    Write-Host "🔨 Deploying App Service..." -ForegroundColor Blue
    
    # Deploy the template
    $deployment = az deployment group create `
        --resource-group $ResourceGroupName `
        --template-file $templatePath `
        --parameters ($templateParams | ConvertTo-Json -Depth 10) `
        --output json | ConvertFrom-Json
    
    if ($LASTEXITCODE -ne 0) {
        throw "Deployment failed with exit code $LASTEXITCODE"
    }
    
    # Extract outputs
    $outputs = $deployment.properties.outputs
    
    Write-Host "✅ App Service deployment completed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📊 Deployment Results:" -ForegroundColor Yellow
    Write-Host "  App Service ID: $($outputs.appServiceId.value)" -ForegroundColor White
    Write-Host "  App Service Name: $($outputs.appServiceName.value)" -ForegroundColor White
    Write-Host "  Default Hostname: $($outputs.defaultHostName.value)" -ForegroundColor White
    Write-Host "  App Service URL: $($outputs.appServiceUrl.value)" -ForegroundColor White
    Write-Host "  Is Linux: $($outputs.isLinux.value)" -ForegroundColor White
    
    if ($outputs.principalId.value) {
        Write-Host "  Managed Identity Principal ID: $($outputs.principalId.value)" -ForegroundColor White
    }
    
    if ($outputs.applicationInsightsId.value) {
        Write-Host "  Application Insights ID: $($outputs.applicationInsightsId.value)" -ForegroundColor White
    }
    
    if ($outputs.privateEndpointId.value) {
        Write-Host "  Private Endpoint ID: $($outputs.privateEndpointId.value)" -ForegroundColor White
    }
    
    Write-Host ""
    Write-Host "🎯 Next Steps:" -ForegroundColor Cyan
    Write-Host "  1. Deploy your application code to the App Service" -ForegroundColor White
    Write-Host "  2. Configure any additional app settings in the Azure portal" -ForegroundColor White
    Write-Host "  3. Set up custom domains and SSL certificates if needed" -ForegroundColor White
    Write-Host "  4. Configure deployment slots for production workloads" -ForegroundColor White
    
    if ($EnableVNetIntegration) {
        Write-Host "  5. Verify VNet integration connectivity" -ForegroundColor White
    }
    
    if ($CreatePrivateEndpoint) {
        Write-Host "  6. Update DNS settings for private endpoint resolution" -ForegroundColor White
    }
    
    Write-Host ""
    Write-Host "🌐 Access your App Service:" -ForegroundColor Magenta
    Write-Host "  $($outputs.appServiceUrl.value)" -ForegroundColor Cyan
    
} catch {
    Write-Error "❌ App Service deployment failed: $($_.Exception.Message)"
    exit 1
}
