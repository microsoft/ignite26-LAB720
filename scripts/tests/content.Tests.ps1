#requires -Version 7.0
[CmdletBinding()]
param(
    [string]$FinalArchive,
    [switch]$InstallParticipantTools
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$repositoryRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../..'))
$contentModule = Import-Module (Join-Path $repositoryRoot 'scripts/LabContent.psm1') -Force -PassThru
$packages = Get-Content -LiteralPath (Join-Path $repositoryRoot 'infra/workload-manifest.json') -Raw | ConvertFrom-Json
$testRoot = Join-Path ([IO.Path]::GetTempPath()) "lab720-tests-$([guid]::NewGuid().ToString('N').Substring(0, 8))"
$script:passed = 0
if ($InstallParticipantTools -and -not $IsWindows) {
    throw '-InstallParticipantTools requires a disposable Windows machine.'
}

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw $Message }
}

function Assert-Throws {
    param([scriptblock]$Action, [string]$Pattern)
    try { & $Action }
    catch {
        if ($_.Exception.Message -like $Pattern) { return }
        throw
    }
    throw "Expected an error matching: $Pattern"
}

function Test-Case {
    param([string]$Name, [scriptblock]$Action)
    & $Action
    $script:passed++
    Write-Host "PASS: $Name"
}

function Write-FixtureFile {
    param([string]$Root, [string]$Path, [string]$Content = 'Synthetic test fixture, not LAB720 teaching content.')
    $file = Join-Path $Root $Path
    [IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($file)) | Out-Null
    [IO.File]::WriteAllText($file, $Content)
}

function Invoke-FixtureGit {
    param([string]$Root, [string[]]$Arguments)
    $output = @(& git -C $Root @Arguments)
    if ($LASTEXITCODE -ne 0) { throw "Fixture git failed: $($Arguments -join ' ')" }
    return $output
}

try {
    [IO.Directory]::CreateDirectory($testRoot) | Out-Null
    Test-Case 'All production PowerShell files parse unchanged' {
        foreach ($file in Get-ChildItem (Join-Path $repositoryRoot 'scripts') -File |
            Where-Object Extension -In '.ps1', '.psm1') {
            $parseErrors = $null
            [Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref]$null, [ref]$parseErrors) | Out-Null
            Assert-True ($parseErrors.Count -eq 0) "$($file.Name): $parseErrors"
        }
        Test-Case 'The installer and verifier distinguish outdated, supported and unrecognized GitHub CLI versions' {
            $tools = Import-Module (Join-Path $repositoryRoot 'scripts/LabTools.psm1') -Force -PassThru
            try {
                foreach ($version in @('2.44.9', '2.45.0', '2.100.0', 'unknown')) {
                    $probe = {
                        param($Value)
                        function gh { $script:LASTEXITCODE = 0; "gh version $Value" }
                        Test-LabGitHubCli
                    }
                    if ($version -eq 'unknown') {
                        Assert-Throws { & $tools $probe $version } '*Unable to determine*'
                    }
                    else {
                        Assert-True ((& $tools $probe $version) -eq ($version -ne '2.44.9')) "Unexpected result for gh $version."
                    }
                }
            }
            finally { Remove-Module $tools }
        }
        Test-Case 'Copilot Chat detection requires the extension manifest, not just a successful CLI exit' {
            $tools = Import-Module (Join-Path $repositoryRoot 'scripts/LabTools.psm1') -Force -PassThru
            $extension = Join-Path $testRoot 'bundled extension [1]'
            $locate = {
                param($Location)
                function code { $script:LASTEXITCODE = 0; if ($Location) { $Location } }
                Test-LabCopilotChat
            }
            try {
                Assert-True (-not (& $tools $locate '')) 'Empty extension lookup was accepted.'
                Write-FixtureFile $extension 'package.json' '{"publisher":"fixture","name":"copilot-chat","version":"0.1"}'
                Assert-True (-not (& $tools $locate $extension)) 'An unrelated extension was accepted.'
                Write-FixtureFile $extension 'package.json' '{"publisher":"GitHub","name":"copilot-chat","version":"0.1"}'
                Assert-True (& $tools $locate $extension) 'The Copilot Chat manifest was not recognized.'
            }
            finally { Remove-Module $tools }
        }
    }

    if (-not $FinalArchive) {
        $FinalArchive = Join-Path $testRoot $packages.final.fileName
        Invoke-WebRequest -Uri $packages.final.url -OutFile $FinalArchive
    }
    $FinalArchive = [IO.Path]::GetFullPath($FinalArchive)
    Test-Case 'The real published final package matches the LAB720 handoff digest' {
        Assert-True ((Get-FileHash -LiteralPath $FinalArchive -Algorithm SHA256).Hash -ieq $packages.final.sha256) 'Unexpected final archive checksum.'
    }

    $sourceDirectory = Join-Path $testRoot 'source'
    $fixtureRoot = Join-Path $sourceDirectory 'caldova'
    Write-FixtureFile $fixtureRoot 'README.md' 'Original fixture entry point.'
    foreach ($module in @('module-01-assess', 'module-02-plan', 'module-03-execute')) {
        foreach ($state in @('start', 'finish')) {
            $repo = Join-Path $fixtureRoot "modules/$module/$state"
            [IO.Directory]::CreateDirectory($repo) | Out-Null
            Invoke-FixtureGit $repo @('init', '--quiet', '--initial-branch=main') | Out-Null
            Invoke-FixtureGit $repo @('config', 'user.name', 'LAB720 fixture') | Out-Null
            Invoke-FixtureGit $repo @('config', 'user.email', 'fixture@example.invalid') | Out-Null
            Invoke-FixtureGit $repo @('config', 'core.autocrlf', 'false') | Out-Null
            Invoke-FixtureGit $repo @('config', 'commit.gpgSign', 'false') | Out-Null
            Invoke-FixtureGit $repo @('config', 'core.hooksPath', (Join-Path $testRoot 'disabled-hooks')) | Out-Null
            Write-FixtureFile $repo 'baseline.txt'
            if ($module -eq 'module-01-assess' -and $state -eq 'start') {
                $report = '.github/modernize/assessment-prebuilt/reports-fixture'
                Write-FixtureFile $repo "$report/index.html" '<html>Fixture report</html>'
                Write-FixtureFile $repo "$report/repos/CaldovaAuthGateway/facts/data-architecture.md"
                Write-FixtureFile $repo "$report/repos/CaldovaAuthGateway/facts/configuration-inventory.md"
            }
            if ($module -eq 'module-02-plan' -and $state -eq 'start') {
                foreach ($file in @('goals/dotnet.txt', 'skills/pii-masking/SKILL.md',
                    'rulebook/charter.md', 'rulebook/policies.md', 'rulebook/targets.md',
                    'apps/CaldovaAuthGateway/CaldovaAuthGateway.csproj')) {
                    Write-FixtureFile $repo $file
                }
            }
            Invoke-FixtureGit $repo @('add', '.') | Out-Null
            Invoke-FixtureGit $repo @('commit', '--quiet', '-m', 'Synthetic baseline') | Out-Null
            Invoke-FixtureGit $repo @('switch', '--quiet', '-c', 'modernization/dotnet') | Out-Null
            if ($module -eq 'module-03-execute') {
                if ($state -eq 'start') {
                    $plan = 'apps/CaldovaAuthGateway/.github/modernize/caldova-dotnet-modernization'
                    Write-FixtureFile $repo "$plan/plan.md"
                    Write-FixtureFile $repo "$plan/rulebook-compliance.md"
                    $task001 = @{id='001-upgrade-dotnet-framework-to-net10'; status='success'}
                    $task002 = @{id='002-transform-webforms-ashx-to-aspnetcore-mvc'; status='success'}
                    Write-FixtureFile $repo "$plan/.metadata/tasks.json" (ConvertTo-Json @{tasks=@($task001,$task002)} -Depth 3)
                    Write-FixtureFile $repo 'apps/CaldovaAuthGateway/CaldovaAuthGateway.csproj' '<Project />'
                }
                else {
                    Write-FixtureFile $repo 'apps/CaldovaAuthGateway/CaldovaAuthGateway.csproj' '<Project />'
                    Write-FixtureFile $repo 'apps/CaldovaAuthGateway/Tests/CaldovaAuthGateway.Tests.csproj' '<Project />'
                    Write-FixtureFile $repo 'apps/CaldovaLoanPortal/Dockerfile' 'FROM mono:6.12'
                    Write-FixtureFile $repo 'apps/CaldovaLoanPortal/CaldovaLoanPortal.csproj' '<Project />'
                }
                Invoke-FixtureGit $repo @('add', '.') | Out-Null
                Invoke-FixtureGit $repo @('commit', '--quiet', '-m', 'Synthetic prepared branch') | Out-Null
            }
            Invoke-FixtureGit $repo @('switch', '--quiet', 'main') | Out-Null
        }
    }
    $archive = Join-Path $testRoot 'fixture.zip'
    [IO.Compression.ZipFile]::CreateFromDirectory($sourceDirectory, $archive)
    $staging = Join-Path $testRoot 'staging'

    $reviewScript = Join-Path $repositoryRoot 'scripts/review-final.ps1'
    $review = Join-Path $testRoot 'final review [1]'
    Test-Case 'A changed SDK installer cannot run or leave a partial public review' {
        $gateway = Import-Module (Join-Path $repositoryRoot 'scripts/LabFinalGateway.psm1') -PassThru
        try {
            & $gateway {
                function script:Get-Command { param($Name,$CommandType,$ErrorAction) }
                function script:Invoke-WebRequest {
                    param($Uri,$OutFile,[switch]$UseBasicParsing)
                    [IO.File]::WriteAllText($OutFile, 'invalid installer fixture')
                }
            }
            Assert-Throws { & $reviewScript -FinalArchive $FinalArchive -Destination $review -TestGateway } '*installer checksum mismatch*'
            Assert-True (-not (Test-Path -LiteralPath $review)) 'Failed SDK verification installed a destination.'
            Assert-True (@(Get-ChildItem -LiteralPath $testRoot -Directory -Force -Filter '.lab720-review-*').Count -eq 0) 'Failed SDK verification left review staging.'
        }
        finally { Remove-Module $gateway }
    }
    Test-Case 'The public review rejects a starting ZIP and cleans staging' {
        Assert-Throws { & $reviewScript -FinalArchive $archive -Destination $review } '*SHA-256 mismatch*'
        Assert-True (-not (Test-Path -LiteralPath $review)) 'Wrong ZIP left a review destination.'
        Assert-True (@(Get-ChildItem -LiteralPath $testRoot -Directory -Force -Filter '.lab720-review-*').Count -eq 0) 'Review staging leaked after failure.'
    }
    Test-Case 'The public review installs only the real final checkpoint from a local ZIP' {
        & $reviewScript -FinalArchive $FinalArchive -Destination $review
        $entries = @(Get-ChildItem -LiteralPath $review -Force)
        Assert-True ($entries.Count -eq 1 -and $entries[0].Name -ceq 'dotnet') 'The review should contain only the final dotnet folder.'
        Assert-True (Test-Path -LiteralPath (Join-Path $review 'dotnet/VALIDATION.md') -PathType Leaf) 'Final validation record missing.'
        Assert-True (@(Get-ChildItem -LiteralPath $testRoot -Directory -Force -Filter '.lab720-review-*').Count -eq 0) 'Review staging leaked after success.'
    }
    Test-Case 'A second public review preserves the existing workspace' {
        Write-FixtureFile $review 'notes.txt' 'Learner notes'
        Assert-Throws { & $reviewScript -FinalArchive $FinalArchive -Destination $review } '*destination already exists*'
        Assert-True ([IO.File]::ReadAllText((Join-Path $review 'notes.txt')) -ceq 'Learner notes') 'Existing review was overwritten.'
    }

    Test-Case 'A non-LAB720 starting archive is rejected before extraction' {
        Assert-Throws { Expand-LabContent -LabArchive $archive -FinalArchive $FinalArchive -StagingDirectory $staging } '*SHA-256 mismatch*'
        Assert-True (-not (Test-Path -LiteralPath $staging)) 'Checksum failure wrote content.'
    }

    # Replace only the rehearsal digest in this test process; production code and the real final stay unchanged.
    & $contentModule { param($Hash) $script:Packages.rehearsal.sha256 = $Hash } (Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash
    Test-Case 'Two separate archives assemble without a final folder in the rehearsal' {
        $script:payload = Expand-LabContent -LabArchive $archive -FinalArchive $FinalArchive -StagingDirectory $staging
        Assert-True (Test-Path -LiteralPath (Join-Path $script:payload 'modules/module-03-execute/final/dotnet/manifest.json')) 'Final checkpoint was not installed.'
    }
    $payload = $script:payload
    Test-Case 'The final manifest checks all 84 real files' {
        & $contentModule { param($Root) Assert-FinalSnapshot -Root $Root } (Join-Path $payload 'modules/module-03-execute/final/dotnet')
    }
    Test-Case 'The prepared branches are selected without rewriting any refs' {
        $before = @{}
        foreach ($module in @('module-01-assess', 'module-02-plan', 'module-03-execute')) {
            foreach ($state in @('start', 'finish')) {
                $repo = Join-Path $payload "modules/$module/$state"
                $before[$repo] = (Invoke-FixtureGit $repo @('show-ref', '--heads')) -join "`n"
            }
        }
        Initialize-LabContent -Root $payload
        foreach ($repo in $before.Keys) {
            Assert-True (((Invoke-FixtureGit $repo @('show-ref', '--heads')) -join "`n") -ceq $before[$repo]) "Refs changed: $repo"
        }
        foreach ($state in @('start', 'finish')) {
            $repo = Join-Path $payload "modules/module-03-execute/$state"
            Assert-True ((Invoke-FixtureGit $repo @('branch', '--show-current')) -eq 'modernization/dotnet') 'Prepared branch was not selected.'
        }
    }
    Test-Case 'A dirty workspace is not reset or switched' {
        $file = Join-Path $payload 'modules/module-03-execute/start/baseline.txt'
        $original = [IO.File]::ReadAllText($file)
        [IO.File]::WriteAllText($file, 'Learner changes')
        Assert-Throws { Initialize-LabContent -Root $payload } '*not clean*'
        Assert-True ([IO.File]::ReadAllText($file) -eq 'Learner changes') 'Learner changes were overwritten.'
        [IO.File]::WriteAllText($file, $original)
    }
    Test-Case 'Missing prepared branches fail rather than falling back to main' {
        $repo = Join-Path $payload 'modules/module-03-execute/start'
        $commit = @(Invoke-FixtureGit $repo @('rev-parse', 'modernization/dotnet'))[0]
        Invoke-FixtureGit $repo @('switch', '--quiet', 'main') | Out-Null
        Invoke-FixtureGit $repo @('branch', '-D', 'modernization/dotnet') | Out-Null
        Assert-Throws { Initialize-LabContent -Root $payload } '*git switch*failed*'
        Invoke-FixtureGit $repo @('branch', 'modernization/dotnet', $commit) | Out-Null
        Initialize-LabContent -Root $payload
    }
    Test-Case 'Missing assessment facts fail validation' {
        $file = Join-Path $payload 'modules/module-01-assess/start/.github/modernize/assessment-prebuilt/reports-fixture/repos/CaldovaAuthGateway/facts/data-architecture.md'
        Move-Item -LiteralPath $file -Destination "$file.saved"
        Assert-Throws { Assert-LabContent -Root $payload } '*assessment is missing*'
        Move-Item -LiteralPath "$file.saved" -Destination $file
    }
    Test-Case 'Missing PII skill content fails validation' {
        $file = Join-Path $payload 'modules/module-02-plan/start/skills/pii-masking/SKILL.md'
        Move-Item -LiteralPath $file -Destination "$file.saved"
        Assert-Throws { Assert-LabContent -Root $payload } '*guide-required file is missing*'
        Move-Item -LiteralPath "$file.saved" -Destination $file
    }
    $preparedPlan = Join-Path $payload 'modules/module-03-execute/start/apps/CaldovaAuthGateway/.github/modernize/caldova-dotnet-modernization'
    Test-Case 'Fresh setup rejects missing or empty prepared review evidence' {
        foreach ($name in @('plan.md','rulebook-compliance.md')) {
            $file = Join-Path $preparedPlan $name
            Move-Item -LiteralPath $file -Destination "$file.saved"
            try {
                Assert-Throws { Assert-LabContent -Root $payload -CheckPreparedStart } "*guide-required file is missing:*$name*"
                [IO.File]::WriteAllText($file, " `r`n")
                Assert-Throws { Assert-LabContent -Root $payload -CheckPreparedStart } "*prepared $name is empty*"
            }
            finally { Move-Item -LiteralPath "$file.saved" -Destination $file -Force }
        }
    }
    Test-Case 'Fresh setup requires both specific task IDs to be successful, without repairing task state' {
        $file = Join-Path $preparedPlan '.metadata/tasks.json'
        $original = [IO.File]::ReadAllBytes($file)
        $pending = @{id=$task002.id; status='pending'}
        $other = @{id='002-unrelated'; status='success'}
        try {
            foreach ($case in @(
                @{json='{'; error='*Invalid JSON*'},
                @{json='{}'; error='*Expected a tasks array*'},
                @{json='{"tasks":[]}'; error="*'$($task001.id)'*"},
                @{tasks=@($task002); id=$task001.id},
                @{tasks=@($task001,$pending,$other); id=$task002.id},
                @{tasks=@($task001,$task002,$task002); id=$task002.id}
            )) {
                if ($case.ContainsKey('json')) { $json = $case.json; $expected = $case.error }
                else { $json = ConvertTo-Json @{tasks=$case.tasks} -Depth 3; $expected = "*'$($case.id)'*" }
                [IO.File]::WriteAllText($file, $json)
                Assert-Throws { Assert-LabContent -Root $payload -CheckPreparedStart } $expected
                Assert-True ([IO.File]::ReadAllText($file) -ceq $json) 'Validation rewrote the task evidence.'
            }
            # Normal verification after the learner runs Modernize does not enforce the starting state.
            [IO.File]::WriteAllText($file, (ConvertTo-Json @{tasks=@($task001,$pending)} -Depth 3))
            Assert-LabContent -Root $payload
        }
        finally { [IO.File]::WriteAllBytes($file, $original) }
    }
    Test-Case 'Changed frozen final files fail validation' {
        $file = Join-Path $payload 'modules/module-03-execute/final/dotnet/README.md'
        $original = [IO.File]::ReadAllBytes($file)
        [IO.File]::WriteAllText($file, 'Changed final')
        Assert-Throws { Assert-LabContent -Root $payload } '*Frozen final file is missing or changed*'
        [IO.File]::WriteAllBytes($file, $original)
    }
    Test-Case 'Changing the final manifest cannot bless changed content' {
        $file = Join-Path $payload 'modules/module-03-execute/final/dotnet/manifest.json'
        $original = [IO.File]::ReadAllBytes($file)
        [IO.File]::WriteAllText($file, '{"files":{}}')
        Assert-Throws { Assert-LabContent -Root $payload } '*frozen final manifest has changed*'
        [IO.File]::WriteAllBytes($file, $original)
    }
    Test-Case 'A wrong final ZIP is rejected' {
        Assert-Throws { Expand-LabContent -LabArchive $archive -FinalArchive $archive -StagingDirectory (Join-Path $testRoot 'bad-final') } '*SHA-256 mismatch*'
    }
    Test-Case 'The automatic download selects the pinned URL and installs the separate final' {
        & $contentModule {
            param($Path)
            $script:FixtureFinalArchive = $Path
            function script:Invoke-WebRequest {
                param($Uri, $OutFile, [switch]$UseBasicParsing)
                if ($Uri -cne $script:Packages.final.url) { throw 'Unexpected download URL.' }
                Copy-Item -LiteralPath $script:FixtureFinalArchive -Destination $OutFile
            }
        } $FinalArchive
        try {
            $downloaded = Expand-LabContent -LabArchive $archive -StagingDirectory (Join-Path $testRoot 'downloaded')
            & $contentModule { param($Root) Assert-FinalSnapshot -Root $Root } (Join-Path $downloaded 'modules/module-03-execute/final/dotnet')
        }
        finally {
            & $contentModule { Remove-Item Function:Invoke-WebRequest; Remove-Variable FixtureFinalArchive -Scope Script }
        }
    }
    Test-Case 'A download failure is surfaced, not reported as an installed final' {
        & $contentModule { function script:Invoke-WebRequest { throw 'Fixture network unavailable' } }
        try {
            Assert-Throws { Expand-LabContent -LabArchive $archive -StagingDirectory (Join-Path $testRoot 'download-failed') } '*Fixture network unavailable*'
        }
        finally {
            & $contentModule { Remove-Item Function:Invoke-WebRequest }
        }
    }

    $setupScript = Join-Path $repositoryRoot 'scripts/setup.ps1'
    $destination = Join-Path $testRoot 'installed lab [1]'
    Test-Case 'An omitted or unsafe rehearsal URL cannot enable a download' {
        try {
            & $contentModule { $script:Packages.rehearsal.url = $null }
            Assert-Throws { Get-RehearsalDownloadUri } '*No approved download*-LabArchive*review-final.ps1*'
            foreach ($invalid in @('http://example.invalid/a.zip', 'file:///archive.zip',
                'https://user@example.invalid/a.zip', 'https://example.invalid/a.zip?token=example',
                'https://example.invalid/a.zip#fragment')) {
                & $contentModule { param($Value) $script:Packages.rehearsal.url = $Value } $invalid
                Assert-Throws { Get-RehearsalDownloadUri } '*must be a stable HTTPS download URL*'
            }
        }
        finally {
            & $contentModule { param($Value) $script:Packages.rehearsal.url = $Value } $packages.rehearsal.url
        }
    }
    if ($IsWindows) {
        Test-Case 'Full setup without a source gives both supported options before creating files' {
            try {
                & $contentModule { $script:Packages.rehearsal.url = $null }
                function Invoke-WebRequest { throw 'Unexpected network request' }
                Assert-Throws { & $setupScript -LabRoot $destination } '*No approved download*-LabArchive*review-final.ps1*'
                Assert-True (-not (Test-Path -LiteralPath $destination)) 'Setup without a source wrote a destination.'
                Assert-True (@(Get-ChildItem -LiteralPath $testRoot -Directory -Force -Filter '.lab720-staging-*').Count -eq 0) 'Staging leaked.'
            }
            finally {
                & $contentModule { param($Value) $script:Packages.rehearsal.url = $Value } $packages.rehearsal.url
            }
        }
        Test-Case 'A configured rehearsal download uses the same checksum gate and full install as local input' {
            $source = 'https://example.invalid/lab720-fixture.zip'
            $fromDownload = Join-Path $testRoot 'downloaded installation'
            try {
                & $contentModule { param($Value) $script:Packages.rehearsal.url = $Value } $source
                $responseFile = $FinalArchive
                function Invoke-WebRequest {
                    param([uri]$Uri, $OutFile, [switch]$UseBasicParsing)
                    if ($Uri.AbsoluteUri -cne $source) { throw 'Unexpected rehearsal URL.' }
                    Copy-Item -LiteralPath $responseFile -Destination $OutFile
                }
                Assert-Throws { & $setupScript -FinalArchive $FinalArchive -LabRoot $fromDownload -SkipToolInstallation } '*SHA-256 mismatch*'
                Assert-True (-not (Test-Path -LiteralPath $fromDownload)) 'Wrong response installed a workspace.'
                Assert-True (@(Get-ChildItem -LiteralPath $testRoot -Directory -Force -Filter '.lab720-staging-*').Count -eq 0) 'Rejected download was retained.'
                $responseFile = $archive
                & $setupScript -FinalArchive $FinalArchive -LabRoot $fromDownload -SkipToolInstallation
                Assert-LabContent -Root $fromDownload
                Assert-True (@(Get-ChildItem -LiteralPath $testRoot -Directory -Force -Filter '.lab720-staging-*').Count -eq 0) 'Successful download was retained.'
            }
            finally {
                & $contentModule { param($Value) $script:Packages.rehearsal.url = $Value } $packages.rehearsal.url
            }
        }
        Test-Case 'Built-in Windows PowerShell forwards setup to PowerShell 7 without installing tools' {
            # The child has the unmodified production manifest, so the synthetic starting ZIP must fail.
            $badArchive = Join-Path $testRoot 'not the original.zip'
            Copy-Item -LiteralPath $archive -Destination $badArchive
            $result = & powershell.exe -NoProfile -ExecutionPolicy RemoteSigned -File $setupScript `
                -LabArchive $badArchive -FinalArchive $FinalArchive -LabRoot $destination -SkipToolInstallation 2>&1 | Out-String
            Assert-True ($LASTEXITCODE -ne 0 -and $result -match 'SHA-256 mismatch' -and
                $result -match 'PowerShell 7 setup failed') "Expected a child checksum failure, got: $result"
            Assert-True (-not (Test-Path -LiteralPath $destination)) 'Failed handoff wrote a destination.'
        }
        Test-Case 'The actual Windows setup installs content, README and four configs' {
            if ($InstallParticipantTools) {
                foreach ($tool in @('winget', 'pwsh', 'git', 'gh', 'code', 'dotnet', 'modernize')) {
                    Write-Host "Before setup: $tool present = $([bool](Get-Command $tool -ErrorAction SilentlyContinue))"
                }
            }
            & $setupScript -LabArchive $archive -FinalArchive $FinalArchive -LabRoot $destination -SkipToolInstallation:(!$InstallParticipantTools)
            Assert-LabContent -Root $destination
            Assert-True ([IO.File]::ReadAllText((Join-Path $destination 'README-ORIGINAL.md')) -eq 'Original fixture entry point.') 'Original README not preserved.'
            foreach ($relative in @('modules/module-02-plan/start', 'modules/module-03-execute/start',
                'modules/module-02-plan/start/apps/CaldovaAuthGateway', 'modules/module-03-execute/start/apps/CaldovaAuthGateway')) {
                $config = Get-Content -LiteralPath (Join-Path $destination "$relative/.github/modernize/config.json") -Raw | ConvertFrom-Json
                Assert-True ($config.feature_flags.rulebook -eq $true) 'Rulebook flag missing.'
                Assert-True ($config.portfolio_url -eq 'https://github.com/ayangupt/ignite26-caldova-rulebook') 'Wrong rulebook source.'
            }
            Assert-True (@(Get-ChildItem -LiteralPath $testRoot -Directory -Force -Filter '.lab720-staging-*').Count -eq 0) 'Staging leaked after success.'
        }
        if ($InstallParticipantTools) {
            Test-Case 'The installed participant tools run without signing in' {
                foreach ($tool in @('winget', 'pwsh', 'git', 'gh', 'code', 'modernize')) {
                    & $tool --version
                    Assert-True ($LASTEXITCODE -eq 0) "$tool --version failed."
                }
                $sdks = @(& dotnet --list-sdks)
                Assert-True ($LASTEXITCODE -eq 0 -and @($sdks -match '^10\.').Count -gt 0) ".NET 10 SDK missing: $sdks"
                Write-Host "Installed .NET 10 SDKs: $($sdks -match '^10\.' -join '; ')"
                Import-Module (Join-Path $repositoryRoot 'scripts/LabTools.psm1')
                Assert-True (Test-LabCopilotChat) 'Copilot Chat is neither bundled nor installed.'
            }
        }
        Test-Case 'A second setup refuses to overwrite an installed workspace' {
            Assert-Throws { & $setupScript -LabArchive $archive -FinalArchive $FinalArchive -LabRoot $destination -SkipToolInstallation } '*LabRoot already exists*'
        }
        Test-Case 'Failed Windows setup leaves no destination or staging directory' {
            $failedDestination = Join-Path $testRoot 'failed-install'
            Assert-Throws { & $setupScript -LabArchive $archive -FinalArchive $archive -LabRoot $failedDestination -SkipToolInstallation } '*SHA-256 mismatch*'
            Assert-True (-not (Test-Path -LiteralPath $failedDestination)) 'Failed setup left a destination.'
            Assert-True (@(Get-ChildItem -LiteralPath $testRoot -Directory -Force -Filter '.lab720-staging-*').Count -eq 0) 'Staging leaked after failure.'
        }
    }
    else {
        Test-Case 'Automatic tool setup explicitly rejects non-Windows platforms' {
            Assert-Throws { & $setupScript -LabArchive $archive -FinalArchive $FinalArchive -LabRoot $destination -SkipToolInstallation } '*supports Windows 11 only*'
            Assert-True (-not (Test-Path -LiteralPath $destination)) 'Unsupported setup wrote content.'
        }
        Write-Host 'NOT RUN: Windows setup integration cases. Run this same file on Windows.'
    }
    Write-Host "$script:passed checks passed. Fixture checks do not replace a real LAB720 archive/Windows 11 rehearsal."
}
finally {
    Remove-Module LabContent -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath $testRoot -Recurse -Force
}
