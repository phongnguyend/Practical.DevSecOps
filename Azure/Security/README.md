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

<details>
  <summary><b>Control authentication for your APIs with Azure API Management</b></summary>
  
  ```
git clone https://github.com/MicrosoftDocs/mslearn-control-authentication-with-apim.git
cd mslearn-control-authentication-with-apim
bash setup.sh

curl -X GET https://apim-WeatherData1597.azure-api.net/api/Weather/53/-1

curl -X GET https://apim-WeatherData1597.azure-api.net/api/Weather/53/-1 \
  -H 'Ocp-Apim-Subscription-Key: ecd27f3078e44d85a51ef9252712b232'


pwd='Pa$$w0rd'
pfxFilePath='selfsigncert.pfx'
openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -keyout privateKey.key -out selfsigncert.crt -subj /CN=localhost

openssl pkcs12 -export -out $pfxFilePath -inkey privateKey.key -in selfsigncert.crt -password pass:$pwd
openssl pkcs12 -in selfsigncert.pfx -out selfsigncert.pem -nodes

Fingerprint="$(openssl x509 -in selfsigncert.pem -noout -fingerprint)"
Fingerprint="${Fingerprint//:}"
echo ${Fingerprint#*=}

curl -X GET https://apim-WeatherData1597.azure-api.net/api/Weather/53/-1 \
  -H 'Ocp-Apim-Subscription-Key: ecd27f3078e44d85a51ef9252712b232' \
  --cert-type pem \
  --cert selfsigncert.pem
  ```
</details>

