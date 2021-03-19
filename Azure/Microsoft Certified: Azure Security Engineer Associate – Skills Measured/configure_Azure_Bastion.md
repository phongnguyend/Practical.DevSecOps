- [Azure Bastion | Microsoft Docs](https://docs.microsoft.com/en-us/azure/bastion/bastion-overview)
- [Tutorial: Create an Azure Bastion host: Windows VM: portal | Microsoft Docs](https://docs.microsoft.com/en-us/azure/bastion/tutorial-create-host-portal)
- [Create a Bastion host using Azure CLI | Microsoft Docs](https://docs.microsoft.com/en-us/azure/bastion/create-host-cli)
- [Working with VMs and NSGs in Azure Bastion | Microsoft Docs](https://docs.microsoft.com/en-us/azure/bastion/bastion-nsg)

```
az group create --name AZ500 --location southeastasia

az network vnet create \
 --name VNET \
 --resource-group AZ500 \
 --address-prefix 10.0.0.0/16 \
 --subnet-name default \
 --subnet-prefix 10.0.0.0/24

az vm create \
 -g AZ500 \
 -n VM \
 --image win2016datacenter \
 --admin-username vmadmin \
 --admin-password 'abcABC123!@#' \
 --size Standard_D2s_v3 \
 --vnet-name VNET \
 --subnet default \
 --public-ip-address ''

az network vnet subnet create \
 --name AzureBastionSubnet \
 --resource-group AZ500 \
 --vnet-name VNET \
 --address-prefixes 10.0.1.0/24
 
az network public-ip create \
 --resource-group AZ500 \
 --name BASTIONIP \
 --sku Standard \
 --location southeastasia

az network bastion create \
 --name BASTION \
 --public-ip-address BASTIONIP \
 --resource-group AZ500 \
 --vnet-name VNET \
 --location southeastasia

```
