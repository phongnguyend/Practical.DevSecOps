## Install TeamCity
[Install TeamCity](InstallTeamCity.md)

## Setup Build Configuration .Net Core Project
[Setup Build Configuration .Net Core Project](BuildConfiguration.NetCore.md)

## Setup Build Configuration Angular Project
[Setup Build Configuration Angular Project](BuildConfigurationAngular.md)

## Powershell Templates:

### Count StyleCop Violations
```ps
$count = 0

$rootPath = "%teamcity.build.checkoutDir%\"

$files = @("File1", "File2")

foreach($file in $files){
	$fullName = $rootPath + $file + "\StyleCopViolations.xml";
	[XML]$violations = Get-Content $fullName
	foreach($violation in $violations.StyleCopViolations.Violation){
		$count++
	}
}

Write-Host "##teamcity[buildStatus text='{build.status.text}, StyleCop violations: $count']"
```
