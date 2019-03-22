param (
    [string]$ProjectPath = ""
)


function ClearWorkItems()
{
	Remove-Item .\.sonarqube -Recurse -Force
	Remove-Item .\VisualStudio.coveragexml
	Remove-Item .\VisualStudio.coverage
	Remove-Item .\TestResults\ -Recurse -Force
}

$currentdir = Get-Location
$currentdir = $currentdir.path

& "C:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\Tools\VsDevCmd.bat"
$ProjectPath += "\"
set-location $ProjectPath
ClearWorkItems

$solution=Get-ChildItem *.sln | select name
$solution=$solution.Name
$ProjectName=$($solution.Split('.')[1])
$ProjectName=$($solution.Split('.')[1])
if ($projectname -eq "sln")
{
	$ProjectName=$($solution.Split('.')[0])
}

write-host $projectname
& C:\sonar-runner-msbuild-1.0\MSBuild.SonarQube.Runner.exe /k:"Atlas:$ProjectName" /n:"$ProjectName" /v:"Main" /d:sonar.cs.vscoveragexml.reportsPaths="$($ProjectPath)\VisualStudio.coveragexml" /d:sonar.cs.vstest.reportsPaths="$($ProjectPath)\TestResults\*.trx"

& "C:\Program Files (x86)\MSBuild\12.0\Bin\MSBuild.exe"


$dllParam = ''

Get-ChildItem -s | where { $_.name -like '*.tests.dll' } | where {$_.fullname.contains('obj') -eq $false } | select fullname | foreach-object { $dllParam+="""$($_.fullname)"" "}

& "C:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\IDE\CommonExtensions\Microsoft\TestWindow\vstest.console.exe"  /Logger:trx /inisolation /enablecodecoverage $dllParam

$reportName = Get-ChildItem -s | where { $_.name -like '*coverage' } | where {$_.fullname.contains('obj') -eq $false } | select fullname 
$reportName = $reportName.FullName
copy-item $reportName "$($ProjectPath)\VisualStudio.coverage" -force
& "C:\Program Files (x86)\Microsoft Visual Studio 12.0\Team Tools\Dynamic Code Coverage Tools\CodeCoverage.exe" analyze /output:"$($ProjectPath)\VisualStudio.coveragexml" "$($ProjectPath)\VisualStudio.coverage"
& C:\sonar-runner-msbuild-1.0\MSBuild.SonarQube.Runner.exe  end
#ClearWorkItems


set-location $currentdir 