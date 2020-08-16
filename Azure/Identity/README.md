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
