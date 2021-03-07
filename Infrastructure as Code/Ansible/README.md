## Setup Lab Environment in Azure
```
---

az group create --name ANSIBLE --location southeastasia

az network vnet create \
 --name VNET \
 --resource-group ANSIBLE \
 --address-prefix 10.0.0.0/16 \
 --subnet-name default \
 --subnet-prefix 10.0.0.0/24
 
az vm image list -f windows -o table

az vm create \
 -g ANSIBLE \
 -n ANSIBLE \
 --image UbuntuLTS \
 --admin-username vmadmin \
 --admin-password 'abcABC123!@#' \
 --size Standard_D2s_v3 \
 --vnet-name VNET \
 --subnet default
 
az vm create \
 -g ANSIBLE \
 -n DC \
 --image win2016datacenter \
 --admin-username vmadmin \
 --admin-password 'abcABC123!@#' \
 --size Standard_D2s_v3 \
 --vnet-name VNET \
 --subnet default
 
az vm create \
 -g ANSIBLE \
 -n VM1 \
 --image win2016datacenter \
 --admin-username vmadmin \
 --admin-password 'abcABC123!@#' \
 --size Standard_D2s_v3 \
 --vnet-name VNET \
 --subnet default
 
az vm create \
 -g ANSIBLE \
 -n VM2 \
 --image win2016datacenter \
 --admin-username vmadmin \
 --admin-password 'abcABC123!@#' \
 --size Standard_D2s_v3 \
 --vnet-name VNET \
 --subnet default

dcIpAddress="$(az network nic ip-config show -g ANSIBLE -n ipconfigDC --nic-name DCVMNic --query "privateIpAddress" --out tsv)"
echo $dcIpAddress
az network nic update -n VM1VMNic -g ANSIBLE --dns-servers $dcIpAddress
az network nic update -n VM2VMNic -g ANSIBLE --dns-servers $dcIpAddress

---
```
