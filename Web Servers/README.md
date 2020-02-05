## What’s New in IIS
- [What’s New in IIS 10.0](https://docs.microsoft.com/en-us/iis/get-started/whats-new-in-iis-10/new-features-introduced-in-iis-10)
- [What's New in IIS 8.5](https://docs.microsoft.com/en-us/iis/get-started/whats-new-in-iis-85/enhanced-logging-for-iis85)
- [What's New in IIS 8](https://docs.microsoft.com/en-us/iis/get-started/whats-new-in-iis-8/installing-iis-8-on-windows-server-2012)
- [What's New in IIS 7](https://docs.microsoft.com/en-us/iis/get-started/whats-new-in-iis-7/changes-in-security-between-iis-60-and-iis-7-and-above)

## URL Rewrite Rules:
### [Install URL Rewrite](https://www.iis.net/downloads/microsoft/url-rewrite)
### Overwrite Server Response Header:
```xml
<system.webServer>
    <rewrite>
      <outboundRules>
        <rule name="Overwrite RESPONSE_Server">
          <match serverVariable="RESPONSE_Server" pattern=".+"/>
          <action type="Rewrite" value="My Web Server"/>
        </rule>
      </outboundRules>
    </rewrite>
</system.webServer>
```

## Remove Unwanted HTTP Response Headers:
- X-Powered-By
- X-AspNet-Version
```xml
<system.web>
  <httpRuntime enableVersionHeader="false" />
</system.web>
<system.webServer>
  <httpProtocol>
    <customHeaders>
      <remove name="X-Powered-By"/>
    </customHeaders>
  </httpProtocol>
</system.webServer>
```

## Add Security HTTP Response Headers:

Web UI:
```xml
<system.webServer>
  <httpProtocol>
    <customHeaders>
      <add name="X-Content-Type-Options" value="nosniff" />        
      <add name="X-Frame-Options" value="DENY" />
      <add name="X-XSS-Protection" value="1; mode=block" />
    </customHeaders>
  </httpProtocol>
</system.webServer>
```

Web API:
```xml
<system.webServer>
  <httpProtocol>
    <customHeaders>
      <add name="Cache-Control" value="no-cache, no-store, must-revalidate" />
      <add name="Pragma" value="no-cache" />
      <add name="Expires" value="0" />
    </customHeaders>
  </httpProtocol>
</system.webServer>
```

## Redirect HTTP to HTTPS
```xml
<system.webServer>
  <rewrite>
    <rules>
        <rule name="HTTP to HTTPS redirect" enabled="false" stopProcessing="true">
          <match url="(.*)"/>
          <conditions>
            <add input="{HTTPS}" pattern="off" ignoreCase="true"/>
          </conditions>
          <action type="Redirect" url="https://{HTTP_HOST}/{R:1}" redirectType="Permanent"/>
        </rule>
    </rules>
  </rewrite>
</system.webServer>
```

## Add CORS
```xml
<system.webServer>
   <httpprotocol>
      <customheaders>
        <add name="Access-Control-Allow-Origin" value="domain" />
      </customheaders>
    </httpprotocol>
</system.webServer>
```

## Add Strict Transport Security
```xml
<system.webServer>
  <rewrite>
    <outboundRules>
      <rule name="Add Strict-Transport-Security when HTTPS" enabled="true">
        <match serverVariable="RESPONSE_Strict_Transport_Security"
          pattern=".*" />
        <conditions>
          <add input="{HTTPS}" pattern="on" ignoreCase="true" />
        </conditions>
        <action type="Rewrite" value="max-age=31536000" />
      </rule>
    </outboundRules>
  </rewrite>
</system.webServer>
```

## React Routes
```xml
<system.webServer>
  <rewrite>
    <rules>
      <rule name="React Routes" stopProcessing="true">
        <match url=".*" />
        <conditions logicalGrouping="MatchAll">
          <add input="{REQUEST_FILENAME}" matchType="IsFile" negate="true" />
          <add input="{REQUEST_FILENAME}" matchType="IsDirectory" negate="true" />
          <add input="{REQUEST_URI}" pattern="^/(api)" negate="true" />
        </conditions>
        <action type="Rewrite" url="/" />
      </rule>
    </rules>
  </rewrite>
</system.webServer>
```
