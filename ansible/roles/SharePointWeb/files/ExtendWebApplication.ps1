Param([string]$webApplicationUrl,
    [string]$webApplicationExtensionName,
    [string]$zone,
    [string]$webApplicationExtensionUrl,
    [string]$hostHeader
)
Add-PSSnapin Microsoft.SharePoint.PowerShell -EA 0
Import-Module WebAdministration
Get-SPWebApplication -Identity $webApplicationUrl | New-SPWebApplicationExtension -name $webApplicationExtensionName -Zone $zone -URL $webApplicationExtensionUrl -Port "80" -HostHeader $hostHeader