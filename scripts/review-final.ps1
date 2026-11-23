#requires -Version 5.1
[CmdletBinding()]
param(
    [string]$Destination = (Join-Path $HOME 'lab720-final-review'),
    [string]$FinalArchive,
    [switch]$TestGateway
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'LabContent.psm1')

$target = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Destination)
if (Test-Path -LiteralPath $target) {
    throw "Review destination already exists: $target. Use the existing checkpoint or choose a new -Destination."
}
$parent = [IO.Directory]::GetParent($target).FullName
$staging = Join-Path $parent ".lab720-review-$([guid]::NewGuid().ToString('N'))"
$checkpoint = Join-Path $staging 'checkpoint'
[IO.Directory]::CreateDirectory($staging) | Out-Null
try {
    Expand-FinalSnapshot -Destination $checkpoint -StagingDirectory $staging -FinalArchive $FinalArchive
    if ($TestGateway) {
        Import-Module (Join-Path $PSScriptRoot 'LabFinalGateway.psm1')
        Invoke-FinalGatewayTest -Snapshot (Join-Path $checkpoint 'dotnet')
    }
    [IO.Directory]::Move($checkpoint, $target)
}
finally {
    Remove-Item -LiteralPath $staging -Recurse -Force
}

Write-Host "LAB720 final checkpoint: $(Join-Path $target 'dotnet')"
Write-Host 'Next: follow instructions/review-final.md in your clone. No starting modules were installed and no modernization ran.'
