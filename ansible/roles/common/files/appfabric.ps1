#-----------------------------------------------------------------------------
# Name:            Update-AppFabric.ps1 
# Description:      This script will patch and enable Garbage Collection in AppFabric
# Usage:         Run script, make sure that the AppFabric CU is in the same directory
#   as the script and that there are no other exes in the same directory.
# Must run script as Administrator if UAC is enabled on server
#   Do not rename the AppFabric Cumulative Update!
#-----------------------------------------------------------------------------
#Check if PS Console is running as "elevated"
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

$PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$appfabversion = (Get-ItemProperty "$env:programfiles\AppFabric 1.1 for Windows Server\PowershellModules\DistributedCacheConfiguration\Microsoft.ApplicationServer.Caching.Configuration.dll" -Name VersionInfo -EA 0).VersionInfo.ProductVersion 
if ($appfabversion -eq $null){
    Write-Host "No appfabric running on server. Exiting Script" -ForegroundColor Red;
    sleep -s 5
    exit
 }
 
 
 #install CU patch if not CU7
 if ($appfabversion -lt "1.0.4657.2"){
	Write-Host "Appfabric not patched with CU7. Patching..." -ForegroundColor Yellow;
	$patchfile = Get-ChildItem $PSScriptRoot | where {$_.Name.ToLower().StartsWith("appfabric") -and $_.Extension -eq ".exe"};
		if($patchfile -eq $null) { 
			$uri = "https://download.microsoft.com/download/F/1/0/F1093AF6-E797-4CA8-A9F6-FC50024B385C/AppFabric-KB3092423-x64-ENU.exe"
			$request = Invoke-WebRequest -Uri $uri -MaximumRedirection 1 -ErrorAction 0
			$location = $request.Headers.Location
			$output = $PSScriptRoot + $location.SubString($location.LastIndexOf('/') + 1)
			Invoke-WebRequest -Uri $location -OutFile $output
		}#end if $patchfile
		
    asnp *sharepoint* -ea 0
    Write-Host "Stopping AppFabric" -ForegroundColor Magenta;
    $afservice = get-service | where {$_.name -like "*appfabric*" }
    if ($afservice.status -eq 'Running'){ 
        Stop-SPDistributedCacheServiceInstance -Graceful
        Write-Host "Appfabric stopped" -ForegroundColor green;
        Write-Host "Patching now keep this PowerShell window open" -ForegroundColor Yellow
        Start-Process -FilePath $patchfile.FullName -ArgumentList "/passive" -Wait;
        Write-Host "Patch installation complete" -foregroundcolor green;
    }#end if $afservice
}#end if $appfabversion


 

#add AppFabric background garbage collection fix from CU3 if not set
[system.reflection.assembly]::LoadWithPartialName("System.Configuration") | Out-Null 
 
# intentionally leave off the trailing ".config" as OpenExeConfiguration will auto-append that 
$configFilePath = "$env:ProgramFiles\AppFabric 1.1 for Windows Server\DistributedCacheService.exe" 
$appFabricConfig = [System.Configuration.ConfigurationManager]::OpenExeConfiguration($configFilePath) 
# if backgroundGC setting does not exist add it, else check if value is "false" and change to "true" 
if($appFabricConfig.AppSettings.Settings.AllKeys -notcontains "backgroundGC") 
{ 
    $appFabricConfig.AppSettings.Settings.Add("backgroundGC", "true") 
} 
elseif ($appFabricConfig.AppSettings.Settings["backgroundGC"].Value -eq "false") 
{ 
    $appFabricConfig.AppSettings.Settings["backgroundGC"].Value = "true" 
} 
# save changes to config file 
$appFabricConfig.Save() 
$afservice = get-service | where {$_.name -like "*appfabric*" }
if ($afservice.status -eq 'Stopped'){ 
    Write-Host "Starting AppFabric" -ForegroundColor Yellow;
    $instance = Get-SPServiceInstance | ? {$_.TypeName -eq "Distributed Cache" -and $_.Server.Name -eq $env:computername};
    $instance.Provision();
    Write-Host "Started AppFabric" -ForegroundColor Green;
}

