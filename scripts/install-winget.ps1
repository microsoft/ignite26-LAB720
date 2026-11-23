#requires -Version 5.1
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

# The supported repair handles missing packages, first-login registration and PATH.
# Run this in Windows PowerShell so the inbox Appx module is available.
if (-not (Get-Module -ListAvailable -Name Microsoft.WinGet.Client)) {
    if ((Get-PSRepository -Name PSGallery).SourceLocation.TrimEnd('/') -ne 'https://www.powershellgallery.com/api/v2') {
        throw 'PSGallery does not point to the official PowerShell Gallery. Install App Installer manually.'
    }
    if (-not (Get-PackageProvider -ListAvailable | Where-Object { $_.Name -eq 'NuGet' -and $_.Version -ge [version]'2.8.5.201' })) {
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Scope CurrentUser -Force | Out-Null
    }
    Install-Module -Name Microsoft.WinGet.Client -Repository PSGallery -Scope CurrentUser -Force
}
# A staged Windows image package may not have a matching GitHub release tag.
# Ask for a published stable release instead of deriving the tag from that package.
Microsoft.WinGet.Client\Repair-WinGetPackageManager -Latest -ErrorAction Stop
