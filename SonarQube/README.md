- [Code Quality and Security | SonarQube](https://www.sonarqube.org/)
- [Install](https://docs.sonarqube.org/latest/setup/get-started-2-minutes/)
- [Install the Server](https://docs.sonarqube.org/latest/setup/install-server/)
- [SonarScanner for MSBuild](https://docs.sonarqube.org/latest/analysis/scan/sonarscanner-for-msbuild/)

## Install OpenJDK [(Link)](https://adoptium.net/en-GB/temurin/releases/?version=21)
![alt text](imgs/download-openjdk.png)

## Install SonarQube [(Link)](https://www.sonarsource.com/products/sonarqube/downloads/)
![alt text](imgs/download-sonarqube.png)
## SonarQube 2025
![alt text](imgs/install-sonarqube.png)
```
cd sonarqube-25.8.0.112029\bin\windows-x86-64
SonarService.bat install
```
##
![alt text](imgs/install-sonarqube2.png)
##
![alt text](imgs/configure-sonarqube.png)
##

## Configure MS SQL Server DB
![alt text](imgs/download-jdbc.png)
##
![alt text](imgs/copy-jdbc.png)
##
![alt text](imgs/copy-jdbc2.png)
##
![alt text](imgs/configure-mssqlserver.png)
##
![alt text](imgs/configure-mssqlserver2.png)
##

## Configre Sonar Scanner MSBuild
![alt text](imgs/download-sonar-scanner-msbuild.png)
##
![alt text](imgs/download-sonar-scanner-msbuild1.png)
##
![alt text](imgs/configure-sonar-scanner-msbuild.png)
##

```ps
"C:\sonar-scanner-msbuild-4.7.1.2311-net46\SonarScanner.MSBuild.exe" begin /k:"Project-Key" /v:"%build.number%"
"C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\MSBuild\15.0\Bin\MSBuild.exe" "%teamcity.build.checkoutDir%\SolutionName.sln" /t:Rebuild /v:m
"C:\sonar-scanner-msbuild-4.7.1.2311-net46\SonarScanner.MSBuild.exe" end
```
