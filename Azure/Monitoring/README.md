### Learning Paths:
- [AZ-104: Monitor and back up Azure resources](https://docs.microsoft.com/en-us/learn/paths/az-104-monitor-backup-resources/)
- [AZ-500: Manage security operations in Azure](https://docs.microsoft.com/en-us/learn/paths/manage-security-operations/)
- [AZ-303, AZ-304: Architect infrastructure operations in Azure](https://docs.microsoft.com/en-us/learn/paths/architect-infrastructure-operations/)
- [AZ-303, AZ-304: Architect migration, business continuity, and disaster recovery in Azure](https://docs.microsoft.com/en-us/learn/paths/architect-migration-bcdr/)

### Tools:
- [Application Insights](https://docs.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview)
- [Azure Security Center](https://azure.microsoft.com/en-us/services/security-center/)
- [Azure Monitor](https://docs.microsoft.com/en-us/azure/azure-monitor/overview)
- [Azure Sentinel](https://docs.microsoft.com/en-us/azure/sentinel/overview)
- [Azure Diagnostics Extension](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/diagnostics-extension-overview)
- [Microsoft Antimalware Extension](https://docs.microsoft.com/en-us/azure/security/fundamentals/antimalware)
- [Kusto Query Language](https://docs.microsoft.com/en-us/azure/data-explorer/kusto/concepts/)

### Useful Links:
- [Delete an Azure Backup Recovery Services vault](https://docs.microsoft.com/en-us/azure/backup/backup-azure-delete-vault)
- [ASP.NET Core Logging with Azure App Service and Serilog](https://devblogs.microsoft.com/aspnet/asp-net-core-logging/)
- [Configuring Logging in Azure App Services](https://ardalis.com/configuring-logging-in-azure-app-services/)

### Scripts:
<details>
  <summary><b>Configure Virtual Machine Boot Diagnostics</b></summary>
  
  ```
STORAGE=metricsstorage$RANDOM

az storage account create \
    --name $STORAGE \
    --sku Standard_LRS \
    --location eastus2 \
    --resource-group learn-2d3f4c3e-f5bf-4adb-a7be-a6572787dd70
	
az vm create \
    --name monitored-linux-vm \
    --image UbuntuLTS \
    --size Standard_B1s \
    --location eastus2 \
    --admin-username azureuser \
	--admin-password abcABC123'!@#' \
    --boot-diagnostics-storage $STORAGE \
    --resource-group learn-2d3f4c3e-f5bf-4adb-a7be-a6572787dd70 \
    --generate-ssh-keys
	
  ```
</details>

<details>
  <summary><b>Create CPU 80% Alert</b></summary>
  
  ```
cat <<EOF > cloud-init.txt
#cloud-config
package_upgrade: true
packages:
- stress
runcmd:
- sudo stress --cpu 1
EOF

az vm create \
    --resource-group learn-903737bb-b940-45e0-9ae9-b5943e85ef9c \
    --name vm1 \
    --image UbuntuLTS \
    --custom-data cloud-init.txt \
    --generate-ssh-keys

VMID=$(az vm show \
        --resource-group learn-903737bb-b940-45e0-9ae9-b5943e85ef9c \
        --name vm1 \
        --query id \
        --output tsv)
		
az monitor metrics alert create \
    -n "Cpu80PercentAlert" \
    --resource-group learn-903737bb-b940-45e0-9ae9-b5943e85ef9c \
    --scopes $VMID \
    --condition "max percentage CPU > 80" \
    --description "Virtual machine is running at or greater than 80% CPU utilization" \
    --evaluation-frequency 1m \
    --window-size 1m \
    --severity 3
  ```
</details>

<details>
  <summary><b>Backup & Restore Virtual Machine</b></summary>
  
  ```
RGROUP=$(az group create --name vmbackups --location westus2 --output tsv --query name)

az network vnet create \
    --resource-group $RGROUP \
    --name NorthwindInternal \
    --address-prefix 10.0.0.0/16 \
    --subnet-name NorthwindInternal1 \
    --subnet-prefix 10.0.0.0/24
	
az vm create \
    --resource-group $RGROUP \
    --name NW-APP01 \
    --size Standard_DS1_v2 \
    --vnet-name NorthwindInternal \
    --subnet NorthwindInternal1 \
    --image Win2016Datacenter \
    --admin-username admin123 \
    --no-wait \
    --admin-password abcABC123'!@#'
	
az vm create \
    --resource-group $RGROUP \
    --name NW-RHEL01 \
    --size Standard_DS1_v2 \
    --image RedHat:RHEL:7-RAW:latest \
    --authentication-type ssh \
    --generate-ssh-keys \
    --vnet-name NorthwindInternal \
    --subnet NorthwindInternal1

az backup vault create \
	--name azure-backup  \
	--resource-group vmbackups \
	--location westus2

az backup protection enable-for-vm \
    --resource-group vmbackups \
    --vault-name azure-backup \
    --vm NW-APP01 \
    --policy-name DefaultPolicy

az backup job list \
    --resource-group vmbackups \
    --vault-name azure-backup \
    --output table
	
az backup protection backup-now \
    --resource-group vmbackups \
    --vault-name azure-backup \
    --container-name NW-APP01 \
    --item-name NW-APP01 \
    --retain-until 18-10-2030 \
    --backup-management-type AzureIaasVM

storageName=restorestaging$RANDOM

az storage account create \
	--resource-group $RGROUP \
	--name $storageName \
	--location westus2

az vm stop --resource-group $RGROUP --name NW-APP01

## use azure portal to restore ##

az group delete --name $RGROUP --yes
```
</details>

<details>
  <summary><b>Protect Azure infrastructure with Azure Site Recovery</b></summary>
  
  ```
curl https://raw.githubusercontent.com/MicrosoftDocs/mslearn-protect-infrastructure-with-azure-site-recovery/master/deploy.json > deploy.json

az group create --name west-coast-rg --location westus2
az group create --name east-coast-rg --location eastus2

az deployment group create \
    --name asrDeployment \
    --template-file deploy.json \
    --parameters storageAccounts_asrcache_name=asrcache$RANDOM \
    --resource-group west-coast-rg

az backup vault create \
  --name asr-vault  \
  --resource-group east-coast-rg \
  --location eastus2

# use portal to continue #

az group delete --name west-coast-rg --yes
az group delete --name east-coast-rg --yes
az group delete --name west-coast-rg-asr --yes
  ```
</details>

<details>
  <summary><b>Capture Web Application Logs with App Service Diagnostics Logging</b></summary>
  
  ```
gitRepo=https://github.com/MicrosoftDocs/mslearn-capture-application-logs-app-service
appName="contosofashions$RANDOM"
appPlan="contosofashionsAppPlan"
appLocation=southeastasia
resourceGroup=learn-081cf34f-1480-4bb7-ae7f-fc0592d95f9a
storageAccount=sa$appName

az appservice plan create --name $appPlan --resource-group $resourceGroup --location $appLocation --sku FREE
az webapp create --name $appName --resource-group $resourceGroup --plan $appPlan --deployment-source-url $gitRepo

az storage account create -n $storageAccount -g $resourceGroup -l $appLocation --sku Standard_LRS

az webapp log config --application-logging true --level verbose --name $appName --resource-group $resourceGroup

az webapp log tail  --resource-group learn-081cf34f-1480-4bb7-ae7f-fc0592d95f9a --name $appName

az webapp log config --application-logging false --name $appName --resource-group $resourceGroup

az webapp log show --name $appName --resource-group $resourceGroup
  ```
</details>

<details>
  <summary><b>Azure Sentinel + Log Analytics Workspace</b></summary>
  
  ```
az group create --name SENTINEL --location southeastasia 
az monitor log-analytics workspace create -g SENTINEL -n LogAnalyticsWorkspace
  ```
</details>
