### Updating List of Trusted Root Certificates in Windows ([reference](https://woshub.com/updating-trusted-root-certificates-in-windows-10/))
```
certutil.exe -generateSSTFromWU c:\roots.sst
```

### Check PATH Variable
- CMD
```
echo %PATH%
```
- PowerShell
```ps1
$env:PATH
```
```ps1
$env:Path -split ';'
```

### Check Last Restarted Time
Open CMD or PowerShell
```ps1
systeminfo
```
