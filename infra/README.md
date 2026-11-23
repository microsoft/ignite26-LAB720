# Infrastructure

For the self-serve modernization track, `../scripts/setup.ps1` installs the participant tools, prepares the learner-supplied **LAB720** archive, installs the separate frozen final checkpoint and [lab-root-README.md](lab-root-README.md), and copies the shared rulebook configuration into the actual CLI launch directories. LAB720's current 50-minute guide is the baseline; PREL38 is not a replacement track.

## Teaching packages and release gate

The LAB720 environment handoff, [microsoft/ignite26-lab-management#689](https://github.com/microsoft/ignite26-lab-management/issues/689), identifies **two distinct ZIPs**, pinned by SHA-256 in [workload-manifest.json](workload-manifest.json):

| Package | Purpose | Source |
|---|---|---|
| `caldova-rehearsal.zip` | Six original assessment/planning/execution start/finish repositories, including Git history and prepared branches | Authorized local copy required; no approved public distribution location is configured |
| `part2-validated-final-dotnet-20261027.zip` | Separate frozen three-application comparison checkpoint | Automatically downloaded from a commit-pinned public package, or supplied with `-FinalArchive` |

The public final package is hosted in PREL38, but its hash is the exact hash recorded for LAB720. Setup never substitutes it for the original teaching modules. Both archives are checked before extraction; the final manifest and all 84 listed files are also checked. The module repositories remain separate from `final\dotnet`.

Without the rehearsal archive, `scripts/review-final.ps1` installs only the frozen checkpoint in a separate review directory. It shares the final-package checks with full setup and is never an implicit fallback. See the [public checkpoint review](../instructions/review-final.md) for what can actually be learned and tested there.

The historical handoff records successful LAB720 image checks, not a clean-machine test of this repository's installer. **Public clone-and-run readiness for the full lab remains blocked** until the original workload has an approved source and the actual setup is rehearsed on Windows 11. Do not publish the historical code/report archive merely because the final package is public.

Before calling the self-serve track ready:

1. **Approve the source.** Until the content owner approves a public distribution location for the exact `caldova-rehearsal.zip`, leave `rehearsal.url` **null**. An authorized private copy can be used with `-LabArchive` for rehearsal; private transfer does not authorize public hosting. Once public distribution is approved, set only `rehearsal.url` in [workload-manifest.json](workload-manifest.json) to a stable, anonymous HTTPS download for those bytes (no credentials or signed links). Keep the recorded hash; a mismatch is a release blocker, not a reason to update the digest.
2. **Rehearse on a participant PC.** Use a Windows 11 PC with no prior LAB720 workspace, under the account that will run the exercises. Keep existing developer tools; record which setup reuses and which it installs. Clone or unzip the candidate revision. Once the source is approved and configured, start in built-in Windows PowerShell and run `powershell.exe -NoProfile -ExecutionPolicy RemoteSigned -File .\scripts\setup.ps1` with **no** archive or skip arguments. Use the default `C:\lab\caldova`. Confirm both packages download, the tools are available, and a second invocation preserves the installed workspace.
3. **Run the 50-minute guide.** Sign in, run `scripts/verify.ps1`, and follow the [participant guide](../instructions/modernize-app-code.md). Open the prepared assessment and both gateway facts; confirm the prepared plan, compliance report, and `success` status for tasks 001/002 **before** starting execution. Observe `Rulebook loaded (3 files)` separately in live planning and execution. From the prepared `finish`, build the gateway, verify 13 passing tests and check the local `/health` and unauthenticated `/WhoAmI.ashx` responses. Do not substitute `final` results or run database-backed login, Azure or SRE.
4. **Record the result before changing the preview label.** Capture the candidate commit, Windows build, package hashes, installed tool versions, and which of the checks above passed, failed or did not run. Do not include tokens, account details or private teaching artifacts. The historical successful image used Modernize 1.0.62, GitHub CLI 2.90.0 and .NET SDK 10.0.403; it is not evidence that the new installer worked.

## Modernization rulebook configuration

The [participant guide](../instructions/modernize-app-code.md) uses the same public [Caldova workshop rulebook](https://github.com/ayangupt/ignite26-caldova-rulebook) as PREL38. Learners do not need to publish individual policy repositories.

The finalized training baseline is **1.0**, commit `5564f81d46c25830910e44dea27a32f32720dabc`. This is workshop policy, not production-policy approval.

### Prepare the launch directories

Use [modernize-config.json](modernize-config.json) as the content of `.github\modernize\config.json` in each actual launch directory:

- `C:\lab\caldova\modules\module-02-plan\start`
- `C:\lab\caldova\modules\module-03-execute\start`

The shortened lab starts the CLI at those module roots. If the image also supports launching Modernize from VS Code or an application directory, the gateway app root in each module needs the same config:

- `C:\lab\caldova\modules\module-02-plan\start\apps\CaldovaAuthGateway`
- `C:\lab\caldova\modules\module-03-execute\start\apps\CaldovaAuthGateway`

Setup first selects `main` for planning-start and `modernization/dotnet` for execution-start and execution-finish, then copies the configs. It requires the extracted repositories to be clean, preserves their refs and does not execute archived Git hooks. This prepares the branch selection that the current guide assumes has already happened.

On a fresh install it checks the execution-start plan and compliance report are nonempty and that `.metadata/tasks.json` contains exactly one successful entry for each of the two task IDs in [the LAB720 task-state screenshot](../img/modernization/caldova-task-states.png). This check never edits task state. Verification after a learner's run does not require the tasks to remain in their starting state.

Keep the config available after selecting the prepared branch. Inspect existing configuration and authored work before changing it; do not reset repositories or overwrite a learner's plan. Local `rulebook\charter.md`, `policies.md` and `targets.md` in the planning workspace should be reading copies of the shared baseline.

Do not alter the deliberately flawed `finish` review example or the frozen `final\dotnet` files, rulebook copies and manifest to make historical evidence appear newly validated.

### Install the LAB720 entry point

The setup script installs [lab-root-README.md](lab-root-README.md) as `README.md` at the extracted workload root. If the authorized archive already has a root `README.md`, setup renames it to `README-ORIGINAL.md` in the installed copy; it does not modify the source archive. The replacement points learners to the guide in their local repository copy and describes the 50-minute modernization flow: 5 minutes for setup/transitions, 8 for assessment, 17 for rulebook setup and planning, and 20 for execution and validation.

### Verify a self-serve install

Run `scripts/verify.ps1` from the cloned repository after setup and sign-in. Pass the same `-LabRoot` if you used a nondefault destination. It checks the teaching-file layout, frozen-final manifest/hashes, required local commands, GitHub CLI authentication, .NET 10, Modernize CLI availability, four launch-directory configs, and exactly 13 passing prepared-gateway tests. Failed test results are retained at the printed temporary path for diagnosis. These checks do not prove that a live Modernize operation can access the shared rulebook; on a fresh install, confirm that both planning and execution report **`Rulebook loaded (3 files)`**.

The self-serve track validates application code on the participant's PC. Preparing or capturing a VM image, provisioning Azure SQL and deploying applications are out of scope.

## Repeatable script checks

With PowerShell 7 and Git installed, run:

```powershell
pwsh -NoProfile -File .\scripts\tests\content.Tests.ps1
```

The checks use synthetic starting repositories and the real public final package. Supply `-FinalArchive` to reuse a downloaded copy without network access. No Pester or private workload download is required. Rehearsal-source cases use an in-memory fixture URL, download response and digest; production scripts and the on-disk manifest are unchanged.

These checks cover two-package extraction, hash failures, final-file/manifest tampering, preservation of Git refs, prepared branch selection, missing guide inputs, dirty-workspace refusal and download failures. On Windows they also invoke the actual setup with `-SkipToolInstallation` and check configuration placement, non-overwrite behavior and cleanup. A separate Windows check starts from built-in Windows PowerShell and verifies that the PowerShell 7 child rejects the synthetic archive. The GitHub Actions workflow runs on Windows and Linux; Windows Server fixture checks are **not** a clean Windows 11 tool-installation or real-workload rehearsal.

The public review is checked separately. `scripts/tests/review-final.Tests.ps1` runs the learner's `review-final.ps1 -TestGateway` command and compares its installed files with a read-only review. It builds with a stable .NET 10 SDK and locked dependencies outside the snapshot. If the SDK is missing, the script verifies a commit-pinned Microsoft `dotnet/install-scripts` installer by SHA-256, installs the GA 10.0 SDK in a temporary directory, and removes it afterward. CI exercises the missing-SDK path with built-in Windows PowerShell (`-WithoutInstalledSdk` hides the host command for this test process only) and the existing-SDK path on Linux. Neither uses synthetic or private starting material.

The `windows11-tools` CI job runs `content.Tests.ps1 -InstallParticipantTools` on a disposable Windows 11 ARM64 runner. Unlike the fixture-only jobs, it lets `setup.ps1` install missing tools and extensions and then launches the installed commands. The hosted image already includes some prerequisites. This is not a blank Windows machine, the original workload, or an authenticated Copilot run. Do not opt into this switch on a shared machine just to run the content tests.

### Windows 11 installer rehearsal

[Run 44634605278](https://github.com/microsoft/ignite26-LAB720/actions/runs/44634605278) exercised revision `4e1af08` on Windows 11 Enterprise ARM64, build `10.0.26200`. The WinGet, VS Code and Modernize commands were absent before setup.

| Setup action | Observed result |
|---|---|
| Prepared WinGet for the current user | WinGet `1.29.380` |
| Installed VS Code and used its bundled Copilot Chat without a separate Marketplace install | VS Code `1.146.0`; Copilot Chat `0.74.0` |
| Installed the stable Modernize CLI | `1.0.95` |
| Reused tools already present on the image | PowerShell `7.6.10`, Git `2.56.1.windows.1`, GitHub CLI `2.104.0`, .NET 10 SDKs including `10.0.404` |

Setup finished without participant input. The starting repositories were synthetic; only the final checkpoint was the real LAB720 package. This run did not exercise first-time installation of the preinstalled tools, participant sign-in, or the 50-minute exercise. The [full-lab release gate](#teaching-packages-and-release-gate) remains open.
