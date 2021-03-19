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
 
az network nsg create \
  --resource-group ANSIBLE \
  --name NSG

az vm image list -f windows -o table

az vm create \
 -g ANSIBLE \
 -n ANSIBLE \
 --image UbuntuLTS \
 --admin-username vmadmin \
 --admin-password 'abcABC123!@#' \
 --size Standard_D2s_v3 \
 --vnet-name VNET \
 --subnet default \
 --nsg NSG
 
az vm create \
 -g ANSIBLE \
 -n DC \
 --image win2016datacenter \
 --admin-username vmadmin \
 --admin-password 'abcABC123!@#' \
 --size Standard_D2s_v3 \
 --vnet-name VNET \
 --subnet default \
 --nsg NSG
 
az vm create \
 -g ANSIBLE \
 -n VM1 \
 --image win2016datacenter \
 --admin-username vmadmin \
 --admin-password 'abcABC123!@#' \
 --size Standard_D2s_v3 \
 --vnet-name VNET \
 --subnet default \
 --nsg NSG
 
az vm create \
 -g ANSIBLE \
 -n VM2 \
 --image win2016datacenter \
 --admin-username vmadmin \
 --admin-password 'abcABC123!@#' \
 --size Standard_D2s_v3 \
 --vnet-name VNET \
 --subnet default \
 --nsg NSG

dcIpAddress="$(az network nic ip-config show -g ANSIBLE -n ipconfigDC --nic-name DCVMNic --query "privateIpAddress" --out tsv)"
echo $dcIpAddress
az network nic update -n VM1VMNic -g ANSIBLE --dns-servers $dcIpAddress
az network nic update -n VM2VMNic -g ANSIBLE --dns-servers $dcIpAddress

az network nsg rule create \
 -g ANSIBLE \
 --nsg-name NSG \
 -n RDP \
 --priority 1001 \
 --destination-port-ranges 3389 \
 --access Allow \
 --protocol Tcp

az network nsg rule create \
 -g ANSIBLE \
 --nsg-name NSG \
 -n SSH \
 --priority 1002 \
 --destination-port-ranges 22 \
 --access Allow \
 --protocol Tcp

az network nsg rule create \
 -g ANSIBLE \
 --nsg-name NSG \
 -n WinRM \
 --priority 1003 \
 --destination-port-ranges 5986 \
 --access Allow \
 --protocol Tcp

ansiblePublicIpAddress="$(az vm show -d -g ANSIBLE -n ANSIBLE --query publicIps -o tsv)"
dcPublicIpAddress="$(az vm show -d -g ANSIBLE -n DC --query publicIps -o tsv)"
vm1PublicIpAddress="$(az vm show -d -g ANSIBLE -n VM1 --query publicIps -o tsv)"
vm2PublicIpAddress="$(az vm show -d -g ANSIBLE -n VM2 --query publicIps -o tsv)"
echo $ansiblePublicIpAddress
echo $dcPublicIpAddress
echo $vm1PublicIpAddress
echo $vm2PublicIpAddress
echo "ssh vmadmin@"$ansiblePublicIpAddress

---
```

## Setup Windows Hosts:
- [WinRM Setup](https://docs.ansible.com/ansible/latest/user_guide/windows_setup.html#winrm-setup)
- Download and Execute PowerShell:
  ```
  https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1
  powershell.exe -ExecutionPolicy ByPass -File "C:\ConfigureRemotingForAnsible.ps1"
  ```

## Connect to ANSIBLE Node over SSH with Vistual Studio Code
- [Install and Configure Vistual Studio Code Extension](https://code.visualstudio.com/docs/remote/ssh-tutorial)
- [Install Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-ansible-on-ubuntu)
  ```
  sudo apt update
  sudo apt install software-properties-common
  sudo apt-add-repository --yes --update ppa:ansible/ansible
  sudo apt install ansible python-pip
  pip install pywinrm

  sudo chown -R vmadmin /etc/ansible/
  ```
- Open /etc/ansible/hosts
  ```
  sudo vim /etc/ansible/hosts
  sudo nano /etc/ansible/hosts
  cat /etc/ansible/hosts
  ```
- Configure Hosts:
  ```
  [domaincontroler]
  10.0.0.5

  [domaincontroler:vars]
  ansible_user=vmadmin
  ansible_password=abcABC123!@#
  ansible_connection=winrm
  ansible_winrm_server_cert_validation=ignore

  [nodes]
  10.0.0.6
  10.0.0.7

  [nodes:vars]
  ansible_user=vmadmin
  ansible_password=abcABC123!@#
  ansible_connection=winrm
  ansible_winrm_server_cert_validation=ignore
  ```
- Test Connection:
  ```
  ansible domaincontroler -m win_ping
  ansible nodes -m win_ping
  ansible all -m win_ping
  ```
  
## Create and Run Playbooks:
- Create [create-ad.yml](create-ad.yml)
- Create [join-ad.yml](join-ad.yml)
- Run
  ```
  ansible-playbook create-ad.yml
  ```
- Restart Nodes
  ```
  az vm restart -g ANSIBLE -n VM1
  az vm restart -g ANSIBLE -n VM2
  ```
- Run
  ```
  ansible-playbook join-ad.yml
  ```
