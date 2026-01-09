### PowerShell
- [Install PowerShell on Windows, Linux, and macOS](https://learn.microsoft.com/en-us/powershell/scripting/install/install-powershell)
- [What's New in PowerShell](https://learn.microsoft.com/en-us/powershell/scripting/whats-new/overview)

### Generate Strong Password:
```ps1
Add-Type -AssemblyName System.Web

[System.Web.Security.Membership]::GeneratePassword(20, 2) | Set-Clipboard
```

### Generate 256 Bit Key:
```ps1
$CreateKey = New-Object Byte[] 32
[Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($CreateKey)
[System.Convert]::ToBase64String($CreateKey) | Set-Clipboard
```

### Generate Guid:
```ps1
New-Guid | Set-Clipboard
```

### Disable SSL 2, SSL 3, TLS 1, TLS 1.0, TLS 1.1 Windows Sever [(refer)](https://www.petenetlive.com/KB/Article/0001675)
```ps1
New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Server' -Force | Out-Null 
New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Server' -name 'Enabled' -value '0' -PropertyType 'DWord' -Force | Out-Null 
New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Server' -name 'DisabledByDefault' -value 1 -PropertyType 'DWord' -Force | Out-Null 
New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Client' -Force | Out-Null 
New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Client' -name 'Enabled' -value '0' -PropertyType 'DWord' -Force | Out-Null 
New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Client' -name 'DisabledByDefault' -value 1 -PropertyType 'DWord' -Force | Out-Null

New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Server' -Force | Out-Null
New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Server' -name 'Enabled' -value '0' -PropertyType 'DWord' -Force | Out-Null 
New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Server' -name 'DisabledByDefault' -value 1 -PropertyType 'DWord' -Force | Out-Null 
New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Client' -Force | Out-Null 
New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Client' -name 'Enabled' -value '0' -PropertyType 'DWord' -Force | Out-Null 
New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Client' -name 'DisabledByDefault' -value 1 -PropertyType 'DWord' -Force | Out-Null

New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server' -Force | Out-Null 
New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server' -name 'Enabled' -value '0' -PropertyType 'DWord' -Force | Out-Null 
New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server' -name 'DisabledByDefault' -value 1 -PropertyType 'DWord' -Force | Out-Null 
New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client' -Force | Out-Null 
New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client' -name 'Enabled' -value '0' -PropertyType 'DWord' -Force | Out-Null 
New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client' -name 'DisabledByDefault' -value 1 -PropertyType 'DWord' -Force | Out-Null

New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server' -Force | Out-Null 
New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server' -name 'Enabled' -value '0' -PropertyType 'DWord' -Force | Out-Null 
New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server' -name 'DisabledByDefault' -value 1 -PropertyType 'DWord' -Force | Out-Null 
New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client' -Force | Out-Null 
New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client' -name 'Enabled' -value '0' -PropertyType 'DWord' -Force | Out-Null 
New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client' -name 'DisabledByDefault' -value 1 -PropertyType 'DWord' -Force | Out-Null
```

### Create Event Log
```ps1
New-EventLog -LogName "Application" -Source "Application Name"
New-EventLog -LogName "CustomLogName" -Source "Application Name"
Remove-EventLog -LogName "CustomLogName"
```

### Install & Create Windows Failover Cluster
```ps1
Install-WindowsFeature -Name Failover-Clustering –IncludeManagementTools
Test-Cluster -Node Node1, Node2
New-Cluster -Name MyCluster -Node Node1, Node2
Get-Cluster
```

### Delete Files Older Than ... Days
```ps1
# https://stackoverflow.com/questions/17829785/delete-files-older-than-15-days-using-powershell

$limit = (Get-Date).AddDays(-180)
$path = "E:\Temp\"
# $path = $env:TEMP

# delete files
Get-ChildItem -Path $path -Recurse -File | Where CreationTime -lt $limit | Remove-Item -Force -Verbose

# delete empty folders
Get-ChildItem -Path $path -Recurse -Force | Where CreationTime -lt $limit | Where-Object { $_.PSIsContainer -and (Get-ChildItem -Path $_.FullName -Recurse -Force | Where-Object { !$_.PSIsContainer }) -eq $null } | Remove-Item -Force -Recurse -Verbose


```

### Delete Folders Recursively
```ps1
# delete dotnet bin and obj folders recursively
Get-ChildItem .\ -include bin,obj -Recurse | foreach ($_) { remove-item $_.fullname -Force -Recurse }
```

### Install/Enable Telnet Client on Windows:
```ps1
Install-WindowsFeature -Name Telnet-Client
```
```ps1
Enable-WindowsOptionalFeature -Online -FeatureName "TelnetClient"
```

### Install SFTP Server (OpenSSH) on Windows:
```ps1
# https://github.com/PowerShell/Win32-OpenSSH/wiki/Install-Win32-OpenSSH-Using-MSI
Invoke-WebRequest https://github.com/PowerShell/Win32-OpenSSH/releases/download/v8.9.1.0p1-Beta/OpenSSH-x64-v8.9.1.0.msi -OutFile C:\OpenSSH-x64-v8.9.1.0.msi
```
```ps1
[Environment]::SetEnvironmentVariable("Path", $env:Path + ';' + ${Env:ProgramFiles} + '\OpenSSH', [System.EnvironmentVariableTarget]::Machine)
Get-Service -Name ssh*
```

### Find Which Process Listening on Specific Port:
```ps1
# TCP
Get-Process -Id (Get-NetTCPConnection -LocalPort Port).OwningProcess

# UDP
Get-Process -Id (Get-NetUDPEndpoint -LocalPort Port).OwningProcess

# Using CMD
netstat -a -n -o | find "Port"
```

### Setup File Watcher
```ps1
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.IncludeSubdirectories = $true
$watcher.Path = 'D:\FolderWhereStuffChanges'
$watcher.EnableRaisingEvents = $true
$action =
{
    $path = $event.SourceEventArgs.FullPath
    $changetype = $event.SourceEventArgs.ChangeType
    Write-Host "$path was $changetype at $(get-date)"
	Out-File -FilePath D:\outlog.txt -Append -InputObject "$path was $changetype at $(get-date)"
}
Register-ObjectEvent $watcher 'Created' -Action $action
Register-ObjectEvent $watcher 'Deleted' -Action $action

```
- Unregister Events
```ps1
Get-EventSubscriber
Get-EventSubscriber | Unregister-Event
```

### Test a Connection To a Remote Host
```ps1
Test-NetConnection 16.12.10.46 -Port 443 -InformationLevel Detailed
telnet 16.12.10.46 443
```

### Invoke Http Request
```ps1
Invoke-WebRequest -Uri https://github.com -UseBasicParsing
```
```ps1
Invoke-WebRequest -Uri https://github.com -Headers @{"key1"="value1";"key2"="value2"}
```

###

### Map Network Path
```ps1
# use New-SmbMapping
$destination1 = "\\server\folder"
$user = ".\username"
$pwd = "password"
New-SmbMapping -RemotePath $destination1 -Username $user -Password $pwd

# use net use
$destination1 = "\\server\folder"
$user = "server\username"
$pwd = "password"
net use $destination1 /user:$user $pwd

# remove mapped
net use * /d /y
```

### Replace Text in File
```ps1
$path = "C:\text.txt"
(Get-Content $path) -Replace 'ABC', 'XYZ' | Set-Content $path
(Get-Content $path) -Replace '123', '456' | Set-Content $path
```
