## Setup Testing Environment in Azure
```
az group create --name Clustering1 --location southeastasia

az network vnet create \
 --name VNET \
 --resource-group Clustering1 \
 --address-prefix 10.0.0.0/16 \
 --subnet-name default \
 --subnet-prefix 10.0.0.0/24
 
az vm image list -f windows -o table
 
az vm create \
 -g Clustering1 \
 -n DC \
 --image win2016datacenter \
 --admin-username vmadmin \
 --admin-password 'abcABC123!@#' \
 --size Standard_D2s_v3 \
 --vnet-name VNET \
 --subnet default
 
az vm create \
 -g Clustering1 \
 -n VM1 \
 --image win2016datacenter \
 --admin-username vmadmin \
 --admin-password 'abcABC123!@#' \
 --size Standard_D2s_v3 \
 --vnet-name VNET \
 --subnet default
 
az vm create \
 -g Clustering1 \
 -n VM2 \
 --image win2016datacenter \
 --admin-username vmadmin \
 --admin-password 'abcABC123!@#' \
 --size Standard_D2s_v3 \
 --vnet-name VNET \
 --subnet default

dcIpAddress="$(az network nic ip-config show -g Clustering1 -n ipconfigDC --nic-name DCVMNic --query "privateIpAddress" --out tsv)"
echo $dcIpAddress
az network nic update -n VM1VMNic -g Clustering1 --dns-servers $dcIpAddress
az network nic update -n VM2VMNic -g Clustering1 --dns-servers $dcIpAddress

```

## Login to DC and Install Active Directory Domain Services (ADDS)
```
Install-WindowsFeature AD-Domain-Services –IncludeManagementTools

Import-Module ADDSDeployment

Install-ADDSForest `
-CreateDnsDelegation:$false `
-DatabasePath "C:\windows\NTDS" `
-DomainMode "WinThreshold" `
-DomainName "htlt.local" `
-DomainNetbiosName "HTLT" `
-ForestMode "WinThreshold" `
-InstallDns:$true `
-LogPath "C:\windows\NTDS" `
-NoRebootOnCompletion:$false `
-SysvolPath "C:\windows\SYSVOL" `
-Force:$true

```
