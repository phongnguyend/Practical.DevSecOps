### Learning Paths:
- [Microsoft Certified: Azure Security Engineer Associate](https://docs.microsoft.com/en-us/learn/certifications/azure-security-engineer#two-ways-to-prepare)

### Tools:

### Scripts:
<details>
  <summary><b>Manage secrets in your server apps with Azure Key Vault</b></summary>
  
  ```
keyVaultName=keyvault1597

az keyvault create \
    --resource-group learn-70c0fc1e-c0df-456b-8ad3-ffc0ed5a0f44 \
    --location centralus \
    --name $keyVaultName
	
az keyvault secret set \
    --name SecretPassword \
    --value reindeer_flotilla \
    --vault-name $keyVaultName
	
az appservice plan create \
    --name keyvault-exercise-plan \
    --sku FREE \
    --location centralus \
    --resource-group learn-70c0fc1e-c0df-456b-8ad3-ffc0ed5a0f44
	
az webapp create \
    --plan keyvault-exercise-plan \
    --resource-group learn-70c0fc1e-c0df-456b-8ad3-ffc0ed5a0f44 \
    --name keyvault-exercise-webapp
	
az webapp config appsettings set \
    --resource-group learn-70c0fc1e-c0df-456b-8ad3-ffc0ed5a0f44 \
    --name keyvault-exercise-webapp \
    --settings VaultName=$keyVaultName
	
az webapp identity assign \
    --resource-group learn-70c0fc1e-c0df-456b-8ad3-ffc0ed5a0f44 \
    --name keyvault-exercise-webapp

principalId=$(az webapp identity show \
    --resource-group learn-70c0fc1e-c0df-456b-8ad3-ffc0ed5a0f44 \
    --name keyvault-exercise-webapp \
	--query principalId \
	--out tsv)
	
az keyvault set-policy \
    --secret-permissions get list \
    --name $keyVaultName \
    --object-id $principalId
  ```
</details>
