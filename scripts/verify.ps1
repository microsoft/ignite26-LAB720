#requires -Version 7.0
[CmdletBinding()]
param(
    [string]$LabRoot = 'C:\lab\caldova'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-Command {
    param([Parameter(Mandatory = $true)][string]$Name)
    if ($null -eq (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Required command '$Name' is not on PATH. Open a new terminal after setup or install the missing tool."
    }
}

$root = [IO.Path]::GetFullPath($LabRoot)
if (-not (Test-Path -LiteralPath $root -PathType Container)) {
    throw "Lab folder not found: $root. Run scripts/setup.ps1 first."
}

Import-Module (Join-Path $PSScriptRoot 'LabContent.psm1')
Assert-LabContent -Root $root

foreach ($command in @('git', 'gh', 'code', 'dotnet', 'modernize')) {
    Assert-Command $command
}

Import-Module (Join-Path $PSScriptRoot 'LabTools.psm1')
if (-not (Test-LabGitHubCli)) {
    throw 'GitHub CLI 2.45.0 or later is required.'
}
if (-not (Test-LabCopilotChat)) {
    throw 'GitHub Copilot Chat is missing from VS Code. Install the extension or update VS Code.'
}

$sdkVersions = @(& dotnet --list-sdks)
if ($LASTEXITCODE -ne 0 -or @($sdkVersions | Where-Object { $_ -match '^10\.' }).Count -eq 0) {
    throw '.NET 10 SDK is not installed. Run scripts/setup.ps1 again or install the SDK manually.'
}

Write-Host 'Checking GitHub CLI authentication...'
& gh auth status
if ($LASTEXITCODE -ne 0) {
    throw 'GitHub CLI is not authenticated. Run gh auth login and retry.'
}

Write-Host 'Checking Modernize CLI...'
& modernize --version
if ($LASTEXITCODE -ne 0) {
    throw 'Modernize CLI could not report its version.'
}

$launchDirectories = @(
    'modules\module-02-plan\start',
    'modules\module-03-execute\start',
    'modules\module-02-plan\start\apps\CaldovaAuthGateway',
    'modules\module-03-execute\start\apps\CaldovaAuthGateway'
)
foreach ($relativeDirectory in $launchDirectories) {
    $configPath = Join-Path $root "$relativeDirectory\.github\modernize\config.json"
    if (-not (Test-Path -LiteralPath $configPath -PathType Leaf)) {
        throw "Modernize config is missing: $configPath. Run setup.ps1 again with a clean LabRoot."
    }
    $config = Get-Content -LiteralPath $configPath -Raw | ConvertFrom-Json
    if ($config.feature_flags.rulebook -ne $true -or
        $config.portfolio_url -ne 'https://github.com/ayangupt/ignite26-caldova-rulebook') {
        throw "Modernize config has unexpected content: $configPath"
    }
}

$testProject = Join-Path $root 'modules\module-03-execute\finish\apps\CaldovaAuthGateway\Tests\CaldovaAuthGateway.Tests.csproj'
if (-not (Test-Path -LiteralPath $testProject -PathType Leaf)) {
    throw "Gateway test project is missing: $testProject. Confirm that the authorized lab archive contains the full modernization payload."
}

$resultsDirectory = Join-Path ([IO.Path]::GetTempPath()) "lab720-test-results-$([guid]::NewGuid())"
try {
    Write-Host 'Building and running the prepared gateway tests...'
    & dotnet test $testProject --configuration Release --results-directory $resultsDirectory --logger 'trx;LogFileName=lab720-verify.trx'
    if ($LASTEXITCODE -ne 0) {
        throw "Gateway tests failed (exit code $LASTEXITCODE). Results are retained at $resultsDirectory."
    }

    $trxPath = Join-Path $resultsDirectory 'lab720-verify.trx'
    if (-not (Test-Path -LiteralPath $trxPath -PathType Leaf)) {
        throw "Test run succeeded but its TRX results file is missing: $trxPath"
    }
    [xml]$trx = Get-Content -LiteralPath $trxPath -Raw
    $counters = $trx.SelectSingleNode("//*[local-name()='ResultSummary']/*[local-name()='Counters']")
    if ($null -eq $counters) {
        throw "The test run succeeded but its TRX summary is missing: $trxPath"
    }
    if ([int]$counters.total -ne 13 -or
        [int]$counters.passed -ne 13 -or
        [int]$counters.failed -ne 0) {
        throw "Expected 13 passing tests and no failures. TRX counters: $($counters.OuterXml)"
    }
    Remove-Item -LiteralPath $resultsDirectory -Recurse -Force
    Write-Host 'Verification passed: Modernize config is present and all 13 gateway tests passed.'
}
catch {
    Write-Host "Verification failed. Any test results are retained at: $resultsDirectory"
    throw
}
