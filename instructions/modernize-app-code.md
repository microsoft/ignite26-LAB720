# Modernize application code with GitHub Copilot

Read an application assessment, start a rulebook-guided modernization, and check the result rather than trusting a successful agent response.

| Stage | Time | Your result |
|---|---|---|
| Assess | 8 minutes | Identify the sign-in provider and its database risks |
| Plan | 12 minutes | Load shared rules, start a plan, and review the prepared plan |
| Execute and verify | 25 minutes | Start execution and check prepared code, tests, and routes |

This is the **45-minute .NET track** for **Caldova Bank**. Under **C:\lab\caldova\modules**, each exercise has a **start** folder (before) and a **finish** folder (prepared after). A separate **final\dotnet** snapshot shows the validated three-application end state. Do not replace the deliberately flawed **finish** review example with **final**.

Start the slow agent work, then inspect the prepared result instead of waiting. Keep a short notes file: distinguish **my run**, **prepared example**, **pending**, and **not run**.

**Separate workloads:** Caldova Bank is not Caldova Retail Co. in the later SRE Agent module. Reuse the assigned VM and accounts, but follow each module's repositories and resource names.

---

## Get ready

Continue in the assigned VM after **Start > GitHub and Copilot** in the lab manual. If Windows asks you to sign in again, use the VM controls on **Resources**.

1. Open **Windows Terminal > PowerShell inside the VM** and check:

   ```powershell
   gh auth status
   Test-Path C:\lab\caldova\modules\module-01-assess\start
   modernize --version
   ```

2. Only if GitHub CLI is signed out, keep the lab's Enterprise SSO page open in the VM browser and run:

   ```powershell
   gh auth login
   ```

   Use the arrow keys to move and **Enter** to confirm. Choose **GitHub.com > Login with a web browser**, complete the one-time-code prompt, and authorize the expected GitHub CLI request. The browser, VS Code and GitHub CLI have separate sessions even though they use the same assigned identity.
3. Use **Auto** in VS Code. Every Modernize command below also passes **--model auto**; the VS Code model picker does not set the CLI model.

**Command entry:** Focus the PowerShell prompt inside the VM before using Skillable's **Type** button or pasting. Wait until the whole command appears, then press **Enter inside the VM**. For a multiline-paste warning, check the text and select **Paste anyway** only for the expected lab command. Trust only the supplied lab workspace when VS Code asks.

**Before you continue:** The folder check returns **True**, **gh auth status** succeeds, and the CLI is available. If a tool or folder is missing, ask the facilitator; do not install software, change permissions or switch to a personal account.

---

## 1. Read the assessment

**Step 1 of 6 - About 8 minutes**

Identify the **provider** (the service other applications call) before its **consumer** (the application that depends on it). Here, CaldovaLoanPortal signs in through CaldovaAuthGateway.

1. Inspect the supplied inputs:

   ```powershell
   cd C:\lab\caldova\modules\module-01-assess\start
   Get-Content .github\modernize\repos-live.json
   Get-Content .github\modernize\assess-config.yaml
   ```

   These inputs select the gateway and target .NET 10 on Azure Container Apps with Full analysis. The prepared portfolio is an earlier estate-wide report, not output from these current inputs. **Do not run a new assessment in this shortened lab.**

2. In File Explorer, open:

   ```plaintext
   C:\lab\caldova\modules\module-01-assess\start\.github\modernize\assessment-prebuilt
   ```

   Open the actual **reports-...** folder (its name ends with a timestamp), then **index.html**. If Windows asks which app to use, select **Microsoft Edge > Just once**.

3. Review the portfolio, then open **repos\ZavaAuthGateway** inside that report folder. The historical **Zava** names correspond to the **Caldova** applications in your working folders; do not rename the report files.
4. Open **facts\data-architecture.md** and **facts\configuration-inventory.md** there. Find **System.Data.SqlClient**, SQL-login settings (**DB_USER** and **DB_PASSWORD**), and certificate-validation settings.

These are application-code findings, **not a live database assessment**. An inferred data model does not prove that tables or seed data exist, that a connection works, or that a migration completed. Use the facts and source when a topology graph omits a relationship.

**Before you continue:** Note why the gateway comes first and two database-connection risks its plan must address.

---

## 2. Use the shared rulebook and add the PII skill

**Step 2 of 6 - About 4 minutes**

A **rulebook** tells the agent **what** standards to meet. A **skill** describes **how** to perform a task. The PII-masking skill keeps personally identifiable information, such as customer names and account numbers, out of logs.

All learners use the same [Caldova workshop rulebook](https://github.com/ayangupt/ignite26-caldova-rulebook). **Do not create a personal rulebook repository.** Its charter, policies and targets are teaching examples, not Microsoft production policy.

1. Open the planning workspace:

   ```powershell
   cd C:\lab\caldova\modules\module-02-plan\start
   code .
   Get-Content .github\modernize\config.json
   ```

2. Skim the local reading copies in the **rulebook** folder: **charter.md**, **policies.md** and **targets.md**. In the configuration, confirm that **feature_flags.rulebook** is **true** and that **portfolio_url** is **https://github.com/ayangupt/ignite26-caldova-rulebook**. Do not type or paste these values into a terminal.

   The config must be in the **working directory where Modernize starts**. These exercises run it from the module root. A VS Code/app-root launch needs its own supplied configuration. A local **rulebook** folder alone does not demonstrate native loading.

3. If the gateway already has **.github > skills > pii-masking**, inspect its **SKILL.md** instead of making a nested copy. Otherwise, copy the PII skill once from the planning module root:

   ```powershell
   New-Item -ItemType Directory -Force -Path apps\CaldovaAuthGateway\.github\skills | Out-Null
   Copy-Item skills\pii-masking apps\CaldovaAuthGateway\.github\skills\ -Recurse
   ```

**Before you continue:** You can distinguish the shared rules from the PII skill, and the config points to the shared repository. If config/access is missing, ask the facilitator and use the prepared-plan review in step 3, item 4; record live planning/execution as **not run**. Do not substitute a local folder or invent a URL.

---

## 3. Start the plan, then review the prepared plan

**Step 3 of 6 - About 8 minutes**

Start a live gateway plan, then use the prepared plan while it runs.

1. In PowerShell, copy the supplied goal and open the CLI:

   ```powershell
   cd C:\lab\caldova\modules\module-02-plan\start
   Get-Content goals\dotnet.txt -Raw | Set-Clipboard
   modernize --model auto
   ```

2. Select **Plan > Create modernization plan > Keep the plan local**. When asked for the repository, select **CaldovaAuthGateway**; if a path is requested, use:

   ```plaintext
   C:\lab\caldova\modules\module-02-plan\start\apps\CaldovaAuthGateway
   ```

   Replace the default plan name with **caldova-dotnet-modernization**. At the goal prompt, press **Ctrl+V** to paste the goal. Answer clarifying questions using the shared rules; do not accept provisioning or deployment.

3. Look for **Rulebook loaded (3 files)**, then leave the run open. When a live plan finishes, its folder should also contain **rulebook-compliance.md** and **.metadata\rulebook-metadata.json**; check the metadata's source URL. The loading message is evidence that the CLI read the rules, not that the resulting code complies.

![CLI reports SUCCESS: Rulebook loaded (3 files)](../img/modernization/caldova-rulebook-loaded.png)

*Expected CLI message: **SUCCESS: Rulebook loaded (3 files)**.*

4. In **another PowerShell terminal**, select the prepared branch before opening the example:

   ```powershell
   cd C:\lab\caldova\modules\module-03-execute\start
   git switch modernization/dotnet
   code apps\CaldovaAuthGateway
   ```

   In Explorer, open **.github > modernize > caldova-dotnet-modernization > plan.md** and use **Open Preview**. Open **.metadata\tasks.json** and any supplied **rulebook-compliance.md** alongside it. The prepared plan is on the **modernization/dotnet** branch, not **main**; its reports describe a rehearsal, not today's execution. If a report is missing, record that gap rather than create substitute evidence.

![1: Open plan.md and its compliance report. 2: Find the .NET 10 target. 3: Check managed-identity database access.](../img/guide-annotations/annotated/caldova-plan-review-annotated-bca49df6c11b.png)

*1. Open the plan and compliance report. 2. Find the .NET 10 target. 3. Check the managed-identity requirement.*

5. Match the rules to tasks: .NET 10; managed-identity database access; validated TLS; no PII in logs; supported libraries; compatible public routes including **/WhoAmI.ashx**; health checks and a compliant Dockerfile.

**Before you continue:** You can explain how the plan covers the rules and where the PII skill is used. If the live plan is slow, record **pending** and continue. If native loading fails, stop that run, tell the facilitator and review the prepared results instead.

---

## 4. Start the prepared execution

**Step 4 of 6 - About 3 minutes**

Run the remaining gateway tasks from the separate execution workspace, not from your still-running plan.

1. If your live planning run is still active, stop it with **Ctrl+C** in its own terminal. In the execution terminal:

   ```powershell
   cd C:\lab\caldova\modules\module-03-execute\start
   git switch modernization/dotnet
   git --no-pager log --oneline
   Get-Content .github\modernize\config.json
   ```

2. Confirm this working directory has the same shared-rulebook settings from step 2. In the gateway plan's **.metadata\tasks.json**, the runtime-upgrade and Web Forms-conversion tasks should already show a status of **success**. They are **prepared starting state**, not work you just performed.

![1: Locate .metadata/tasks.json. 2: Task 001 runtime upgrade has status success. 3: Task 002 Web Forms conversion has status success.](../img/guide-annotations/annotated/caldova-task-states-annotated-918df22654f4.png)

*1. Locate **tasks.json**. 2-3. Confirm **success** for the runtime upgrade and Web Forms conversion.*

3. Use the CLI route below for this shortened lab; do not start a second IDE execution:

   ```powershell
   modernize plan execute "Execute all remaining tasks, starting with the first unfinished task. Do not stop after one task. Do not run the deployment task, provision resources, grant access, push changes or install tools." `
     --plan-name caldova-dotnet-modernization `
     --source "$PWD\apps\CaldovaAuthGateway" `
     --model auto `
     --no-tty
   ```

**Before you continue:** Check for **Rulebook loaded (3 files)** in this execution too. If it is absent, stop and ask the facilitator; do not assume the planning workspace's settings carried over. Otherwise leave the terminal running and move on **without waiting**. If task states or tools differ, use the prepared review and mark execution **not run**.

---

## 5. Review a finished application

**Step 5 of 6 - About 10 minutes**

Inspect the prepared result for faults that a successful build or agent response would miss.

1. Leave any live execution running and open another PowerShell terminal:

   ```powershell
   cd C:\lab\caldova\modules\module-03-execute\finish
   git switch modernization/dotnet
   git --no-pager diff --stat main -- apps/CaldovaLoanPortal
   ```

2. Find the ASP.NET Core replacement for the old Web Forms code. Compare its database settings and public routes with the rulebook.
3. Identify two gaps: the portal's legacy **FROM mono:6.12** base image, and how it recognizes users through the gateway's **/WhoAmI.ashx** response. A green build does not prove this sign-in contract works.
4. Spend about four minutes on the **separate** final state:

   ```powershell
   code C:\lab\caldova\modules\module-03-execute\final\dotnet
   ```

   Confirm the three apps target .NET 10; compare the portal's Microsoft-based, non-root Dockerfile; and read **VALIDATION.md**. This frozen snapshot's evidence is not output from your current agent run. Do not rerun its full SQL-backed suite, rebuild containers or deploy during this lab.

**Before you continue:** Note the review gaps and how the final snapshot addresses them. Keep Azure access, signed-in behavior and any new-rulebook execution separate from that historical evidence. Do not overwrite **finish** with **final**.

---

## 6. Validate the provider

**Step 6 of 6 - About 12 minutes**

Build, test and run the **prepared gateway** locally. Apply the same checks to your live result only if it finishes.

1. Build and run the concrete test project:

   ```powershell
   cd C:\lab\caldova\modules\module-03-execute\finish\apps\CaldovaAuthGateway
   dotnet build
   dotnet test Tests\CaldovaAuthGateway.Tests.csproj
   ```

![1: Build succeeded. 2: The test summary shows zero failed tests and 13 succeeded.](../img/guide-annotations/annotated/caldova-build-tests-annotated-1225a17c2c50.png)

*1. Look for **Build succeeded**. 2. Check **failed: 0** in the test summary.*

2. Inspect the code for an SDK-style .NET 10 project; **Microsoft.Data.SqlClient** with identity-based authentication and validated TLS; structured logs using PII masking; and preserved public routes.
3. Run without a database, using local-only placeholders:

   ```powershell
   $env:DB_HOST = 'localhost'
   $env:DB_NAME = 'CaldovaBankDB'
   $env:APPLICATIONINSIGHTS_CONNECTION_STRING = 'InstrumentationKey=00000000-0000-0000-0000-000000000000;IngestionEndpoint=http://localhost/'
   dotnet run
   ```

4. In another terminal, check:

   ```powershell
   curl.exe -i http://localhost:8080/health
   curl.exe -i http://localhost:8080/WhoAmI.ashx
   ```

   Expect HTTP 200 and the response **{"authenticated":false}** from **/WhoAmI.ashx**. Stop the app with **Ctrl+C** in its server terminal.

![1: The health response is OK with HTTP 200. 2: WhoAmI returns authenticated false with HTTP 200.](../img/guide-annotations/annotated/caldova-local-routes-annotated-bf363029221e.png)

*1. **/health**: HTTP 200 and **OK**. 2. **/WhoAmI.ashx**: HTTP 200 and **{"authenticated":false}**.*

5. If your live execution finished, repeat the checks in its gateway under **module-03-execute\start**. If it is still running, record **pending**; if skipped, record **not run**. Do not launch a duplicate.

**Before you continue:** Record your build/test and route results separately from prepared evidence. These routes do not test database-backed login or Azure telemetry delivery. The VM, Azure and TAP credentials are **not application test-user credentials**. Missing DB/app-login inputs mean **not verified**, not an invitation to guess credentials or create resources.

---

## Finish

In your notes, answer:

- Why did the sign-in provider come before its consumer?
- Which rules and skill guided the plan, and where did you see native loading?
- What did you personally verify, what came from prepared examples, and what remains pending or not run?

If you used the review-only fallback, say so; it does not complete the live hands-on outcomes. Stop local app servers, leave unfinished agent work identified, and follow the facilitator's handoff. Do not reset the shared lab.

**Continue to [Automate operations with Azure SRE Agent](sre-agent.md)** or **SRE Agent** in the full lab manual, using its own workload and resources.

### If something did not work

| Symptom | Next action |
|---|---|
| Lab folder or tool missing | Ask the facilitator; do not install or use personal access |
| CLI rejects the model | Confirm the command includes **--model auto**; VS Code's picker is separate |
| Rulebook not loaded | Check the actual working-directory config, shared URL and **gh auth status**; stop live work and ask the facilitator |
| Agent takes too long | Review the prepared result and record your run as pending |
| Git output fills the terminal | Press **q** if a pager opened; use the documented **--no-pager** commands |
| Build passes but login fails | Inspect the gateway/portal contract and required DB/app-user setup |

### Reference: CLI alternatives

These are **not additional required runs**. Do not run them alongside an existing assessment or plan.

For a new assessment outside the shortened flow:

```powershell
cd C:\lab\caldova\modules\module-01-assess\start
modernize assess `
  --source "$PWD\.github\modernize\repos-live.json" `
  --assess-config "$PWD\.github\modernize\assess-config.yaml" `
  --output-path "$PWD\.github\modernize\assessment" `
  --model auto `
  --no-tty
```

For planning without the interactive menus:

```powershell
cd C:\lab\caldova\modules\module-02-plan\start
modernize plan create (Get-Content goals\dotnet.txt -Raw) `
  --source "$PWD\apps\CaldovaAuthGateway" `
  --plan-name caldova-dotnet-modernization `
  --language dotnet `
  --model auto `
  --no-tty
```

The shared workshop rulebook baseline is **1.0**, commit **5564f81d46c25830910e44dea27a32f32720dabc**. Rulebook publication and loading do not establish application compliance.

The full PREL38 pre-day lab includes the live assessment and Java alternative; neither is an extra task in this .NET-only section.
