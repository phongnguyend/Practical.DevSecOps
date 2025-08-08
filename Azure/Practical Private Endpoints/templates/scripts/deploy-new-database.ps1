# deploy-new-database.ps1
# PowerShell script to create a new database on existing SQL Server
# Use this when you need a new database for APIs or Sites

param(
    [Parameter(Mandatory=$true)]
    [string]$DatabaseName,
    
    [string]$ResourceGroupName = "PracticalPrivateEndpoints",
    [string]$Location = "southeastasia",
    [string]$ExistingSqlServerName = "PracticalPrivateEndpoints"
)

Write-Host "Creating new database: $DatabaseName" -ForegroundColor Green

# Deploy the new database
$deploymentName = "database-$DatabaseName-$(Get-Date -Format 'yyyyMMdd-HHmmss')"

try {
    az deployment group create `
        --resource-group $ResourceGroupName `
        --template-file "modules/new-database.bicep" `
        --name $deploymentName `
        --parameters `
            databaseName=$DatabaseName `
            location=$Location `
            existingSqlServerName=$ExistingSqlServerName
    
    Write-Host "Database $DatabaseName created successfully!" -ForegroundColor Green
    
    # Get deployment outputs
    $outputs = az deployment group show --resource-group $ResourceGroupName --name $deploymentName --query properties.outputs --output json | ConvertFrom-Json
    
    Write-Host "`nDatabase Details:" -ForegroundColor Yellow
    Write-Host "Database Name: $($outputs.databaseName.value)" -ForegroundColor White
    Write-Host "SQL Server: $ExistingSqlServerName" -ForegroundColor White
    Write-Host "Resource Group: $ResourceGroupName" -ForegroundColor White
    
    Write-Host "`nConnection String Pattern:" -ForegroundColor Yellow
    Write-Host "Server=$ExistingSqlServerName.database.windows.net;Database=$($outputs.databaseName.value);[Authentication]" -ForegroundColor White
    
    Write-Host "`nNext Steps:" -ForegroundColor Yellow
    Write-Host "1. Configure your applications to use this database" -ForegroundColor White
    Write-Host "2. Set up appropriate connection strings" -ForegroundColor White
    Write-Host "3. Configure database access permissions if needed" -ForegroundColor White
    
} catch {
    Write-Host "Error creating database $DatabaseName : $_" -ForegroundColor Red
    exit 1
}

Write-Host "`nDatabase creation completed successfully!" -ForegroundColor Green
