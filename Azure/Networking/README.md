### Learning Paths:
- [AZ-104: Configure and manage virtual networks for Azure administrators](https://docs.microsoft.com/en-us/learn/paths/az-104-manage-virtual-networks/)
- [AZ-500: Implement network security in Azure](https://docs.microsoft.com/en-us/learn/paths/implement-network-security/)
- [AZ-303, AZ-304: Architect network infrastructure in Azure](https://docs.microsoft.com/en-us/learn/paths/architect-network-infrastructure/)

### Tools:
- [IP Subnet Calculator](https://www.calculator.net/ip-subnet-calculator.html)
- [nslookup](https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/nslookup)
- [Dig (DNS lookup)](https://toolbox.googleapps.com/apps/dig/)
- [Network Watcher | Topology](https://portal.azure.com/#blade/Microsoft_Azure_Network/NetworkWatcherMenuBlade/topology)
- [Network Watcher | Connection monitor](https://portal.azure.com/#blade/Microsoft_Azure_Network/NetworkWatcherMenuBlade/connectionMonitor)
- [Network Watcher | IP flow verify](https://portal.azure.com/#blade/Microsoft_Azure_Network/NetworkWatcherMenuBlade/verifyIPFlow)
- [Network Watcher | Usage + quotas](https://portal.azure.com/#blade/Microsoft_Azure_Network/NetworkWatcherMenuBlade/usage)

### Common Scripts:
<details>
  <summary><b>Network + Subnets</b></summary>
  
  ```
az group create --name "LearnNetworking" \
                --location "southeastasia"

az network vnet create -g LearnNetworking \
                       -n MyVnet \
                       --address-prefix 10.0.0.0/16 \
                       --subnet-name default \
                       --subnet-prefix 10.0.0.0/24

az network vnet subnet create --address-prefixes 10.0.1.0/24 \
                              --name GatewaySubnet \
                              --resource-group LearnNetworking \
                              --vnet-name MyVnet

az network vnet subnet create --address-prefixes 10.0.2.0/24 \
                              --name ApplicationGateway \
                              --resource-group LearnNetworking \
                              --vnet-name MyVnet

az vm create --resource-group LearnNetworking \
             --location "southeastasia" \
             --name MyVM1 \
             --image win2016datacenter \
             --admin-username azureuser \
             --admin-password abcABC123'!''@''#' \
             --vnet-name MyVnet \
             --subnet default

az vm create --resource-group LearnNetworking \
             --location "southeastasia" \
             --name MyVM2 \
             --image win2016datacenter \
             --admin-username azureuser \
             --admin-password abcABC123'!''@''#' \
             --vnet-name MyVnet \
             --subnet default \
             --public-ip-address ""

az group delete --name LearnNetworking --yes

  ```
</details>

<details>
  <summary><b>Network Peering</b></summary>
  
  ```
az group create --name "LearnNetworking" \
                --location "southeastasia"

az network vnet create -g LearnNetworking \
                       -n MyVnet1 \
                       --location "southeastasia" \
                       --address-prefix 10.1.0.0/16 \
                       --subnet-name default \
                       --subnet-prefix 10.1.0.0/24

az network vnet create -g LearnNetworking \
                       -n MyVnet2 \
                       --location "eastasia" \
                       --address-prefix 10.2.0.0/16 \
                       --subnet-name default \
                       --subnet-prefix 10.2.0.0/24

az network vnet create -g LearnNetworking \
                       -n MyVnet3 \
                       --location "northeurope" \
                       --address-prefix 10.3.0.0/16 \
                       --subnet-name default \
                       --subnet-prefix 10.3.0.0/24

az network vnet peering create \
    --name MyVnet1-To-MyVnet2 \
    --resource-group LearnNetworking \
    --vnet-name MyVnet1 \
    --remote-vnet MyVnet2 \
    --allow-vnet-access

az network vnet peering create \
    --name MyVnet2-To-MyVnet1 \
    --resource-group LearnNetworking \
    --vnet-name MyVnet2 \
    --remote-vnet MyVnet1 \
    --allow-vnet-access

az network vnet peering create \
    --name MyVnet1-To-MyVnet3 \
    --resource-group LearnNetworking \
    --vnet-name MyVnet1 \
    --remote-vnet MyVnet3 \
    --allow-vnet-access

az network vnet peering create \
    --name MyVnet3-To-MyVnet1 \
    --resource-group LearnNetworking \
    --vnet-name MyVnet3 \
    --remote-vnet MyVnet1 \
    --allow-vnet-access

az network vnet peering create \
    --name MyVnet2-To-MyVnet3 \
    --resource-group LearnNetworking \
    --vnet-name MyVnet2 \
    --remote-vnet MyVnet3 \
    --allow-vnet-access

az network vnet peering create \
    --name MyVnet3-To-MyVnet2 \
    --resource-group LearnNetworking \
    --vnet-name MyVnet3 \
    --remote-vnet MyVnet2 \
    --allow-vnet-access

az group delete --name LearnNetworking --yes

  ```
</details>

<details>
  <summary><b>Virtual Network Traffic Routing</b></summary>
  
  ```
az group create --name "LearnNetworking" \
                --location "southeastasia"

az network route-table create \
    --name publictable \
    --resource-group LearnNetworking \
    --disable-bgp-route-propagation false

az network route-table route create \
    --route-table-name publictable \
    --resource-group LearnNetworking \
    --name productionsubnet \
    --address-prefix 10.0.1.0/24 \
    --next-hop-type VirtualAppliance \
    --next-hop-ip-address 10.0.2.4
	
az network vnet create \
    --name vnet \
    --resource-group LearnNetworking \
    --address-prefix 10.0.0.0/16 \
    --subnet-name publicsubnet \
    --subnet-prefix 10.0.0.0/24
	
az network vnet subnet create \
    --name privatesubnet \
    --vnet-name vnet \
    --resource-group LearnNetworking \
    --address-prefix 10.0.1.0/24
	
az network vnet subnet create \
    --name dmzsubnet \
    --vnet-name vnet \
    --resource-group LearnNetworking \
    --address-prefix 10.0.2.0/24
	
az network vnet subnet update \
    --name publicsubnet \
    --vnet-name vnet \
    --resource-group LearnNetworking \
    --route-table publictable
	
az vm create \
    --resource-group LearnNetworking \
    --name nva \
    --vnet-name vnet \
    --subnet dmzsubnet \
    --image UbuntuLTS \
    --admin-username azureuser \
    --admin-password abcABC123'!@#'
	
NVAIP="$(az vm list-ip-addresses \
    --resource-group LearnNetworking \
    --name nva \
    --query "[].virtualMachine.network.publicIpAddresses[*].ipAddress" \
    --output tsv)"

echo $NVAIP

NICID=$(az vm nic list \
    --resource-group LearnNetworking \
    --vm-name nva \
    --query "[].{id:id}" --output tsv)

echo $NICID

NICNAME=$(az vm nic show \
    --resource-group LearnNetworking \
    --vm-name nva \
    --nic $NICID \
    --query "{name:name}" --output tsv)

echo $NICNAME

az network nic update --name $NICNAME \
    --resource-group LearnNetworking \
    --ip-forwarding true
	
ssh -t -o StrictHostKeyChecking=no azureuser@$NVAIP 'sudo sysctl -w net.ipv4.ip_forward=1; exit;'

code cloud-init.txt

#cloud-config
package_upgrade: true
packages:
   - inetutils-traceroute

az vm create \
    --resource-group LearnNetworking \
    --name public \
    --vnet-name vnet \
    --subnet publicsubnet \
    --image UbuntuLTS \
    --admin-username azureuser \
    --no-wait \
    --custom-data cloud-init.txt \
    --admin-password abcABC123'!@#'
	
az vm create \
    --resource-group LearnNetworking \
    --name private \
    --vnet-name vnet \
    --subnet privatesubnet \
    --image UbuntuLTS \
    --admin-username azureuser \
    --no-wait \
    --custom-data cloud-init.txt \
    --admin-password abcABC123'!@#'

watch -d -n 5 "az vm list \
    --resource-group LearnNetworking \
    --show-details \
    --query '[*].{Name:name, ProvisioningState:provisioningState, PowerState:powerState}' \
    --output table"
	
PUBLICIP="$(az vm list-ip-addresses \
    --resource-group LearnNetworking \
    --name public \
    --query "[].virtualMachine.network.publicIpAddresses[*].ipAddress" \
    --output tsv)"

echo $PUBLICIP

PRIVATEIP="$(az vm list-ip-addresses \
    --resource-group LearnNetworking \
    --name private \
    --query "[].virtualMachine.network.publicIpAddresses[*].ipAddress" \
    --output tsv)"

echo $PRIVATEIP

ssh -t -o StrictHostKeyChecking=no azureuser@$PUBLICIP 'traceroute private --type=icmp; exit'

ssh -t -o StrictHostKeyChecking=no azureuser@$PRIVATEIP 'traceroute public --type=icmp; exit'

az group delete --name LearnNetworking --yes

  ```
</details>

<details>
  <summary><b>Connect your on-premises network to Azure with VPN Gateway</b></summary>
  
  ```
-- Azure network

az network vnet create \
    --resource-group learn-4ca3b30b-dd92-48f5-ac40-21b72671465f \
    --name Azure-VNet-1 \
    --address-prefix 10.0.0.0/16 \
    --subnet-name Services \
    --subnet-prefix 10.0.0.0/24

az network vnet subnet create \
    --resource-group learn-4ca3b30b-dd92-48f5-ac40-21b72671465f \
    --vnet-name Azure-VNet-1 \
    --address-prefix 10.0.255.0/27 \
    --name GatewaySubnet

az network local-gateway create \
    --resource-group learn-4ca3b30b-dd92-48f5-ac40-21b72671465f \
    --gateway-ip-address 94.0.252.160 \
    --name LNG-HQ-Network \
    --local-address-prefixes 172.16.0.0/16

az network public-ip create \
    --resource-group learn-4ca3b30b-dd92-48f5-ac40-21b72671465f \
    --name PIP-VNG-Azure-VNet-1 \
    --allocation-method Dynamic

az network vnet-gateway create \
    --resource-group learn-4ca3b30b-dd92-48f5-ac40-21b72671465f \
    --name VNG-Azure-VNet-1 \
    --public-ip-address PIP-VNG-Azure-VNet-1 \
    --vnet Azure-VNet-1 \
    --gateway-type Vpn \
    --vpn-type RouteBased \
    --sku VpnGw1 \
    --no-wait	

-- Simulated on-premises network

az network vnet create \
    --resource-group learn-4ca3b30b-dd92-48f5-ac40-21b72671465f \
    --name HQ-Network \
    --address-prefix 172.16.0.0/16 \
    --subnet-name Applications \
    --subnet-prefix 172.16.0.0/24

az network vnet subnet create \
    --resource-group learn-4ca3b30b-dd92-48f5-ac40-21b72671465f \
    --address-prefix 172.16.255.0/27 \
    --name GatewaySubnet \
    --vnet-name HQ-Network

az network local-gateway create \
    --resource-group learn-4ca3b30b-dd92-48f5-ac40-21b72671465f \
    --gateway-ip-address 94.0.252.160 \
    --name LNG-Azure-VNet-1 \
    --local-address-prefixes 10.0.0.0/16

az network public-ip create \
    --resource-group learn-4ca3b30b-dd92-48f5-ac40-21b72671465f \
    --name PIP-VNG-HQ-Network \
    --allocation-method Dynamic

az network vnet-gateway create \
    --resource-group learn-4ca3b30b-dd92-48f5-ac40-21b72671465f \
    --name VNG-HQ-Network \
    --public-ip-address PIP-VNG-HQ-Network \
    --vnet HQ-Network \
    --gateway-type Vpn \
    --vpn-type RouteBased \
    --sku VpnGw1 \
    --no-wait

-- Monitor the progress of the gateway creation

watch -d -n 5 az network vnet-gateway list \
    --resource-group learn-4ca3b30b-dd92-48f5-ac40-21b72671465f \
    --output table

-- Update the local network gateway IP references

az network vnet-gateway list \
    --resource-group learn-4ca3b30b-dd92-48f5-ac40-21b72671465f \
    --query "[?provisioningState=='Succeeded']" \
    --output table

PIPVNGAZUREVNET1=$(az network public-ip show \
    --resource-group learn-4ca3b30b-dd92-48f5-ac40-21b72671465f \
    --name PIP-VNG-Azure-VNet-1 \
    --query "[ipAddress]" \
    --output tsv)

az network local-gateway update \
    --resource-group learn-4ca3b30b-dd92-48f5-ac40-21b72671465f \
    --name LNG-Azure-VNet-1 \
    --gateway-ip-address $PIPVNGAZUREVNET1

PIPVNGHQNETWORK=$(az network public-ip show \
    --resource-group learn-4ca3b30b-dd92-48f5-ac40-21b72671465f \
    --name PIP-VNG-HQ-Network \
    --query "[ipAddress]" \
    --output tsv)

az network local-gateway update \
    --resource-group learn-4ca3b30b-dd92-48f5-ac40-21b72671465f \
    --name LNG-HQ-Network \
    --gateway-ip-address $PIPVNGHQNETWORK

-- Create connections:

SHAREDKEY=4ca3b30b-dd92-48f5-ac40-21b72671465f

az network vpn-connection create \
    --resource-group learn-4ca3b30b-dd92-48f5-ac40-21b72671465f \
    --name Azure-VNet-1-To-HQ-Network \
    --vnet-gateway1 VNG-Azure-VNet-1 \
    --shared-key $SHAREDKEY \
    --local-gateway2 LNG-HQ-Network

az network vpn-connection create \
    --resource-group learn-4ca3b30b-dd92-48f5-ac40-21b72671465f \
    --name HQ-Network-To-Azure-VNet-1  \
    --vnet-gateway1 VNG-HQ-Network \
    --shared-key $SHAREDKEY \
    --local-gateway2 LNG-Azure-VNet-1

-- Verify:

az network vpn-connection show \
    --resource-group learn-4ca3b30b-dd92-48f5-ac40-21b72671465f \
    --name Azure-VNet-1-To-HQ-Network  \
    --output table \
    --query '{Name:name,ConnectionStatus:connectionStatus}'

az network vpn-connection show \
    --resource-group learn-4ca3b30b-dd92-48f5-ac40-21b72671465f \
    --name HQ-Network-To-Azure-VNet-1  \
    --output table \
    --query '{Name:name,ConnectionStatus:connectionStatus}'

  ```
</details>

<details>
  <summary><b>Network Security Groups & Service Endpoints</b></summary>
  
  ```
az group create --name "LearnNetworking" \
                --location "southeastasia"
			  
az network vnet create \
    --resource-group LearnNetworking \
    --name ERP-servers \
    --address-prefix 10.0.0.0/16 \
    --subnet-name Applications \
    --subnet-prefix 10.0.0.0/24
	
az network vnet subnet create \
    --resource-group LearnNetworking \
    --vnet-name ERP-servers \
    --address-prefix 10.0.1.0/24 \
    --name Databases
	
az network nsg create \
    --resource-group LearnNetworking \
    --name ERP-SERVERS-NSG
	
wget -N https://raw.githubusercontent.com/MicrosoftDocs/mslearn-secure-and-isolate-with-nsg-and-service-endpoints/master/cloud-init.yml && \
az vm create \
    --resource-group LearnNetworking \
    --name AppServer \
    --vnet-name ERP-servers \
    --subnet Applications \
    --nsg ERP-SERVERS-NSG \
    --image UbuntuLTS \
    --size Standard_DS1_v2 \
    --admin-username azureuser \
    --custom-data cloud-init.yml \
    --no-wait \
    --admin-password abcABC123'!@#'
	
az vm create \
    --resource-group LearnNetworking \
    --name DataServer \
    --vnet-name ERP-servers \
    --subnet Databases \
    --nsg ERP-SERVERS-NSG \
    --size Standard_DS1_v2 \
    --image UbuntuLTS \
    --admin-username azureuser \
    --custom-data cloud-init.yml \
    --admin-password abcABC123'!@#'
	
az vm list \
    --resource-group LearnNetworking \
    --show-details \
    --query "[*].{Name:name, Provisioned:provisioningState, Power:powerState}" \
    --output table
	
az vm list \
    --resource-group LearnNetworking \
    --show-details \
    --query "[*].{Name:name, PrivateIP:privateIps, PublicIP:publicIps}" \
    --output table
	
APPSERVERIP="$(az vm list-ip-addresses \
                 --resource-group LearnNetworking \
                 --name AppServer \
                 --query "[].virtualMachine.network.publicIpAddresses[*].ipAddress" \
                 --output tsv)"

DATASERVERIP="$(az vm list-ip-addresses \
                 --resource-group LearnNetworking \
                 --name DataServer \
                 --query "[].virtualMachine.network.publicIpAddresses[*].ipAddress" \
                 --output tsv)"
				 
ssh azureuser@$APPSERVERIP -o ConnectTimeout=5

ssh azureuser@$DATASERVERIP -o ConnectTimeout=5

az network nsg rule create \
    --resource-group LearnNetworking \
    --nsg-name ERP-SERVERS-NSG \
    --name AllowSSHRule \
    --direction Inbound \
    --priority 100 \
    --source-address-prefixes '*' \
    --source-port-ranges '*' \
    --destination-address-prefixes '*' \
    --destination-port-ranges 22 \
    --access Allow \
    --protocol Tcp \
    --description "Allow inbound SSH"

ssh azureuser@$APPSERVERIP -o ConnectTimeout=5

ssh azureuser@$DATASERVERIP -o ConnectTimeout=5

az network nsg rule create \
    --resource-group LearnNetworking \
    --nsg-name ERP-SERVERS-NSG \
    --name httpRule \
    --direction Inbound \
    --priority 150 \
    --source-address-prefixes 10.0.1.4 \
    --source-port-ranges '*' \
    --destination-address-prefixes 10.0.0.4 \
    --destination-port-ranges 80 \
    --access Deny \
    --protocol Tcp \
    --description "Deny from DataServer to AppServer on port 80"
	
ssh -t azureuser@$APPSERVERIP 'wget http://10.0.1.4; exit; bash'

ssh -t azureuser@$DATASERVERIP 'wget http://10.0.0.4; exit; bash'

az network asg create \
    --resource-group LearnNetworking \
    --name ERP-DB-SERVERS-ASG
	
az network nic ip-config update \
    --resource-group LearnNetworking \
    --application-security-groups ERP-DB-SERVERS-ASG \
    --name ipconfigDataServer \
    --nic-name DataServerVMNic \
    --vnet-name ERP-servers \
    --subnet Databases
	
az network nsg rule update \
    --resource-group LearnNetworking \
    --nsg-name ERP-SERVERS-NSG \
    --name httpRule \
    --direction Inbound \
    --priority 150 \
    --source-address-prefixes "" \
    --source-port-ranges '*' \
    --source-asgs ERP-DB-SERVERS-ASG \
    --destination-address-prefixes 10.0.0.4 \
    --destination-port-ranges 80 \
    --access Deny \
    --protocol Tcp \
    --description "Deny from DataServer to AppServer on port 80 using application security group"
	
ssh -t azureuser@$APPSERVERIP 'wget http://10.0.1.4; exit; bash'

ssh -t azureuser@$DATASERVERIP 'wget http://10.0.0.4; exit; bash'

az network nsg rule create \
    --resource-group LearnNetworking \
    --nsg-name ERP-SERVERS-NSG \
    --name Allow_Storage \
    --priority 190 \
    --direction Outbound \
    --source-address-prefixes "VirtualNetwork" \
    --source-port-ranges '*' \
    --destination-address-prefixes "Storage" \
    --destination-port-ranges '*' \
    --access Allow \
    --protocol '*' \
    --description "Allow access to Azure Storage"
	
az network nsg rule create \
    --resource-group LearnNetworking \
    --nsg-name ERP-SERVERS-NSG \
    --name Deny_Internet \
    --priority 200 \
    --direction Outbound \
    --source-address-prefixes "VirtualNetwork" \
    --source-port-ranges '*' \
    --destination-address-prefixes "Internet" \
    --destination-port-ranges '*' \
    --access Deny \
    --protocol '*' \
    --description "Deny access to Internet."
	
STORAGEACCT=$(az storage account create \
                --resource-group LearnNetworking \
                --name engineeringdocs$RANDOM \
                --sku Standard_LRS \
                --query "name" | tr -d '"')
				
STORAGEKEY=$(az storage account keys list \
                --resource-group LearnNetworking \
                --account-name $STORAGEACCT \
                --query "[0].value" | tr -d '"')
				
az storage share create \
    --account-name $STORAGEACCT \
    --account-key $STORAGEKEY \
    --name "erp-data-share"
	
az network vnet subnet update \
    --vnet-name ERP-servers \
    --resource-group LearnNetworking \
    --name Databases \
    --service-endpoints Microsoft.Storage
	
az storage account update \
    --resource-group LearnNetworking \
    --name $STORAGEACCT \
    --default-action Deny

az storage account network-rule add \
    --resource-group LearnNetworking \
    --account-name $STORAGEACCT \
    --vnet ERP-servers \
    --subnet Databases
	
APPSERVERIP="$(az vm list-ip-addresses \
                    --resource-group LearnNetworking \
                    --name AppServer \
                    --query "[].virtualMachine.network.publicIpAddresses[*].ipAddress" \
                    --output tsv)"

DATASERVERIP="$(az vm list-ip-addresses \
                    --resource-group LearnNetworking \
                    --name DataServer \
                    --query "[].virtualMachine.network.publicIpAddresses[*].ipAddress" \
                    --output tsv)"
					
ssh -t azureuser@$APPSERVERIP \
    "mkdir azureshare; \
    sudo mount -t cifs //$STORAGEACCT.file.core.windows.net/erp-data-share azureshare \
    -o vers=3.0,username=$STORAGEACCT,password=$STORAGEKEY,dir_mode=0777,file_mode=0777,sec=ntlmssp; findmnt \
    -t cifs; exit; bash"
	
ssh -t azureuser@$DATASERVERIP \
    "mkdir azureshare; \
    sudo mount -t cifs //$STORAGEACCT.file.core.windows.net/erp-data-share azureshare \
    -o vers=3.0,username=$STORAGEACCT,password=$STORAGEKEY,dir_mode=0777,file_mode=0777,sec=ntlmssp;findmnt \
    -t cifs; exit; bash"

az group delete --name LearnNetworking --yes

  ```
</details>

<details>
  <summary><b>Load balance with Application Gateway</b></summary>
  
  ```
rg=LearnNetworking

az group create --name $rg --location southeastasia

az network vnet create \
  --resource-group $rg \
  --name vehicleAppVnet \
  --address-prefix 10.0.0.0/16 \
  --subnet-name webServerSubnet \
  --subnet-prefix 10.0.1.0/24
  
git clone https://github.com/MicrosoftDocs/mslearn-load-balance-web-traffic-with-application-gateway module-files

az vm create \
  --resource-group $rg \
  --name webServer1 \
  --image UbuntuLTS \
  --admin-username azureuser \
  --generate-ssh-keys \
  --vnet-name vehicleAppVnet \
  --subnet webServerSubnet \
  --public-ip-address "" \
  --nsg "" \
  --custom-data module-files/scripts/vmconfig.sh \
  --no-wait

az vm create \
  --resource-group $rg \
  --name webServer2 \
  --image UbuntuLTS \
  --admin-username azureuser \
  --generate-ssh-keys \
  --vnet-name vehicleAppVnet \
  --subnet webServerSubnet \
  --public-ip-address "" \
  --nsg "" \
  --custom-data module-files/scripts/vmconfig.sh
  
az vm list \
  --resource-group $rg \
  --show-details \
  --output table
  
APPSERVICE="licenserenewal$RANDOM"

az appservice plan create \
    --resource-group $rg \
    --name vehicleAppServicePlan \
    --sku S1
	
az webapp create \
    --resource-group $rg \
    --name $APPSERVICE \
    --plan vehicleAppServicePlan \
    --deployment-source-url https://github.com/MicrosoftDocs/mslearn-load-balance-web-traffic-with-application-gateway \
    --deployment-source-branch appService

az network vnet subnet create \
  --resource-group $rg \
  --vnet-name vehicleAppVnet  \
  --name appGatewaySubnet \
  --address-prefixes 10.0.0.0/24
  
az network public-ip create \
  --resource-group $rg \
  --name appGatewayPublicIp \
  --sku Standard \
  --dns-name vehicleapp${RANDOM}

az network application-gateway create \
--resource-group $rg \
--name vehicleAppGateway \
--sku WAF_v2 \
--capacity 2 \
--vnet-name vehicleAppVnet \
--subnet appGatewaySubnet \
--public-ip-address appGatewayPublicIp \
--http-settings-protocol Http \
--http-settings-port 8080 \
--frontend-port 8080

WEBSERVER1IP="$(az vm list-ip-addresses \
  --resource-group $rg \
  --name webServer1 \
  --query [0].virtualMachine.network.privateIpAddresses[0] \
  --output tsv)"

WEBSERVER2IP="$(az vm list-ip-addresses \
  --resource-group $rg \
  --name webserver2 \
  --query [0].virtualMachine.network.privateIpAddresses[0] \
  --output tsv)"
  
az network application-gateway address-pool create \
  --gateway-name vehicleAppGateway \
  --resource-group $rg \
  --name vmPool \
  --servers $WEBSERVER1IP $WEBSERVER2IP
  
az network application-gateway address-pool create \
    --resource-group $rg \
    --gateway-name vehicleAppGateway \
    --name appServicePool \
    --servers $APPSERVICE.azurewebsites.net
	
az network application-gateway frontend-port create \
    --resource-group $rg \
    --gateway-name vehicleAppGateway \
    --name port80 \
    --port 80
	
az network application-gateway http-listener create \
    --resource-group $rg \
    --name vehicleListener \
    --frontend-port port80 \
    --gateway-name vehicleAppGateway
	
az network application-gateway probe create \
    --resource-group $rg \
    --gateway-name vehicleAppGateway \
    --name customProbe \
    --path / \
    --interval 15 \
    --threshold 3 \
    --timeout 10 \
    --protocol Http \
    --host-name-from-http-settings true
	
az network application-gateway http-settings update \
    --resource-group $rg \
    --gateway-name vehicleAppGateway \
    --name appGatewayBackendHttpSettings \
    --host-name-from-backend-pool true \
    --port 80 \
    --probe customProbe
	
az network application-gateway url-path-map create \
    --resource-group $rg \
    --gateway-name vehicleAppGateway \
    --name urlPathMap \
    --paths /VehicleRegistration/* \
    --http-settings appGatewayBackendHttpSettings \
    --address-pool vmPool
	
az network application-gateway url-path-map rule create \
    --resource-group $rg \
    --gateway-name vehicleAppGateway \
    --name appServiceUrlPathMap \
    --paths /LicenseRenewal/* \
    --http-settings appGatewayBackendHttpSettings \
    --address-pool appServicePool \
    --path-map-name urlPathMap
	
az network application-gateway rule create \
    --resource-group $rg \
    --gateway-name vehicleAppGateway \
    --name appServiceRule \
    --http-listener vehicleListener \
    --rule-type PathBasedRouting \
    --address-pool appServicePool \
    --url-path-map urlPathMap
	
az network application-gateway rule delete \
    --resource-group $rg \
    --gateway-name vehicleAppGateway \
    --name rule1
	
echo http://$(az network public-ip show \
  --resource-group $rg \
  --name appGatewayPublicIp \
  --query dnsSettings.fqdn \
  --output tsv)
  
az vm deallocate \
  --resource-group $rg \
  --name webServer1
  
az vm start \
  --resource-group $rg \
  --name webServer1
  
az group delete --name $rg --yes
  ```
</details>

<details>
  <summary><b>Load balance with Azure Load Balancer</b></summary>
  
  ```
git clone https://github.com/MicrosoftDocs/mslearn-improve-app-scalability-resiliency-with-load-balancer.git
cd mslearn-improve-app-scalability-resiliency-with-load-balancer
bash create-high-availability-vm-with-sets.sh learn-24ae0fc7-4c60-4d5f-b184-4db2ebff6ff2

az network public-ip create \
  --resource-group learn-24ae0fc7-4c60-4d5f-b184-4db2ebff6ff2 \
  --allocation-method Static \
  --name myPublicIP
  
az network lb create \
  --resource-group learn-24ae0fc7-4c60-4d5f-b184-4db2ebff6ff2 \
  --name myLoadBalancer \
  --public-ip-address myPublicIP \
  --frontend-ip-name myFrontEndPool \
  --backend-pool-name myBackEndPool
  
az network lb probe create \
  --resource-group learn-24ae0fc7-4c60-4d5f-b184-4db2ebff6ff2 \
  --lb-name myLoadBalancer \
  --name myHealthProbe \
  --protocol tcp \
  --port 80
  
az network lb rule create \
  --resource-group learn-24ae0fc7-4c60-4d5f-b184-4db2ebff6ff2 \
  --lb-name myLoadBalancer \
  --name myHTTPRule \
  --protocol tcp \
  --frontend-port 80 \
  --backend-port 80 \
  --frontend-ip-name myFrontEndPool \
  --backend-pool-name myBackEndPool \
  --probe-name myHealthProbe
  
az network nic ip-config update \
  --resource-group learn-24ae0fc7-4c60-4d5f-b184-4db2ebff6ff2 \
  --nic-name webNic1 \
  --name ipconfig1 \
  --lb-name myLoadBalancer \
  --lb-address-pools myBackEndPool

az network nic ip-config update \
  --resource-group learn-24ae0fc7-4c60-4d5f-b184-4db2ebff6ff2 \
  --nic-name webNic2 \
  --name ipconfig1 \
  --lb-name myLoadBalancer \
  --lb-address-pools myBackEndPool
  
echo http://$(az network public-ip show \
                --resource-group learn-24ae0fc7-4c60-4d5f-b184-4db2ebff6ff2 \
                --name myPublicIP \
                --query ipAddress \
                --output tsv)
				
  ```
</details>

<details>
  <summary><b>Encrypt network traffic end to end with Azure Application Gateway</b></summary>
  
  ```
export rgName=LearnNetworking

az group create --name $rgName --location southeastasia

git clone https://github.com/MicrosoftDocs/mslearn-end-to-end-encryption-with-app-gateway shippingportal
cd shippingportal
bash setup-infra.sh

echo https://"$(az vm show \
  --name webservervm1 \
  --resource-group $rgName \
  --show-details \
  --query [publicIps] \
  --output tsv)"
  
privateip="$(az vm list-ip-addresses \
  --resource-group $rgName \
  --name webservervm1 \
  --query "[0].virtualMachine.network.privateIpAddresses[0]" \
  --output tsv)"
  
az network application-gateway address-pool create \
  --resource-group $rgName \
  --gateway-name gw-shipping \
  --name ap-backend \
  --servers $privateip
  
az network application-gateway root-cert create \
  --resource-group $rgName \
  --gateway-name gw-shipping \
  --name shipping-root-cert \
  --cert-file server-config/shipping-ssl.crt
  
az network application-gateway http-settings create \
  --resource-group $rgName \
  --gateway-name gw-shipping \
  --name https-settings \
  --port 443 \
  --protocol Https \
  --host-name $privateip
  
rgID="$(az group show --name $rgName --query id --output tsv)"

az network application-gateway http-settings update \
    --resource-group $rgName \
    --gateway-name gw-shipping \
    --name https-settings \
    --set trustedRootCertificates='[{"id": "'$rgID'/providers/Microsoft.Network/applicationGateways/gw-shipping/trustedRootCertificates/shipping-root-cert"}]'
	
az network application-gateway frontend-port create \
  --resource-group $rgName \
  --gateway-name gw-shipping \
  --name https-port \
  --port 443
  
az network application-gateway ssl-cert create \
   --resource-group $rgName \
   --gateway-name gw-shipping \
   --name appgateway-cert \
   --cert-file server-config/appgateway.pfx \
   --cert-password somepassword
   
az network application-gateway http-listener create \
  --resource-group $rgName \
  --gateway-name gw-shipping \
  --name https-listener \
  --frontend-port https-port \
  --ssl-cert appgateway-cert
  
az network application-gateway rule create \
    --resource-group $rgName \
    --gateway-name gw-shipping \
    --name https-rule \
    --address-pool ap-backend \
    --http-listener https-listener \
    --http-settings https-settings \
    --rule-type Basic
	
echo https://$(az network public-ip show \
  --resource-group $rgName \
  --name appgwipaddr \
  --query ipAddress \
  --output tsv)
  
az group delete --name $rgName --yes		
  ```
</details>

<details>
  <summary><b>DNS Load Balancing with Azure Traffic Manager</b></summary>
  
  ```
az network traffic-manager profile create \
    --resource-group learn-a10af545-e9e7-409b-be6f-b5d342c439fa \
    --name TM-MusicStream-Priority \
    --routing-method Priority \
    --unique-dns-name TM-MusicStream-Priority-$RANDOM
	
az deployment group create \
    --resource-group learn-a10af545-e9e7-409b-be6f-b5d342c439fa \
    --template-uri  https://raw.githubusercontent.com/MicrosoftDocs/mslearn-distribute-load-with-traffic-manager/master/azuredeploy.json \
    --parameters password="$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 32)"
	
WestId=$(az network public-ip show \
    --resource-group learn-a10af545-e9e7-409b-be6f-b5d342c439fa \
    --name westus2-vm-nic-pip \
    --query id \
    --out tsv)

az network traffic-manager endpoint create \
    --resource-group learn-a10af545-e9e7-409b-be6f-b5d342c439fa \
    --profile-name TM-MusicStream-Priority \
    --name "Primary-WestUS" \
    --type azureEndpoints \
    --priority 1 \
    --target-resource-id $WestId

EastId=$(az network public-ip show \
    --resource-group learn-a10af545-e9e7-409b-be6f-b5d342c439fa \
    --name eastasia-vm-nic-pip \
    --query id \
    --out tsv)

az network traffic-manager endpoint create \
    --resource-group learn-a10af545-e9e7-409b-be6f-b5d342c439fa \
    --profile-name TM-MusicStream-Priority \
    --name "Failover-EastAsia" \
    --type azureEndpoints \
    --priority 2 \
    --target-resource-id $EastId
	
az network traffic-manager endpoint list \
    --resource-group learn-a10af545-e9e7-409b-be6f-b5d342c439fa \
    --profile-name TM-MusicStream-Priority \
    --output table
	
# Retrieve the address for the West US 2 web app
nslookup $(az network public-ip show \
            --resource-group learn-a10af545-e9e7-409b-be6f-b5d342c439fa \
            --name eastasia-vm-nic-pip \
            --query dnsSettings.fqdn \
            --output tsv)
# Retrieve the address for the East Asia web app
nslookup $(az network public-ip show \
            --resource-group learn-a10af545-e9e7-409b-be6f-b5d342c439fa \
            --name westus2-vm-nic-pip \
            --query dnsSettings.fqdn \
            --output tsv)
# Retrieve the address for the Traffic Manager profile
nslookup $(az network traffic-manager profile show \
            --resource-group learn-a10af545-e9e7-409b-be6f-b5d342c439fa \
            --name TM-MusicStream-Priority \
            --query dnsConfig.fqdn \
            --out tsv)
			
echo http://$(az network traffic-manager profile show \
    --resource-group learn-a10af545-e9e7-409b-be6f-b5d342c439fa \
    --name TM-MusicStream-Priority \
    --query dnsConfig.fqdn \
    --out tsv)
	
az network traffic-manager endpoint update \
    --resource-group learn-a10af545-e9e7-409b-be6f-b5d342c439fa  \
    --name "Primary-WestUS" \
    --profile-name TM-MusicStream-Priority \
    --type azureEndpoints \
    --endpoint-status Disabled
	
# Retrieve the address for the West US 2 web app
nslookup $(az network public-ip show \
            --resource-group learn-a10af545-e9e7-409b-be6f-b5d342c439fa \
            --name eastasia-vm-nic-pip \
            --query dnsSettings.fqdn \
            --output tsv)
# Retrieve the address for the East Asia web app
nslookup $(az network public-ip show \
            --resource-group learn-a10af545-e9e7-409b-be6f-b5d342c439fa \
            --name westus2-vm-nic-pip \
            --query dnsSettings.fqdn \
            --output tsv)
# Retrieve the address for the Traffic Manager profile
nslookup $(az network traffic-manager profile show \
            --resource-group learn-a10af545-e9e7-409b-be6f-b5d342c439fa \
            --name TM-MusicStream-Priority \
            --query dnsConfig.fqdn \
            --out tsv)
			
### Create a Traffic Manager profile using performance routing ###

az network traffic-manager profile create \
    --resource-group learn-a10af545-e9e7-409b-be6f-b5d342c439fa \
    --name TM-MusicStream-Performance \
    --routing-method Performance \
    --unique-dns-name TM-MusicStream-Performance-$RANDOM \
    --output table
	
WestId=$(az network public-ip show \
    --resource-group learn-a10af545-e9e7-409b-be6f-b5d342c439fa \
    --name westus2-vm-nic-pip \
    --query id \
    --out tsv)

az network traffic-manager endpoint create \
    --resource-group learn-a10af545-e9e7-409b-be6f-b5d342c439fa \
    --profile-name TM-MusicStream-Performance \
    --name "WestUS" \
    --type azureEndpoints \
    --target-resource-id $WestId

EastId=$(az network public-ip show \
    --resource-group learn-a10af545-e9e7-409b-be6f-b5d342c439fa \
    --name eastasia-vm-nic-pip \
    --query id \
    --out tsv)

az network traffic-manager endpoint create \
    --resource-group learn-a10af545-e9e7-409b-be6f-b5d342c439fa \
    --profile-name TM-MusicStream-Performance \
    --name "EastAsia" \
    --type azureEndpoints \
    --target-resource-id $EastId
	
echo http://$(az network traffic-manager profile show \
    --resource-group learn-a10af545-e9e7-409b-be6f-b5d342c439fa \
    --name TM-MusicStream-Performance \
    --query dnsConfig.fqdn \
    --output tsv)
	
nslookup $(az network traffic-manager profile show \
        --resource-group learn-a10af545-e9e7-409b-be6f-b5d342c439fa \
        --name TM-MusicStream-Performance \
        --query dnsConfig.fqdn \
        --output tsv)	
  ```
</details>
