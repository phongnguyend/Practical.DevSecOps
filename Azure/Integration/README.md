### Learning Paths:
- [AZ-204: Connect your services together](https://docs.microsoft.com/en-us/learn/paths/connect-your-services-together/)
- [AZ-303, AZ-304: Architect message brokering and serverless applications in Azure](https://docs.microsoft.com/en-us/learn/paths/architect-messaging-serverless/)
- [AZ-303, AZ-304: Architect API integration in Azure](https://docs.microsoft.com/en-us/learn/paths/architect-api-integration/)

### Tools:
- [curl](https://curl.haxx.se/)

### Useful Links:
- [cURL: Add Header, Multiple Headers, Authorization](https://www.shellhacks.com/curl-add-header-multiple-headers-authorization/)

### Scripts:
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

