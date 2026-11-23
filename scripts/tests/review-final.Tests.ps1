#requires -Version 5.1
[CmdletBinding()]
param([switch]$WithoutInstalledSdk)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$root = Join-Path ([IO.Path]::GetTempPath()) "lab720-final-smoke-$([guid]::NewGuid().ToString('N').Substring(0, 8))"
$destination = Join-Path $root 'review'
$final = Join-Path $destination 'dotnet'
$beforePath = $env:PATH
$beforeDotnetRoot = $env:DOTNET_ROOT
$beforeCertificate = $env:DOTNET_GENERATE_ASPNET_CERTIFICATE
$beforeGlobalTools = $env:DOTNET_ADD_GLOBAL_TOOLS_TO_PATH
$beforeLocation = $PWD.Path

try {
    $scriptPath = Join-Path $PSScriptRoot '../review-final.ps1'
    $reference = Join-Path $root 'reference'
    & $scriptPath -Destination $reference
    if ($WithoutInstalledSdk) {
        if ($env:OS -ne 'Windows_NT') { throw 'The PATH isolation check is only for a disposable Windows job.' }
        $env:PATH = (($env:PATH -split ';') | Where-Object {
            $_ -and -not (Test-Path -LiteralPath (Join-Path $_ 'dotnet.exe') -PathType Leaf)
        }) -join ';'
        if (Get-Command dotnet -CommandType Application -ErrorAction SilentlyContinue) { throw 'The test still sees dotnet on PATH.' }
    }
    $testPath = $env:PATH
    & $scriptPath -Destination $destination -TestGateway
    if ($env:PATH -cne $testPath -or $env:DOTNET_ROOT -cne $beforeDotnetRoot -or $PWD.Path -cne $beforeLocation -or
        $env:DOTNET_GENERATE_ASPNET_CERTIFICATE -cne $beforeCertificate -or $env:DOTNET_ADD_GLOBAL_TOOLS_TO_PATH -cne $beforeGlobalTools) {
        throw 'The review changed the caller environment.'
    }
    function Get-SnapshotFiles([string]$Directory) {
        Get-ChildItem -LiteralPath $Directory -Recurse -Force -File | ForEach-Object {
            "$($_.FullName.Substring($Directory.Length)) $((Get-FileHash -LiteralPath $_.FullName).Hash)"
        }
    }
    if (Compare-Object @(Get-SnapshotFiles (Join-Path $reference 'dotnet')) @(Get-SnapshotFiles $final)) {
        throw 'Tests changed the frozen final file set or contents.'
    }
    Write-Host 'PASS: The learner command tested the final gateway without changing the snapshot or caller environment.'
}
finally {
    $env:PATH = $beforePath
    if (Test-Path -LiteralPath $root) { Remove-Item -LiteralPath $root -Recurse -Force }
}
