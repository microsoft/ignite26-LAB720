#requires -Version 5.1
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-FinalGatewaySdk {
    param([Parameter(Mandatory)][string]$WorkDirectory)

    $hostCommand = Get-Command dotnet -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($hostCommand) {
        $sdks = @(& $hostCommand.Source --list-sdks)
        if ($LASTEXITCODE -ne 0) { throw 'dotnet --list-sdks failed. Repair the existing .NET installation and retry.' }
        if ($sdks -match '^10\.\d+\.\d+\s+\[') { return $hostCommand.Source }
    }

    Write-Host 'No stable .NET 10 SDK found. Downloading a temporary SDK from Microsoft for this test.'
    $onWindows = $env:OS -eq 'Windows_NT'
    $revision = 'ee83f9c42135205be4e0503bd472b6f99c9b7d51'
    if ($onWindows) {
        $installerName = 'dotnet-install.ps1'
        $expectedHash = '3bb07bc8025211836c1e4f9d3f6a044e55b1fb6eec518a6c78851d04e210442b'
        $executableName = 'dotnet.exe'
    }
    else {
        $installerName = 'dotnet-install.sh'
        $expectedHash = '082f7685e156738a1b2e2ed8381a621870d4ce8e8c59278034556f05c186eb2e'
        $executableName = 'dotnet'
    }
    $installer = Join-Path $WorkDirectory $installerName
    Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/dotnet/install-scripts/$revision/src/$installerName" -OutFile $installer
    if ((Get-FileHash -LiteralPath $installer -Algorithm SHA256).Hash -ine $expectedHash) {
        throw 'Microsoft .NET installer checksum mismatch; the installer was not run.'
    }
    $sdk = Join-Path $WorkDirectory 'sdk'
    if ($onWindows) {
        Unblock-File -LiteralPath $installer
        & powershell.exe -NoProfile -NonInteractive -ExecutionPolicy RemoteSigned -File $installer -Channel 10.0 -Quality GA -InstallDir $sdk -NoPath | Out-Host
    }
    else {
        & /bin/bash $installer --channel 10.0 --quality GA --install-dir $sdk --no-path | Out-Host
    }
    if ($LASTEXITCODE -ne 0) { throw "Temporary .NET 10 installation failed (exit code $LASTEXITCODE)." }
    $executable = Join-Path $sdk $executableName
    if (-not (Test-Path -LiteralPath $executable -PathType Leaf)) { throw 'Temporary SDK installer did not produce the dotnet executable.' }
    return $executable
}

function Invoke-FinalGatewayTest {
    param([Parameter(Mandatory)][string]$Snapshot)

    $work = Join-Path ([IO.Path]::GetTempPath()) "lab720-gw-$([guid]::NewGuid().ToString('N').Substring(0, 12))"
    [IO.Directory]::CreateDirectory($work) | Out-Null
    $previous = @{}
    foreach ($name in @('PATH','DOTNET_ROOT','DOTNET_GENERATE_ASPNET_CERTIFICATE','DOTNET_ADD_GLOBAL_TOOLS_TO_PATH')) {
        $previous[$name] = [Environment]::GetEnvironmentVariable($name)
    }
    Push-Location -LiteralPath $work
    try {
        # A first SDK invocation normally creates a developer certificate and adds global tools to PATH.
        $env:DOTNET_GENERATE_ASPNET_CERTIFICATE = 'false'
        $env:DOTNET_ADD_GLOBAL_TOOLS_TO_PATH = 'false'
        $dotnet = Get-FinalGatewaySdk -WorkDirectory $work
        $temporarySdk = Join-Path $work 'sdk'
        if ([IO.Path]::GetDirectoryName($dotnet) -eq $temporarySdk) {
            $env:DOTNET_ROOT = $temporarySdk
            $env:PATH = "$temporarySdk$([IO.Path]::PathSeparator)$($previous['PATH'])"
        }
        # Select a stable 10.x SDK even on a machine that also has newer SDKs or a preview.
        [IO.File]::WriteAllText((Join-Path $work 'global.json'), '{"sdk":{"version":"10.0.100","rollForward":"latestFeature","allowPrerelease":false}}')
        $version = & $dotnet --version
        if ($LASTEXITCODE -ne 0 -or $version -notmatch '^10\.\d+\.\d+$') { throw "Could not select a stable .NET 10 SDK: $version" }
        Write-Host "Testing the frozen final gateway with .NET SDK $version."
        $project = Join-Path $Snapshot 'apps/CaldovaAuthGateway/Tests/CaldovaAuthGateway.Tests.csproj'
        $output = Join-Path $work 'output'
        & $dotnet test $project --configuration Release --artifacts-path $output -p:RestoreLockedMode=true `
            --disable-build-servers -p:UseSharedCompilation=false -nodeReuse:false `
            --results-directory $output --logger 'trx;LogFileName=final-gateway.trx' | Out-Host
        if ($LASTEXITCODE -ne 0) { throw "Final gateway tests failed (exit code $LASTEXITCODE)." }
        [xml]$trx = Get-Content -LiteralPath (Join-Path $output 'final-gateway.trx') -Raw
        $counts = $trx.SelectSingleNode("//*[local-name()='ResultSummary']/*[local-name()='Counters']")
        if (-not $counts -or [int]$counts.total -ne 13 -or [int]$counts.passed -ne 13 -or [int]$counts.failed -ne 0) {
            throw 'Expected exactly 13 passing final gateway tests.'
        }
        Write-Host 'Final gateway: 13 passed, 0 failed, 0 skipped. The prepared finish and live execution were not tested.'
    }
    finally {
        foreach ($name in $previous.Keys) {
            if ($null -eq $previous[$name]) {
                if (Test-Path -LiteralPath "Env:$name") { Remove-Item -LiteralPath "Env:$name" }
            }
            else { [Environment]::SetEnvironmentVariable($name, $previous[$name]) }
        }
        Pop-Location
        Remove-Item -LiteralPath $work -Recurse -Force
    }
}

Export-ModuleMember -Function Invoke-FinalGatewayTest
