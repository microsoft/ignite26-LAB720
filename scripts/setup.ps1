#requires -Version 5.1
[CmdletBinding()]
param(
    [ValidateNotNullOrEmpty()]
    [string]$LabArchive,

    [string]$FinalArchive,

    [string]$LabRoot = 'C:\lab\caldova',

    [switch]$SkipToolInstallation
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ($PSVersionTable.PSEdition -eq 'Core' -and -not $IsWindows) {
    throw 'The automated setup currently supports Windows 11 only. Follow the official tool installation instructions to set up a different platform manually.'
}

Import-Module (Join-Path $PSScriptRoot 'LabContent.psm1')

function Test-Command {
    param([Parameter(Mandatory = $true)][string]$Name)
    return $null -ne (Get-Command $Name -ErrorAction SilentlyContinue)
}

function Sync-SessionPath {
    $entries = @(
        [Environment]::GetEnvironmentVariable('Path', 'Machine'),
        [Environment]::GetEnvironmentVariable('Path', 'User'),
        $env:Path
    ) -join [IO.Path]::PathSeparator -split [IO.Path]::PathSeparator |
        Where-Object { $_ } |
        Select-Object -Unique
    $env:Path = $entries -join [IO.Path]::PathSeparator
}

function Initialize-LabWinGet {
    if (Test-Command 'winget') { return }
    Write-Host 'WinGet is missing. Preparing App Installer for the current user...'
    & powershell.exe -NoProfile -NonInteractive -ExecutionPolicy RemoteSigned -File (Join-Path $PSScriptRoot 'install-winget.ps1')
    if ($LASTEXITCODE -ne 0) {
        throw 'Could not bootstrap WinGet. See the error above. Install App Installer from the Microsoft Store or contact your administrator, then rerun setup.'
    }
    Sync-SessionPath
    if (-not (Test-Command 'winget')) {
        throw 'WinGet is still not on PATH. Check the App Installer app execution alias and open a new terminal.'
    }
}

function Invoke-WinGetInstall {
    param([Parameter(Mandatory = $true)][string]$Id)

    # winget reports these when the package is already present but not yet on this session's PATH.
    $alreadyInstalledCodes = @(
        -1978335135, # 0x8A150061 APPINSTALLER_CLI_ERROR_PACKAGE_ALREADY_INSTALLED
        -1978334963, # 0x8A15010D APPINSTALLER_CLI_ERROR_INSTALL_ALREADY_INSTALLED
        -1978335189  # 0x8A15002B APPINSTALLER_CLI_ERROR_UPDATE_NOT_APPLICABLE
    )

    Write-Host "Installing $Id..."
    & winget install --id $Id --exact --source winget --silent --disable-interactivity --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -ne 0 -and $alreadyInstalledCodes -notcontains $LASTEXITCODE) {
        throw "winget failed to install $Id (exit code $LASTEXITCODE)."
    }
}

function Install-WinGetPackage {
    param(
        [Parameter(Mandatory = $true)][string]$Id,
        [Parameter(Mandatory = $true)][string]$Command
    )

    if (Test-Command $Command) {
        Write-Host "$Command is already installed."
        return
    }

    Invoke-WinGetInstall -Id $Id
}

function Install-ModernizeCli {
    $installerPath = Join-Path ([IO.Path]::GetTempPath()) "modernize-install-$([guid]::NewGuid()).ps1"
    try {
        Write-Host 'Downloading the official Modernize CLI installer...'
        Invoke-WebRequest `
            -Uri 'https://raw.githubusercontent.com/microsoft/modernize-cli/main/scripts/install.ps1' `
            -OutFile $installerPath
        # The installer calls exit on failure, so run it in a child process and check its exit code.
        & ([Environment]::ProcessPath) -NoProfile -NonInteractive -ExecutionPolicy Bypass -File $installerPath
        if ($LASTEXITCODE -ne 0) {
            throw "The Modernize CLI installer failed (exit code $LASTEXITCODE)."
        }
    }
    finally {
        if (Test-Path -LiteralPath $installerPath) {
            Remove-Item -LiteralPath $installerPath -Force
        }
    }
}

if ($LabArchive) {
    $archivePath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($LabArchive)
    if (-not (Test-Path -LiteralPath $archivePath -PathType Leaf)) {
        throw "Lab archive not found: $archivePath. Obtain an authorized Caldova modernization archive before running setup."
    }
    if ([IO.Path]::GetExtension($archivePath) -ine '.zip') {
        throw 'LabArchive must be a .zip file.'
    }
}
else {
    $rehearsalUri = Get-RehearsalDownloadUri
}
Sync-SessionPath

$destination = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($LabRoot)
if (Test-Path -LiteralPath $destination) {
    throw "LabRoot already exists: $destination. Setup will not overwrite a learner workspace; choose a new path or move the existing folder yourself."
}

# Stage beside the destination so the final move stays on one volume and extracted paths stay short.
$destinationParent = [IO.Path]::GetDirectoryName($destination)
[IO.Directory]::CreateDirectory($destinationParent) | Out-Null
$stagingDirectory = Join-Path $destinationParent ".lab720-staging-$([guid]::NewGuid().ToString('N').Substring(0, 8))"
try {
    [IO.Directory]::CreateDirectory($stagingDirectory) | Out-Null
    if (-not $LabArchive) {
        $archivePath = Join-Path $stagingDirectory 'caldova-rehearsal.zip'
        Write-Host 'Downloading the LAB720 starting archive from the configured source...'
        Invoke-WebRequest -UseBasicParsing -Uri $rehearsalUri -OutFile $archivePath
    }
    if ($PSVersionTable.PSVersion.Major -lt 7) {
        if (-not (Test-Command 'pwsh.exe')) {
            if ($SkipToolInstallation) {
                throw 'PowerShell 7 (pwsh.exe) is required when using -SkipToolInstallation.'
            }
            # Reject the wrong input before installing anything on the learner's machine.
            Assert-LabArchives -LabArchive $archivePath -FinalArchive $FinalArchive
            Initialize-LabWinGet
            Invoke-WinGetInstall -Id 'Microsoft.PowerShell'
            Sync-SessionPath
            if (-not (Test-Command 'pwsh.exe')) {
                throw 'PowerShell 7 was installed but pwsh.exe is not on PATH. Open a new terminal and rerun setup.'
            }
        }

        $arguments = @('-NoProfile', '-ExecutionPolicy', 'RemoteSigned', '-File', $PSCommandPath,
            '-LabArchive', $archivePath, '-LabRoot', $destination)
        if ($FinalArchive) {
            $arguments += @('-FinalArchive', $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($FinalArchive))
        }
        if ($SkipToolInstallation) { $arguments += '-SkipToolInstallation' }
        & pwsh.exe @arguments
        if ($LASTEXITCODE -ne 0) { throw "PowerShell 7 setup failed (exit code $LASTEXITCODE). See the error above." }
        return
    }
    $payloadRoot = Expand-LabContent -LabArchive $archivePath -FinalArchive $FinalArchive -StagingDirectory $stagingDirectory

    $configSource = Join-Path $PSScriptRoot '..\infra\modernize-config.json'
    if (-not (Test-Path -LiteralPath $configSource -PathType Leaf)) {
        throw "Modernize configuration is missing from this repository: $configSource"
    }
    $rootReadmeSource = Join-Path $PSScriptRoot '..\infra\lab-root-README.md'
    if (-not (Test-Path -LiteralPath $rootReadmeSource -PathType Leaf)) {
        throw "The participant README is missing from this repository: $rootReadmeSource"
    }

    if (-not $SkipToolInstallation) {
        Import-Module (Join-Path $PSScriptRoot 'LabTools.psm1')
        Initialize-LabWinGet
        Install-WinGetPackage -Id 'Git.Git' -Command 'git'
        if (-not (Test-LabGitHubCli)) {
            Invoke-WinGetInstall -Id 'GitHub.cli'
            Sync-SessionPath
            if (-not (Test-LabGitHubCli)) {
                throw 'GitHub CLI 2.45.0 or later is required. Check for an older gh executable on PATH before rerunning setup.'
            }
        }
        Install-WinGetPackage -Id 'Microsoft.VisualStudioCode' -Command 'code'

        $hasDotNet10 = $false
        if (Test-Command 'dotnet') {
            $hasDotNet10 = @(& dotnet --list-sdks | Where-Object { $_ -match '^10\.' }).Count -gt 0
        }
        if (-not $hasDotNet10) {
            Invoke-WinGetInstall -Id 'Microsoft.DotNet.SDK.10'
        }

        Sync-SessionPath
        foreach ($command in @('git', 'gh', 'code')) {
            if (-not (Test-Command $command)) {
                throw "'$command' was installed but is not on PATH. Open a new PowerShell 7 terminal and rerun setup."
            }
        }
        if (-not (Test-Command 'dotnet') -or
            @(& dotnet --list-sdks | Where-Object { $_ -match '^10\.' }).Count -eq 0) {
            throw 'The .NET 10 SDK installation was not detected. Open a new terminal or install the SDK manually.'
        }

        Install-ModernizeCli
        Sync-SessionPath
        if (-not (Test-Command 'modernize')) {
            throw 'The Modernize CLI installation was not detected. Open a new terminal or install it manually from the official quickstart.'
        }

        if (-not (Test-LabCopilotChat)) {
            Write-Host 'Installing the GitHub Copilot Chat extension for VS Code...'
            & code --install-extension GitHub.copilot-chat
            if ($LASTEXITCODE -ne 0 -or -not (Test-LabCopilotChat)) {
                throw 'GitHub Copilot Chat was not installed. Update VS Code and retry setup.'
            }
        }
    }

    if (-not (Test-Command 'git')) {
        throw 'Git is required to select the prepared LAB720 branches. Install Git before using -SkipToolInstallation.'
    }
    Initialize-LabContent -Root $payloadRoot

    $archiveReadme = Join-Path $payloadRoot 'README.md'
    $originalReadme = Join-Path $payloadRoot 'README-ORIGINAL.md'
    if ((Test-Path -LiteralPath $archiveReadme -PathType Leaf) -and
        (Test-Path -LiteralPath $originalReadme)) {
        throw 'The archive already contains README-ORIGINAL.md; refusing to overwrite it.'
    }
    if (Test-Path -LiteralPath $archiveReadme -PathType Leaf) {
        Move-Item -LiteralPath $archiveReadme -Destination $originalReadme
    }
    Copy-Item -LiteralPath $rootReadmeSource -Destination (Join-Path $payloadRoot 'README.md')

    $launchDirectories = @(
        'modules\module-02-plan\start',
        'modules\module-03-execute\start',
        'modules\module-02-plan\start\apps\CaldovaAuthGateway',
        'modules\module-03-execute\start\apps\CaldovaAuthGateway'
    )
    foreach ($relativeDirectory in $launchDirectories) {
        $launchPath = Join-Path $payloadRoot $relativeDirectory
        $modernizeDirectory = Join-Path $launchPath '.github\modernize'
        [IO.Directory]::CreateDirectory($modernizeDirectory) | Out-Null
        Copy-Item -LiteralPath $configSource -Destination (Join-Path $modernizeDirectory 'config.json') -Force
    }

    if (Test-Path -LiteralPath $destination) {
        throw "LabRoot appeared during setup: $destination. Refusing to overwrite or nest the workspace."
    }
    $resolvedPayloadRoot = (Resolve-Path -LiteralPath $payloadRoot).Path
    [IO.Directory]::Move($resolvedPayloadRoot, $destination)

    Write-Host "Lab content installed at: $destination"
    Write-Host 'Next: open a new PowerShell 7 terminal, sign in to GitHub in gh and VS Code, then run scripts/verify.ps1.'
}
finally {
    if (Test-Path -LiteralPath $stagingDirectory) {
        Remove-Item -LiteralPath $stagingDirectory -Recurse -Force
    }
}
