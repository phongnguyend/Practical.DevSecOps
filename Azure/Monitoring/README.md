### Learning Paths:
- [AZ-104: Monitor and back up Azure resources](https://docs.microsoft.com/en-us/learn/paths/az-104-monitor-backup-resources/)
- [AZ-500: Manage security operations in Azure](https://docs.microsoft.com/en-us/learn/paths/manage-security-operations/)
- [AZ-303, AZ-304: Architect infrastructure operations in Azure](https://docs.microsoft.com/en-us/learn/paths/architect-infrastructure-operations/)

### Tools:
- [Application Insights](https://docs.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview)
- [Azure Security Center](https://azure.microsoft.com/en-us/services/security-center/)
- [Azure Monitor](https://docs.microsoft.com/en-us/azure/azure-monitor/overview)
- [Azure Sentinel](https://docs.microsoft.com/en-us/azure/sentinel/overview)
- [Azure Diagnostics Extension](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/diagnostics-extension-overview)
- [Kusto Query Language](https://docs.microsoft.com/en-us/azure/data-explorer/kusto/concepts/)

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
