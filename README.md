<a name="start-building"></a>

# LAB720: Modernize applications with GitHub Copilot
### Session description

Use GitHub Copilot modernization to review a prepared application assessment, create a rulebook-guided plan, start a modernization run, and validate the prepared .NET results. This repository focuses on the Caldova Bank application-modernization track.

### Lab walkthrough

This 50-minute lab covers assessment review, rulebook setup and planning, and validation of a prepared .NET modernization result. Live planning is optional; the guide keeps prepared evidence separate from current agent output.

The modernization section uses the shared [Caldova workshop rulebook](https://github.com/ayangupt/ignite26-caldova-rulebook). All learners use the same training baseline; creating an individual rulebook repository is not a prerequisite.

Follow the [modernization guide](instructions/modernize-app-code.md). The [attendee instructions](instructions/README.md) provide the track index.

<a id="getting-started"></a>

### 🚀 Getting started

Run the lab on your own computer. You don't need a Skillable VM, an assigned lab account or an Azure subscription. Choose the path that matches the materials you have:

| What you have | Where to start |
|---|---|
| Just this repository | [Review the public final checkpoint](instructions/review-final.md). Trace a gateway risk from assessment to plan to final code. One command fetches the checkpoint and can run the gateway tests, downloading a temporary .NET 10 SDK if needed. No Copilot account or starting archive needed. |
| This repository and an authorized `caldova-rehearsal.zip` | [Set up the full 50-minute lab](#full-lab-setup). Review the original assessment, plan and deliberately flawed `finish`, and work through planning and execution. |

<a id="full-lab-setup"></a>

#### Full lab setup (Windows 11 preview)

Before the session, run setup directly on the Windows 11 PC you'll use for the exercises. The full lab is still a preview: the starting archive needs an approved distribution location, and the walkthrough has not yet been rehearsed on a participant PC with that archive.

- Windows 11 with permission to install tools. If [WinGet](https://learn.microsoft.com/en-us/windows/package-manager/winget/) is missing, setup uses Microsoft's `Microsoft.WinGet.Client` module from the PowerShell Gallery to prepare App Installer for the current user. If your organization manages App Installer, ask your administrator to provide it instead.
- A GitHub account with an active Copilot plan. The modernization agent supports Copilot Free, Pro, Pro+, Business, and Enterprise; see the [official quickstart](https://learn.microsoft.com/en-us/azure/developer/github-copilot-app-modernization/modernization-agent/quickstart) for current requirements.
- An authorized copy of the **exact LAB720 `caldova-rehearsal.zip` teaching archive** recorded in [the package manifest](infra/workload-manifest.json). Its six historical start/finish repositories are not included here and have no approved public download configured. A facilitator must supply it privately until distribution is approved; do not substitute the final snapshot or redistribute the archive without permission.

Setup installs tools directly on your PC, and they remain installed after the lab. It checks for Git, GitHub CLI, Visual Studio Code and the .NET 10 SDK, runs the Modernize CLI installer, and uses VS Code's bundled GitHub Copilot Chat when present. On a managed work PC, follow your organization's software installation policy. If you can't install the prerequisites, you can still do the [read-only checkpoint review](instructions/review-final.md) in built-in Windows PowerShell.

Setup checks the starting archive's SHA-256, preserves its Git history, and selects the prepared .NET execution/review branches before adding the four launch-directory configs. Before installing the workspace, it also checks that the prepared plan and compliance report are present and that tasks 001 and 002 are marked `success`. These are historical starting conditions, not results from your run.

The separate frozen `final\dotnet` checkpoint is downloaded automatically from a pinned, public package with its SHA-256 checked. Although hosted in PREL38, these are the **same bytes used by LAB720**, not a replacement curriculum or a substitute for its deliberately flawed `finish` example.

Clone this repository (or download its source ZIP if Git is not installed) and open **Windows PowerShell** in its root. If you downloaded the source ZIP, review the scripts and run `Get-ChildItem -Recurse .\scripts | Unblock-File` first.

Run setup with the archive path. It installs PowerShell 7 if needed, then continues the full setup in that shell:

```powershell
powershell.exe -NoProfile -ExecutionPolicy RemoteSigned -File .\scripts\setup.ps1 -LabArchive C:\path\to\caldova-rehearsal.zip
```

For this preview, omitting `-LabArchive` stops setup before it installs tools. There is no approved starting-archive download in the manifest yet.

If you already use PowerShell 7, `pwsh -NoProfile -File .\scripts\setup.ps1 -LabArchive C:\path\to\caldova-rehearsal.zip` runs the same setup directly.

By default, the lab files are installed under `C:\lab\caldova`, matching the guide and historical metadata. Setup will not overwrite an existing lab folder. `-LabRoot` accepts another path that does not yet exist, but relocation of the historical plan/assessment metadata has not been rehearsed; use the default for the first real-content rehearsal.

To supply the frozen final package locally, add `-FinalArchive C:\path\to\part2-validated-final-dotnet-20261027.zip`. This avoids the content download, not the tool/package downloads. Use `-SkipToolInstallation` only when the prerequisites are already installed; Git is still needed to select the prepared branches.

After installation, open a new PowerShell terminal and check that GitHub CLI is using your Copilot-enabled account:

```powershell
gh auth status
```

If you're signed out, run `gh auth login`. Sign in to VS Code with the same account, then verify setup:

```powershell
pwsh -NoProfile -File .\scripts\verify.ps1
```

The rulebook source is public, but planning and execution require your account's Copilot entitlement.
Verification checks the teaching-file layout, all 84 frozen-final hashes, tools, authentication, configs and 13 prepared-gateway tests. It does not claim that a live Modernize run loaded the rulebook. Confirm **`Rulebook loaded (3 files)`** separately during planning and execution, and follow the guide's local route checks.

#### For Tech Connect organizers

If attendees have only the repository, share the [public checkpoint review](instructions/review-final.md). For the full 50-minute workshop, arrange authorized access to the original archive first. Ask attendees to complete setup and sign-in on their own Windows 11 PCs **before** the session so the workshop time is available for the [modernization exercises](instructions/modernize-app-code.md).

### 🎯 Learning outcomes

By the end of this session, you will be able to:

- Identify upgrade, security, cloud-readiness, and database-connection risks from a prepared application-estate assessment.
- Start a rulebook-guided modernization plan and execution with GitHub Copilot, then review and test prepared .NET results for database-access changes, personal-data masking, and compatibility, recording what remains unverified.

### 💻 Technologies used

- [GitHub Copilot](https://learn.microsoft.com/en-us/azure/developer/github-copilot-app-modernization/) and the [`modernize` CLI](https://learn.microsoft.com/en-us/azure/developer/github-copilot-app-modernization/modernization-agent/cli-commands)
- [Visual Studio Code](https://code.visualstudio.com/docs) and [PowerShell](https://learn.microsoft.com/en-us/powershell/scripting/overview)
- [.NET 10](https://learn.microsoft.com/en-us/dotnet/core/whats-new/dotnet-10/overview) and [ASP.NET Core](https://learn.microsoft.com/en-us/aspnet/core/overview?view=aspnetcore-10.0)
- [`Microsoft.Data.SqlClient`](https://learn.microsoft.com/en-us/sql/connect/ado-net/introduction-microsoft-data-sqlclient-namespace?view=sql-server-ver17) and [managed identity](https://learn.microsoft.com/en-us/sql/connect/ado-net/sql/azure-active-directory-authentication?view=sql-server-ver17) for application-side database access
- [Azure Container Apps](https://learn.microsoft.com/en-us/azure/container-apps/overview) (modernization target)

### 📚 Official documentation

- [GitHub Copilot modernization quickstart](https://learn.microsoft.com/en-us/azure/developer/github-copilot-app-modernization/modernization-agent/quickstart)
- [Modernize CLI commands](https://learn.microsoft.com/en-us/azure/developer/github-copilot-app-modernization/modernization-agent/cli-commands)
- [ASP.NET Core documentation](https://learn.microsoft.com/en-us/aspnet/core/overview?view=aspnetcore-10.0)

### 👥 Content owners

<table>
<tr>
    <td align="center"><a href="https://github.com/ayangupt">
        <img src="https://avatars.githubusercontent.com/u/74832088?v=4" width="100px;" alt="Ayan Gupta"/><br />
        <sub><b>Ayan Gupta</b></sub></a><br />
        <sub>GitHub Copilot modernization</sub>
    </td>
</tr></table>

### ⚖️ Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft trademarks or logos is subject to and must follow [Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/legal/intellectualproperty/trademarks/usage/general). Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.

Any use of third-party trademarks or logos are subject to those third-party's policies.
