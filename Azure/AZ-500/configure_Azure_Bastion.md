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

az network nsg create \
  --resource-group AZ500 \
  --name NSG
  
az network nsg create \
  --resource-group AZ500 \
  --name BASTION-NSG

az network nsg rule create \
  --resource-group AZ500 \
  --nsg-name BASTION-NSG \
  --name BastionInboundRule \
  --direction Inbound \
  --priority 100 \
  --source-address-prefixes '*' \
  --source-port-ranges '*' \
  --destination-address-prefixes '*' \
  --destination-port-ranges 443 8080 5701 \
  --access Allow \
  --protocol Tcp \
  --description "Bastion Inbound Rule"

az network nsg rule create \
  --resource-group AZ500 \
  --nsg-name BASTION-NSG \
  --name BastionOutboundRule \
  --direction Outbound \
  --priority 100 \
  --source-address-prefixes '*' \
  --source-port-ranges '*' \
  --destination-address-prefixes '*' \
  --destination-port-ranges 22 3389 8080 5701 443 \
  --access Allow \
  --protocol Tcp \
  --description "Bastion Outbound Rule"

az vm create \
 -g AZ500 \
 -n VM \
 --image win2016datacenter \
 --admin-username vmadmin \
 --admin-password 'abcABC123!@#' \
 --size Standard_D2s_v3 \
 --vnet-name VNET \
 --subnet default \
 --nsg NSG \
 --public-ip-address ''

az network vnet subnet create \
 --name AzureBastionSubnet \
 --resource-group AZ500 \
 --vnet-name VNET \
 --address-prefixes 10.0.1.0/24 \
 --network-security-group BASTION-NSG
 
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
