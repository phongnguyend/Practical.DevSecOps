- List available Linux distributions
  ```ps1
  wsl --list --online
  ```
- Install
  ```ps1
  wsl --install -d <Distribution Name>
  ```
- List installed instances
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

- Login into an instance
  ```ps1
  wsl --distribution Ubuntu
  wsl --distribution Ubuntu --user phongnguyend
  ```

- Upgrade WSL Version
  ```
  wsl --version
  wsl --update
  ```
- Download and Install/Upgrade directly from GitHub releases: https://github.com/microsoft/WSL/releases
