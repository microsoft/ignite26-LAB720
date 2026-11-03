## Before you're done

This repo has been created for your Microsoft Ignite 2026 session. Here's how to get it ready.

**Easiest path — use the agent (recommended):**

- Open GitHub Copilot Chat and say `help me initialize repo`. The agent will walk you through getting the README populated.
- When you're ready to publish, say `help me finalize repo`. The agent will clean up unused folders, validate everything, and remove this "Before you're done" section and other extra stuff that attendees don't need to see.
- Curious how it works? Read the [agent workflow](.github/AGENT-WORKFLOW.md).

**Doing it manually?**

Fill in the sections below yourself, then:

- Delete any placeholder folders you don't need (`data/`, `infra/`, etc.)
- Delete this "Before you're done" section
- Delete `.github/agents/`, `.github/tests/`, `.github/copilot-instructions.md`, and `.github/AGENT-WORKFLOW.md` — these are template tooling, not part of your published repo

**Folder conventions:**

- Attendee step-by-step guidance goes in `instructions/`. If you use MkDocs or a docs site instead, put it in `docs/` and link to it from this README.
- Reference material and background reading go in `docs/`.
- You can add a `.devcontainer/` folder if needed.

---

<a name="start-building"></a>

<p align="center">
<img src="img/banner-ignite-26.png" alt="Microsoft Ignite 2026" width="100%"/>
</p>

# [Microsoft Ignite 2026](https://ignite.microsoft.com)

## 🔥LAB720: Hands-on: Modernize apps and databases and automate operations
### Session description

Get hands-on using AI to modernize applications, databases, and operations. Use GitHub Copilot to assess and upgrade a Java or .NET app, remediate dependencies, containerize workloads, and modernize the database. Then use Azure SRE Agent to investigate incidents, identify root causes, and automate remediation. Leave with practical experience applying AI agents across the modernization and operations lifecycle.

### Lab walkthrough

This 75-minute hands-on lab combines application modernization and operations automation using two separate training workloads in your assigned lab environment. For Caldova Bank, review a prepared assessment, start a rulebook-guided modernization plan and execution with GitHub Copilot, and check prepared .NET results for database-access changes, personal-data masking, and compatibility. For Caldova Retail Co., use Azure SRE Agent to investigate a product-search failure, verify recovery, schedule cost reviews, and create live traffic-and-health reports.

The modernization section uses the shared [Caldova workshop rulebook](https://github.com/ayangupt/ignite26-caldova-rulebook). All learners use the same training baseline; creating an individual rulebook repository is not a prerequisite.

### 🚀 Getting started

The exercises require an assigned, prepared lab environment and lab accounts. Cloning this repository does not set up the lab. If the assigned environment, exercise files, or tools are unavailable, ask the facilitator or lab provider rather than installing software, creating replacement resources, or using personal accounts.

#### In a guided session

If you're following along during a live session:

1. Use the participant access details supplied by your facilitator to open the assigned lab environment. Use the **Resources** tab for VM access and assigned account details, and open sign-in pages inside the VM.
2. Stay in the Skillable instruction pane: follow **Start > GitHub and Copilot**, then **Modernize app code**. Follow the facilitator's pacing and use the prepared assessment, plan, and results rather than waiting for long-running agent steps. The [repo guide](instructions/modernize-app-code.md) is a reference copy; you do not need to switch guides during the lab.
3. Continue to **SRE Agent** in the lab manual. Reuse the assigned VM and accounts, but use that module's Caldova Retail Co. repository and Azure resource names rather than the Caldova Bank workload.

#### On your own

If you're learning at your own pace:

1. Confirm access to the assigned lab environment and complete lab manual with the lab provider. The exercises depend on its VM, prepared files, and assigned GitHub and Azure accounts; repository access alone is not enough.
2. In the Skillable instruction pane, follow **Start > GitHub and Copilot**, then **Modernize app code**. Work through each checkpoint, use the prepared results while live work runs, and record any checks or tasks that remain unverified. [Modernize application code with GitHub Copilot](instructions/modernize-app-code.md) provides the same steps as a repo reference, including sign-in screenshots in **Get ready**.
3. Follow the **SRE Agent** module in the lab manual for the operations exercises. Keep the two workloads separate and verify the customer-visible result of the search investigation.

### 🎯 Learning outcomes

By the end of this session, you will be able to:

- Identify upgrade, security, cloud-readiness, and database-connection risks from a prepared application-estate assessment.
- Start a rulebook-guided modernization plan and execution with GitHub Copilot, then review and test prepared .NET results for database-access changes, personal-data masking, and compatibility, recording what remains unverified.
- Use Azure SRE Agent to investigate a customer-visible failure and verify recovery, schedule a read-only cost review, and create a live traffic-and-health report.

### 💻 Technologies used

- GitHub Copilot and the `modernize` CLI
- Visual Studio Code and PowerShell
- .NET 10 and ASP.NET Core
- `Microsoft.Data.SqlClient` and managed identity for application-side database access
- Azure Container Apps (modernization target)
- Azure SRE Agent
- Azure App Service
- Application Insights and Log Analytics

### 📚 Continue your learning

Pick your next step based on your learning style:

| Resource | What you'll get |
|----------|-----------------|
| **[Ignite 2026 Next Steps](https://aka.ms/ignite26-next-steps)** | Additional session repos and materials from Microsoft Ignite 2026 |
| **[Microsoft AI Skills Navigator](https://aka.ms/ignite26-asn)** | Discover AI skills, learning paths, and resources for your next step |
| **[Microsoft Learn](https://aka.ms/ignite26-learn)** | Official documentation and guided learning paths on these topics |
| **[Microsoft Foundry Community](https://aka.ms/MicrosoftFoundryDiscord-Ignite26)** | Connect with other learners and experts in our Discord community |

### 🌟 Microsoft Learn MCP Server

This optional integration is for your own projects after the lab. It is not required for these exercises; do not install it in the assigned lab VM.

The Microsoft Learn MCP Server gives your AI agent direct access to Microsoft's official documentation — grounded, up-to-date answers about the topics in this session.

**GitHub Copilot CLI** — Install with:

```shell
copilot plugin install microsoftdocs/mcp
```

**VS Code** — One-click install:  
[![Install in VS Code](https://img.shields.io/badge/VS_Code-Install_Microsoft_Learn_MCP-0098FF?style=flat-square&logo=visualstudiocode&logoColor=white)](https://vscode.dev/redirect/mcp/install?name=microsoft-learn&config=%7B%22type%22%3A%22http%22%2C%22url%22%3A%22https%3A%2F%2Flearn.microsoft.com%2Fapi%2Fmcp%22%7D)

For more information, visit the [Learn MCP Server repo](https://aka.ms/learnmcp).

### 👥 Content owners

<table>
<tr>
    <td align="center"><a href="https://github.com/ayangupt">
        <img src="https://avatars.githubusercontent.com/u/74832088?v=4" width="100px;" alt="Ayan Gupta"/><br />
        <sub><b>Ayan Gupta</b></sub></a><br />
        <sub>GitHub Copilot modernization</sub>
    </td>
    <td align="center"><a href="https://github.com/meetshamir">
        <img src="https://avatars.githubusercontent.com/u/6728631?v=4" width="100px;" alt="Shamir Abdul Aziz"/><br />
        <sub><b>Shamir Abdul Aziz</b></sub></a><br />
        <sub>Azure SRE Agent</sub>
    </td>
</tr></table>

### ⚖️ Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft trademarks or logos is subject to and must follow [Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/legal/intellectualproperty/trademarks/usage/general). Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.

Any use of third-party trademarks or logos are subject to those third-party's policies.
