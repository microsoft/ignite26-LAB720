#requires -Version 5.1
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Test-LabGitHubCli {
    if (-not (Get-Command gh -ErrorAction SilentlyContinue)) { return $false }
    $output = @(& gh --version)
    if ($LASTEXITCODE -ne 0 -or $output.Count -eq 0 -or $output[0] -notmatch '^gh version (\d+\.\d+\.\d+)\b') {
        throw 'Unable to determine the GitHub CLI version. Repair gh or check which executable is on PATH.'
    }
    $version = [version]$Matches[1]
    Write-Host "GitHub CLI version: $version"
    return $version -ge [version]'2.45.0'
}

function Test-LabCopilotChat {
    # --list-extensions omits built-ins. --locate-extension finds either kind.
    $paths = @(& code --locate-extension github.copilot-chat --locate-extension GitHub.copilot-chat)
    if ($LASTEXITCODE -ne 0) { throw 'VS Code could not locate its installed extensions.' }
    foreach ($path in $paths) {
        if (-not [IO.Path]::IsPathRooted($path)) { continue }
        $file = Join-Path $path 'package.json'
        if (Test-Path -LiteralPath $file -PathType Leaf) {
            $manifest = Get-Content -LiteralPath $file -Raw | ConvertFrom-Json
            if ($manifest.publisher -eq 'GitHub' -and $manifest.name -eq 'copilot-chat') {
                Write-Host "VS Code Copilot Chat version: $($manifest.version)"
                return $true
            }
        }
    }
    return $false
}

Export-ModuleMember -Function Test-LabGitHubCli, Test-LabCopilotChat
