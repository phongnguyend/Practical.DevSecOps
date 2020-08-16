### Learning Paths:
- [AZ-104: Manage identities and governance in Azure](https://docs.microsoft.com/en-us/learn/paths/az-104-manage-identities-governance/)
- [AZ-500: Manage identity and access in Azure Active Directory](https://docs.microsoft.com/en-us/learn/paths/manage-identity-and-access/)

### Tools:


### Common Scripts:

- Create an User & its own Resource Group
```
az ad user create --display-name "<Display Name>" \
                  --password "<Password>" \
                  --user-principal-name "<Name>@<Domain>" \
                  --force-change-password-next-login false
                  
az group create --name "<Group Name>" --location "southeastasia"

az role assignment create --role Owner \
                          --assignee "<Name>@<Domain>" \
                          --subscription "<Subscription>" \
                          --resource-group "<Group Name>"

az group delete -y --name "<Group Name>"

az ad user delete --upn-or-object-id "<Name>@<Domain>"
```
