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
  168.63.252.169

  [domaincontroler:vars]
  ansible_user=vmadmin
  ansible_password=abcABC123!@#
  ansible_connection=winrm
  ansible_winrm_server_cert_validation=ignore

  [nodes]
  104.215.253.36
  104.215.153.53

  [nodes:vars]
  ansible_user=vmadmin
  ansible_password=abcABC123!@#
  ansible_connection=winrm
  ansible_winrm_server_cert_validation=ignore
  ```
