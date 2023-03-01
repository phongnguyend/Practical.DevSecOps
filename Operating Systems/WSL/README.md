
- List Instances
  ```ps1
  wsl -l -v
  ```
- Installing WSL on another drive in Windows
  ```ps1
  wsl --shutdown Ubuntu-22.04
  wsl --export Ubuntu-22.04 "E:\WSL\Export\Ubuntu-22.04.tar"
  wsl --unregister Ubuntu-22.04
  wsl --import Ubuntu-22.04 "E:\WSL\Ubuntu-22.04" "E:\WSL\Export\Ubuntu-22.04.tar"
  ```
 
 - Set Default Version
   ```ps1
   wsl --set-default-version 2
   ```
 - Upgrade Version
   ```ps1
   wsl --set-version Ubuntu-22.04 2
   ```
- Configure wsl.conf and .wslconfig
  + [Advanced settings configuration in WSL | Microsoft Learn](https://learn.microsoft.com/en-us/windows/wsl/wsl-config)
