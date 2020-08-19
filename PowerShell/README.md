Generate Strong Password:
```
Add-Type -AssemblyName System.Web

[System.Web.Security.Membership]::GeneratePassword(20, 2) | Set-Clipboard
```
