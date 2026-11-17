<a name="start-building"></a>

<p align="center">
<img src="img/banner-ignite-26.png" alt="Microsoft Ignite 2026" width="100%"/>
</p>

# [Microsoft Ignite 2026](https://ignite.microsoft.com)

## 🔥LAB720: Hands-on: Modernize apps and databases and automate operations
### Session description

Get hands-on using AI to modernize applications, database access, and operations. Use GitHub Copilot to review a prepared assessment and start modernizing a .NET app, then inspect prepared results for dependency, containerization, and database-access changes. Then use Azure SRE Agent to investigate incidents, identify root causes, and automate remediation. Leave with practical experience applying AI agents across the modernization and operations lifecycle.

### Lab walkthrough

This 75-minute hands-on lab combines application modernization and operations automation using two separate training workloads in your assigned lab environment. For Caldova Bank, review a prepared assessment, start a rulebook-guided modernization plan and execution with GitHub Copilot, and check prepared .NET results for database-access changes, personal-data masking, and compatibility. For Caldova Retail Co., use Azure SRE Agent to investigate a product-search failure, verify recovery, schedule cost reviews, and create live traffic-and-health reports.

The modernization section uses the shared [Caldova workshop rulebook](https://github.com/ayangupt/ignite26-caldova-rulebook). All learners use the same training baseline; creating an individual rulebook repository is not a prerequisite.

Follow the [modernization guide](instructions/modernize-app-code.md) (50 minutes), then the [SRE Agent guide](instructions/sre-agent.md) (15 minutes). The [attendee instructions](instructions/README.md) index both sections.

### 🚀 Getting started

The exercises require an assigned, prepared lab environment and lab accounts. Cloning this repository does not set up the lab. If the assigned environment, exercise files, or tools are unavailable, ask the facilitator or lab provider rather than installing software, creating replacement resources, or using personal accounts.

#### In a guided session

If you're following along during a live session:

1. Use the participant access details supplied by your facilitator to open the assigned lab environment. Use the **Resources** tab for VM access and assigned account details, and open sign-in pages inside the VM.
2. Follow **Start > GitHub and Copilot** in the lab manual, then open the [modernization guide](instructions/modernize-app-code.md). Follow the facilitator's pacing through live planning, using a prepared plan if it exceeds the timebox. Start execution from the prepared checkpoint, then review and validate prepared code without waiting for execution to finish.
3. Continue to the [SRE Agent guide](instructions/sre-agent.md) or **SRE Agent** in the lab manual. Reuse the assigned VM and accounts, but use that module's Caldova Retail Co. repository and Azure resource names rather than the Caldova Bank workload.

#### On your own

If you're learning at your own pace:

1. Confirm access to the assigned lab environment and complete lab manual with the lab provider. The exercises depend on its VM, prepared files, and assigned GitHub and Azure accounts; repository access alone is not enough.
2. Follow [Modernize application code with GitHub Copilot](instructions/modernize-app-code.md), beginning with **Get ready**. Work through live planning and plan review, then use the prepared execution checkpoint and code for review and validation. Keep live results separate from prepared evidence and identify any checks that remain unverified.
3. Follow [Automate operations with Azure SRE Agent](instructions/sre-agent.md) for the operations exercises. Keep the two workloads separate and verify the customer-visible result of the search investigation.

### 🎯 Learning outcomes

By the end of this session, you will be able to:

- Identify upgrade, security, cloud-readiness, and database-connection risks from a prepared application-estate assessment.
- Start a rulebook-guided modernization plan and execution with GitHub Copilot, then review and test prepared .NET results for database-access changes, personal-data masking, and compatibility, recording what remains unverified.
- Use Azure SRE Agent to investigate a customer-visible failure and verify recovery, schedule a read-only cost review, and create a live traffic-and-health report.

### 💻 Technologies used

- [GitHub Copilot](https://learn.microsoft.com/en-us/azure/developer/github-copilot-app-modernization/) and the [`modernize` CLI](https://learn.microsoft.com/en-us/azure/developer/github-copilot-app-modernization/modernization-agent/cli-commands)
- [Visual Studio Code](https://code.visualstudio.com/docs) and [PowerShell](https://learn.microsoft.com/en-us/powershell/scripting/overview)
- [.NET 10](https://learn.microsoft.com/en-us/dotnet/core/whats-new/dotnet-10/overview) and [ASP.NET Core](https://learn.microsoft.com/en-us/aspnet/core/overview?view=aspnetcore-10.0)
- [`Microsoft.Data.SqlClient`](https://learn.microsoft.com/en-us/sql/connect/ado-net/introduction-microsoft-data-sqlclient-namespace?view=sql-server-ver17) and [managed identity](https://learn.microsoft.com/en-us/sql/connect/ado-net/sql/azure-active-directory-authentication?view=sql-server-ver17) for application-side database access
- [Azure Container Apps](https://learn.microsoft.com/en-us/azure/container-apps/overview) (modernization target)
- [Azure SRE Agent](https://learn.microsoft.com/en-us/azure/sre-agent/overview)
- [Azure App Service](https://learn.microsoft.com/en-us/azure/app-service/overview)
- [Application Insights](https://learn.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview) and [Log Analytics](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/log-analytics-overview)

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
