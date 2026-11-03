# Infrastructure

## Modernization rulebook configuration

This section is for the lab image preparer, not an additional participant exercise. The [participant guide](../instructions/modernize-app-code.md) uses the same public [Caldova workshop rulebook](https://github.com/ayangupt/ignite26-caldova-rulebook) as PREL38. Learners do not need to publish individual policy repositories.

The finalized training baseline is **1.0**, commit `5564f81d46c25830910e44dea27a32f32720dabc`. This is workshop policy, not production-policy approval.

### Prepare the launch directories

Use [modernize-config.json](modernize-config.json) as the content of `.github\modernize\config.json` in each actual launch directory:

- `C:\lab\caldova\modules\module-02-plan\start`
- `C:\lab\caldova\modules\module-03-execute\start`

The shortened lab starts the CLI at those module roots. If the image also supports launching Modernize from VS Code or an application directory, the gateway app root in each module needs the same config:

- `C:\lab\caldova\modules\module-02-plan\start\apps\CaldovaAuthGateway`
- `C:\lab\caldova\modules\module-03-execute\start\apps\CaldovaAuthGateway`

Keep the config available after selecting the prepared `modernization/dotnet` branch. Inspect existing configuration and authored work before changing it; do not reset repositories or overwrite a learner's plan. Local `rulebook\charter.md`, `policies.md` and `targets.md` in the planning workspace should be reading copies of the shared baseline.

Do not alter the deliberately flawed `finish` review example or the frozen `final\dotnet` files, rulebook copies and manifest to make historical evidence appear newly validated.

## Prepare the learner VM

The shortened LAB720 modernization track needs Git, GitHub CLI, Modernize CLI, the .NET 10 SDK, Visual Studio Code and its Copilot modernization support. The [existing LAB720 image preparation](https://github.com/microsoft/ignite26-LAB720/issues/14) established Modernize 1.0.62, GitHub CLI 2.90.0 and .NET SDK 10.0.403. This file/configuration update does not require installing Java, Gradle or Docker. Preserve the existing Azure CLI and SRE setup.

Use **Auto** in VS Code and explicit `--model auto` in the attendee commands. The IDE picker does not configure the CLI.

The guide's preflight checks cover the tools needed for the shortened .NET track. If a required tool is absent, the learner should contact the facilitator rather than install software or use a personal account. Verify the prepared image on a fresh learner launch before describing the VM as ready.

### Apply the updated assessment files

The November 2 PREL38 changes are in commit [`e2c26b5`](https://github.com/microsoft/ignite26-PREL38/commit/e2c26b558b9b3a87688e7711433ad6b6093e3a91). Use its [Rename-PreparedReports.ps1](https://github.com/microsoft/ignite26-PREL38/blob/e2c26b558b9b3a87688e7711433ad6b6093e3a91/app-modernization/Rename-PreparedReports.ps1) and [Set-AssessmentDefaults.ps1](https://github.com/microsoft/ignite26-PREL38/blob/e2c26b558b9b3a87688e7711433ad6b6093e3a91/app-modernization/Set-AssessmentDefaults.ps1) as the source for the LAB720 image refresh.

Back up the affected module repositories, their branches and the existing user-level defaults before applying the changes in an authorized preparation instance. Inspect the actual LAB720 layout; do not assume the PREL38 wrapper's fixed twelve-branch count applies. Stop on dirty repositories, conflicting files or migration warnings rather than overwrite authored work.

| File or area | Required result |
|---|---|
| `.github\modernize\repos.json` | The default one-app list selects `CaldovaAuthGateway`. In `module-01-assess\start`, its path is `C:/lab/caldova/modules/module-01-assess/start/apps/CaldovaAuthGateway`. |
| `.github\modernize\repos-portfolio.json` | Retains the former six-app `repos.json`, including its application groups. |
| `.github\modernize\repos-live.json` | Renamed to `repos.json`; no tracked copy remains on the prepared local branches. |
| Tracked module report text and paths | Use Caldova names, including `repos\CaldovaAuthGateway`. Preserve the historical report's results and the deliberately flawed review example. |
| `C:\Users\LabUser\.modernize\assessment-config.yaml` | Set as **LabUser** for the interactive menus: Full analysis, High CVE severity, .NET 10, OpenJDK 21, Azure Container Apps and Linux. The shared Java defaults do not add a Java exercise to LAB720. |
| Module `assess-config.yaml` and `.github\modernize\config.json` | Keep their existing explicit assessment settings and shared-rulebook configuration; neither replaces the user-level defaults. |

The user-level defaults file is UTF-8 without a BOM and uses CRLF line endings. Its expected SHA-256 is `d8ba1e9b5bb7b6016df2b14349abf8e41d47bf0a1ffe4feb9fb2d0a424db8195`.

Apply the naming/list migration across the existing local module branches so selecting `modernization/dotnet` does not restore the old filenames. Keep `module-03-execute\final\dotnet`, its manifest, the original archives, SRE resources and learner authentication untouched. Do not copy the whole PREL38 VM disk chain into LAB720.

These are image-preparation changes, not participant steps. Publish the revised file paths only after they survive **Commit Changes** and a fresh LAB720 launch. A repository update or a staged script does not update the VM.

**Image status (November 2, 2026):** These changes and the LAB720 entry-point README below were applied to VM profile 370024 and committed as disk layer 23 (`Win11-Base-Disk-226801-370024-1793672229-23.vhdx`). The development, ILT and self-paced LAB720 profiles share that layer. A fresh launch confirmed all six module repositories on `main` with no tracked changes (twelve branches checked), the one-app `repos.json`, six-app `repos-portfolio.json`, no `repos-live.json`, Caldova report names, the LabUser defaults hash and the root README. Module rulebook configuration was left unchanged. The `modernization/java` branch of `module-03-execute\start` still lacks the shared-rulebook config; that gap predates this update and is outside the .NET track. These file checks do not establish live planning/execution readiness; see the rehearsal result below.

**Skillable manual (November 3, 2026):** The **Modernize app code** section of the LAB720 Skillable manual (instruction set 362436) now matches [the repo guide](../instructions/modernize-app-code.md): the one-app `repos.json`, the Caldova report path, the Copilot access check in **Get ready**, the documented 20-40-minute provisioning window, and the HTTP 403 troubleshooting row. The manual shows the flow as a one-line text summary instead of the Mermaid diagram. No other manual sections changed. The initial update was confirmed by re-export and a fresh learner launch; the provisioning note was then checked in both the reloaded editor and rendered learner instructions. The saved text remained unchanged after ending the rehearsal without saving its VM. When the repo guide changes, update the Skillable manual in the same pass.

### Use the LAB720 entry point

The shared `caldova-rehearsal.zip` contains a root `caldova/README.md` headed **PREL38 Part 2**, with a 15/15/30-minute schedule. Extracting that archive into `C:\lab` places the longer pre-day walkthrough at `C:\lab\caldova\README.md`. That file is separate from the current LAB720 Skillable manual and can send attendees to the wrong timing and track.

During owner-approved LAB720 image preparation, use [lab-root-README.md](lab-root-README.md) as `C:\lab\caldova\README.md`. Inspect the existing file first and preserve any newer authored changes; retain the inherited PREL38 README separately as reference rather than deleting it. For this entry-point replacement, change only the top-level README. Apply the separate assessment-file migration above without replacing the original archives or frozen final snapshot.

The replacement directs learners to **Modernize app code** in Skillable and repeats the established LAB720 8/12/25-minute, .NET-only flow. Confirm those values agree with the assigned manual on a fresh learner launch. A repository update alone does not replace the README already stored in the shared VM image; an authorized guest-file update and image capture are needed for future launches to receive it.

### Verify the configured image

PREL38 verified native loading with Modernize CLI **1.0.62** and explicit **`--model auto`**. That is source evidence for these instructions, not proof that the LAB720 image has the same tools or settings. Do not assume the CLI's default model or VS Code's picker selects Auto for a terminal command.

On a fresh LAB720 launch, confirm the required tools, package access and assigned-account sign-in before testing planning and execution. Both live operations must show **`Rulebook loaded (3 files)`**. A completed plan should also contain `rulebook-compliance.md` and `.metadata\rulebook-metadata.json` identifying the shared source. Reading local policy files, a prepared compliance report or a passing build is not sufficient evidence of a current native load.

**Live rehearsal (November 3, 2026): native rulebook loading verified for planning and execution.** The earlier instance **66924143** authenticated successfully but returned a Copilot HTTP **403** before rulebook loading; VS Code also requested Copilot Business access. That instance ran for only **15 minutes 26 seconds**. [Skillable advises allowing 20-40 minutes for GitHub/Copilot access to populate](https://github.com/microsoft/ignite26-LAB720/issues/9#issuecomment-6317108726), so the early failure alone did not establish that an administrator needed to change the account's entitlement.

Fresh instance **66925696** used its assigned account and waited a full **40 minutes after Enterprise SSO**, more than 50 minutes after launch. Modernize **1.0.62**, GitHub CLI **2.90.0** and Copilot CLI **1.0.57**, with explicit **`--model auto`**, then completed live planning without license grants, enterprise-policy changes or personal credentials. The planning command reported **`Rulebook loaded (3 files)`** and generated a new nine-task plan, `rulebook-compliance.md` and `.metadata\rulebook-metadata.json`. The metadata identified the shared rulebook URL and baseline commit `5564f81d46c25830910e44dea27a32f32720dabc`.

The separate prepared execution workspace was clean before switching to `modernization/dotnet`; its first two tasks already showed `success`. Live execution independently reported **`Rulebook loaded (3 files)`** and started task 003. This bounded image-configuration rehearsal was stopped there: it does **not** establish completion of the remaining modernization tasks, application tests, database connectivity or deployment. Project test suites and deployment were excluded. The CLI was signed out, the clipboard cleared, and the instance ended without saving or committing. VM profile 370024 still uses layer 23; no signed-in rehearsal state was captured.

Keep shared-image promotion coordinated with the other module owners. Merging this configuration file or the documentation PR does not install dependencies, copy files into Skillable, capture a VM or complete a fresh-learner rehearsal.

The local gateway validation does not require provisioning Azure SQL or changing the SRE resources. Any separate live DB-assessment exercise still needs its agreed database/context and CLI capability; an inferred data model is not a live database check.
