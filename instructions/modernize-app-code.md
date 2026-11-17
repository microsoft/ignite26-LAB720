# Modernize application code with GitHub Copilot

Read an application assessment, start a rulebook-guided modernization, and check the result rather than trusting a successful agent response.

| Stage | Time | Your result |
|---|---|---|
| Setup and transitions | 5 minutes | Confirm sign-in and tools; allow for switching workspaces |
| Assess | 8 minutes | Identify the sign-in provider and its database risks |
| Plan | 17 minutes | Configure the rules and skill, work through live planning, and review the plan |
| Execute and verify | 20 minutes | Start execution and check prepared code, tests, and routes |

This is the **50-minute .NET track** for **Caldova Bank**. Under **C:\lab\caldova\modules**, each exercise has a **start** folder (before) and a **finish** folder (prepared after). A separate **final\dotnet** snapshot shows the validated three-application end state. Do not replace the deliberately flawed **finish** review example with **final**.

Work through live planning, including the agent's questions and the plan review. To fit the session, execution starts from a prepared checkpoint; review and validate the supplied code without waiting for that execution to finish. If planning exceeds its time allocation, use the prepared plan for review instead.

Results from your live runs and prepared examples are separate evidence. An unfinished run is **pending**; a skipped or blocked operation is **not run**. If a run fails, inspect the error rather than treating it as success.

**Separate workloads:** Caldova Bank is not Caldova Retail Co. in the later SRE Agent module. Reuse the assigned VM and accounts, but follow each module's repositories and resource names.

---

## Get ready

Continue in the assigned VM after **Start > GitHub and Copilot** in the lab manual. If Windows asks you to sign in again, use the VM controls on **Resources**.

### Check sign-in and tools

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

### Enter commands

Focus the PowerShell prompt inside the VM before using Skillable's **Type** button or pasting. Wait until the whole command appears, then press **Enter inside the VM**. For a multiline-paste warning, check the text and select **Paste anyway** only for the expected lab command. Trust only the supplied lab workspace when VS Code asks.

**Continue when:** The folder check returns **True**, **gh auth status** succeeds, and the CLI is available. If a tool or folder is missing, ask the facilitator; do not install software, change permissions or switch to a personal account.

---

## 1. Read the assessment

**Step 1 of 6 - About 8 minutes**

**Prepared assessment**

Identify the **provider** (the service other applications call) before its **consumer** (the application that depends on it). Here, CaldovaLoanPortal signs in through CaldovaAuthGateway.

Normally, you run **modernize assess** to generate an assessment report before planning. **To fit the lab time, open the precreated assessment report instead.** Do not run a new assessment or change the assessment inputs during this lab. The assessment command is included under **Reference: CLI alternatives** for use outside this shortened flow.

### Open the assessment

1. In File Explorer, open the precreated report folder:

   ```plaintext
   C:\lab\caldova\modules\module-01-assess\start\.github\modernize\assessment-prebuilt
   ```

2. Open the actual **reports-...** folder (its name ends with a timestamp), then **index.html**. If Windows asks which app to use, select **Microsoft Edge > Just once**. This portfolio is a prepared estate-wide report, not output from your current session.

### Inspect the gateway's database risks

1. Review the portfolio, then open **repos\CaldovaAuthGateway** inside that report folder.
2. Open **facts\data-architecture.md** and **facts\configuration-inventory.md** there. Find **System.Data.SqlClient**, SQL-login settings (**DB_USER** and **DB_PASSWORD**), and certificate-validation settings.

These are application-code findings, **not a live database assessment**. An inferred data model does not prove that tables or seed data exist, that a connection works, or that a migration completed.

The gateway is the sign-in provider. Its plan needs to address the SQL client, database authentication, and certificate-validation risks identified above.

---

## 2. Configure the rulebook and add the PII skill

**Step 2 of 6 - About 4 minutes**

**Planning setup**

A **rulebook** tells the agent **what** standards to meet. A **skill** describes **how** to perform a task. The PII-masking skill keeps personally identifiable information, such as customer names and account numbers, out of logs.

All learners use the same [Caldova workshop rulebook](https://github.com/ayangupt/ignite26-caldova-rulebook). **Do not create a personal rulebook repository.** Its charter, policies and targets are teaching examples, not Microsoft production policy.

### Check the shared-rulebook configuration

1. In PowerShell, open the planning workspace. This will be your **Planning** terminal:

   ```powershell
   cd C:\lab\caldova\modules\module-02-plan\start
   code .
   Get-Content .github\modernize\config.json
   ```

2. Skim the local reading copies in the **rulebook** folder: **charter.md**, **policies.md** and **targets.md**. In the configuration, confirm that **feature_flags.rulebook** is **true** and that **portfolio_url** is **https://github.com/ayangupt/ignite26-caldova-rulebook**. Do not type or paste these values into a terminal.

   The config must be in the **working directory where Modernize starts**. These exercises run it from the module root. A VS Code/app-root launch needs its own supplied configuration. A local **rulebook** folder alone does not demonstrate native loading.

### Add the PII-masking skill

Copy the PII skill into the gateway. The command skips the copy if the skill is already there:

```powershell
$skills = 'apps\CaldovaAuthGateway\.github\skills'
New-Item -ItemType Directory -Force $skills | Out-Null
if (-not (Test-Path "$skills\pii-masking")) { Copy-Item skills\pii-masking $skills -Recurse }
Get-ChildItem "$skills\pii-masking"
```

The list should include **SKILL.md**. Open it in VS Code to see what the skill asks the agent to do.

**If config or access is missing:** Ask the facilitator and use **Step 3 - Review the plan** to open the prepared plan. Live operations that cannot start are **not run**. Do not substitute a local folder or invent a URL.

---

## 3. Create and review the plan

**Step 3 of 6 - About 13 minutes**

**Live planning**

Allow up to about **10 minutes for live planning**, including the questions, and use the remaining time to review the plan. Stay with the **Planning** terminal: generation pauses when the agent needs an answer.

### Start planning

1. In the **Planning** terminal, open the interactive CLI:

   ```powershell
   cd C:\lab\caldova\modules\module-02-plan\start
   modernize --model auto
   ```

2. If prompted, trust the supplied lab folder. Use the arrow keys and **Enter** to select **Plan**, then **Manual input** for the target repository. Enter only the provider path:

   ```plaintext
   C:\lab\caldova\modules\module-02-plan\start\apps\CaldovaAuthGateway
   ```

3. Confirm only **CaldovaAuthGateway** is selected (**1/1**), then choose **Keep the plan local**. Do not submit to the Cloud Coding Agent.
4. On **Create modernization plan**, select **Plan name** and replace the default with **caldova-dotnet-modernization**. Return to **Type your own prompt**.
5. With the goal field ready, open another PowerShell tab (**+**) and copy the supplied goal with local-only limits:

   ```powershell
   cd C:\lab\caldova\modules\module-02-plan\start
   $goal = Get-Content goals\dotnet.txt -Raw
   $goal += ' Keep the plan local. Do not deploy, provision resources, grant access, push changes or install tools.'
   $goal | Set-Clipboard
   ```

6. Return to the **Planning** terminal, press **Ctrl+V** to paste the goal, then press **Enter**. Keep the other terminal for plan review.

### Confirm rulebook loading

After submitting the goal, look for **SUCCESS: Rulebook loaded (3 files)**. It appears during planning, not when you inspect the configuration in step 2. If a question appears, answer it against the rulebook rather than leaving the planner paused.

![CLI reports SUCCESS: Rulebook loaded (3 files)](../img/modernization/caldova-rulebook-loaded.png)

*Expected output after planning starts: **SUCCESS: Rulebook loaded (3 files)**.*

The message confirms that the CLI read the shared rules; it does not mean the plan is complete or that the plan/code complies. A delayed message is not itself a loading error.

**If the command fails:** Inspect the error and tell the facilitator. If native loading fails while the run remains active, stop that run. Use the prepared plan below; do not claim a successful live plan. HTTP 403 or another Copilot access error means live work is blocked, not an invitation to switch accounts.

### Answer questions and confirm the plan

1. Answer the planner's clarifying questions using the shared rules. Choose a recommended option only if it agrees with those rules. Do not approve deployment, provisioning, access changes, pushes, or tool installation.
2. At **Summary for confirmation**, review the summary and confirm it only if it matches the goal and rulebook.
3. Wait within the time allocation for **SUCCESS: Rulebook compliance report: ...rulebook-compliance.md** and the **How would you like to continue?** menu.
4. Select **Return to main menu**, then **Esc** to return to PowerShell. **Do not accept the default Execute modernization plan option.** Step 4 uses a separate prepared checkpoint.

**If planning exceeds the timebox:** Check for an unanswered question; do not mistake a paused prompt for active generation. Answer it against the rulebook if possible, then leave unfinished planning open and review the prepared plan below. Do not wait beyond the allocation. If planning is still active when you reach step 4, skip live execution and continue with prepared review and validation; live execution is **not run**. You can check the planning result near the end.

### Review the plan

Use the idle terminal where you copied the goal, or open a PowerShell tab (**+**) if planning was skipped. Do not enter commands in the busy **Planning** terminal. Choose **one** folder:

**If your live plan completed**, open its gateway:

```powershell
code C:\lab\caldova\modules\module-02-plan\start\apps\CaldovaAuthGateway
```

**If planning is unfinished or unavailable**, open the prepared gateway plan:

```powershell
code C:\lab\caldova\modules\module-03-execute\start\apps\CaldovaAuthGateway
```

1. In the VS Code **Explorer**, open **.github > modernize > caldova-dotnet-modernization > plan.md** and use **Open Preview** (**Ctrl+Shift+V**). Open **.metadata\tasks.json** and the supplied **rulebook-compliance.md** alongside it.
2. For a completed live plan, inspect **.metadata\rulebook-metadata.json** and confirm its source URL is the shared rulebook. Prepared reports describe a rehearsal, not your run.

![1: Open plan.md and its compliance report. 2: Find the .NET 10 target. 3: Check managed-identity database access.](../img/guide-annotations/annotated/caldova-plan-review-annotated-bca49df6c11b.png)

*Prepared example: open the plan and compliance report, then find the .NET 10 target and managed-identity requirement. Your live plan may be worded differently.*

3. Match the rules to tasks: .NET 10; managed-identity database access; validated TLS; no PII in logs; supported libraries; compatible public routes including **/WhoAmI.ashx**; health checks and a compliant Dockerfile. Find **pii-masking** on the logging task. Inspect gaps rather than treating the loading message as proof of coverage.

---

## 4. Start the prepared execution

**Step 4 of 6 - About 3 minutes**

**Live execution from a prepared checkpoint**

Execution uses the supplied plan and task state in **module-03-execute\start**, not your live plan in **module-02-plan\start**. Do not copy your plan between the folders.

### Open the execution workspace

Use the idle review terminal, or open a new PowerShell tab (**+**), as your **Execution** terminal. Open this workspace even if you reviewed your live plan:

```powershell
cd C:\lab\caldova\modules\module-03-execute\start
Get-Content .github\modernize\config.json
code apps\CaldovaAuthGateway
```

### Check the prepared task state and configuration

1. Confirm this working directory has the same shared-rulebook settings from step 2.
2. In the VS Code window for this **execution** gateway, open **.github > modernize > caldova-dotnet-modernization > .metadata > tasks.json**. The runtime-upgrade and Web Forms-conversion tasks should already show **"status": "success"**. They are **prepared starting state**, not work you just performed.

![1: Locate .metadata/tasks.json. 2: Task 001 runtime upgrade has status success. 3: Task 002 Web Forms conversion has status success.](../img/guide-annotations/annotated/caldova-task-states-annotated-918df22654f4.png)

*1. Locate **tasks.json**. 2-3. Confirm **success** for the runtime upgrade and Web Forms conversion.*

**If settings, task states, or tools differ:** Ask the facilitator, do not start execution, and continue to step 5. Execution is **not run**.

### Start execution and confirm rulebook loading

**Before starting:** Check the **Planning** terminal. If its run is still generating or awaiting input, leave it open and skip the command below. Also skip execution if Copilot access or rulebook loading remains blocked. Continue to step 5 with live execution **not run**.

Otherwise, start the prepared execution in the **Execution** terminal. Use this command rather than starting a second run from VS Code:

```powershell
modernize plan execute "Execute all remaining tasks, starting with the first unfinished task. Do not stop after one task. Do not run the deployment task, provision resources, grant access, push changes or install tools." `
  --plan-name caldova-dotnet-modernization `
  --source "$PWD\apps\CaldovaAuthGateway" `
  --model auto `
  --no-tty
```

Look for **Rulebook loaded (3 files)** in this execution too; the planning workspace's successful load does not verify this run's settings.

**Continue when:** The message appears and execution is underway. Leave the terminal running and move to step 5 **without waiting for tasks to finish**.

**If the message is delayed:** At the end of this step's three-minute allocation, continue to the prepared review with execution **pending** and loading unconfirmed. Do not start a duplicate. If an actual loading/access error appears, inspect it, stop that run if still active, and ask the facilitator; use the prepared review instead.

---

## 5. Review the prepared code

**Step 5 of 6 - About 7 minutes**

**Prepared portal and final comparison**

Inspect the prepared result for faults that a successful build or agent response would miss. This portal review does not depend on gateway execution finishing; provider-first modernization still applies.

### Inspect the prepared portal

1. Leave any live execution running. Open another PowerShell tab (**+**) as your **Validation** terminal:

   ```powershell
   cd C:\lab\caldova\modules\module-03-execute\finish
   code apps\CaldovaLoanPortal
   ```

   The prepared result is already in this local folder; no Git commands are needed.

2. Find the ASP.NET Core replacement for the old Web Forms code. Compare its database settings and public routes with the rulebook.
3. Press **Ctrl+Shift+F** in VS Code and inspect these review targets:

   - **mono:6.12**: the portal's Dockerfile still uses the legacy **FROM mono:6.12** base image.
   - **WhoAmI.ashx**: how the portal recognizes users through the gateway's **/WhoAmI.ashx** response. A green build does not prove this sign-in contract works.

### Compare with the final snapshot

Spend about two minutes on the **separate** final state:

```powershell
code C:\lab\caldova\modules\module-03-execute\final\dotnet
```

Confirm the three apps target .NET 10; compare the portal's Microsoft-based, non-root Dockerfile; and read **VALIDATION.md**. Compare the review gaps with the fixes in this final snapshot.

This frozen snapshot's evidence is not output from your live execution. Keep Azure access and signed-in behavior separate from that historical evidence. Do not rerun its full SQL-backed suite, rebuild containers, deploy, or overwrite **finish** with **final**.

---

## 6. Validate the prepared gateway

**Step 6 of 6 - About 10 minutes**

**Prepared-code validation**

Build, test and run the **prepared gateway** locally. Apply the same checks to your live result only if it finishes.

### Build, test, and inspect the gateway

In the **Validation** terminal, build and run the test project:

```powershell
cd C:\lab\caldova\modules\module-03-execute\finish\apps\CaldovaAuthGateway
dotnet build
dotnet test Tests\CaldovaAuthGateway.Tests.csproj
```

Wait for both results. If either fails, inspect the error and ask the facilitator before starting the app.

![1: Build succeeded. 2: The test summary shows zero failed tests and 13 succeeded.](../img/guide-annotations/annotated/caldova-build-tests-annotated-1225a17c2c50.png)

*1. Look for **Build succeeded**. 2. Check **failed: 0** in the test summary.*

Inspect the code for an SDK-style .NET 10 project; **Microsoft.Data.SqlClient** with identity-based authentication and validated TLS (**the risks identified in step 1**); structured logs using PII masking; and preserved public routes.

### Start the gateway

In the same **Validation** terminal, start the app without a database, using local-only placeholders:

```powershell
$env:DB_HOST = 'localhost'
$env:DB_NAME = 'CaldovaBankDB'
$env:APPLICATIONINSIGHTS_CONNECTION_STRING = 'InstrumentationKey=00000000-0000-0000-0000-000000000000;IngestionEndpoint=http://localhost/'
dotnet run
```

**Continue when:** This terminal reports that the app is listening on **port 8080** and the process stays running. Do not wait for **dotnet run** to finish; the server must remain available for the requests.

**If the app exits or port 8080 is already in use:** Do not count responses from another process as this app's results. Ask the facilitator; do not terminate an unknown process.

### Check the local routes

Once the prepared server is ready, open another PowerShell tab (**+**) as your **Route checks** terminal:

```powershell
curl.exe -i http://localhost:8080/health
curl.exe -i http://localhost:8080/WhoAmI.ashx
```

Expect HTTP 200 from both, and **{"authenticated":false}** from **/WhoAmI.ashx**. Then return to the **Validation** terminal and press **Ctrl+C** to stop this app.

![1: The health response is OK with HTTP 200. 2: WhoAmI returns authenticated false with HTTP 200.](../img/guide-annotations/annotated/caldova-local-routes-annotated-bf363029221e.png)

*1. **/health**: HTTP 200 and **OK**. 2. **/WhoAmI.ashx**: HTTP 200 and **{"authenticated":false}**.*

These checks validate the prepared gateway, not your live execution, database-backed login, or Azure telemetry delivery. The VM, Azure and TAP credentials are **not application test-user credentials**. Missing DB/app-login inputs mean **not verified**, not an invitation to guess credentials or create resources.

### Check completed live results, if time permits

If planning was unfinished in step 3 and has now completed, return to its **Planning** terminal. Choose **Return to main menu**, not **Execute**, then review its files using **Step 3 - Review the plan**.

If live execution has finished, inspect its outcome and task status first; an exited command can have failed. Once the agent is no longer changing files and the prepared server is stopped, repeat the build and tests in the live gateway:

```powershell
cd C:\lab\caldova\modules\module-03-execute\start\apps\CaldovaAuthGateway
dotnet build
dotnet test Tests\CaldovaAuthGateway.Tests.csproj
```

Use the **Validation** terminal, then follow **Start the gateway** and **Check the local routes** above from this folder. Keep these results separate from the prepared example.

If a live run is still active, it remains **pending**; if skipped, it is **not run**. Do not wait beyond the session or launch a duplicate.

---

## Finish

Using prepared artifacts for review and validation is the intended shortened flow, not proof that your live upgrade finished. Check any completed live results separately; unfinished work remains **pending**, and skipped operations are **not run**.

Stop the local app server when finished, leave any unfinished agent work identified, and follow the facilitator's handoff. Do not reset the shared lab.

**Continue to [Automate operations with Azure SRE Agent](sre-agent.md)** or **SRE Agent** in the full lab manual, using its own workload and resources.

### If something did not work

| Symptom | Next action |
|---|---|
| Lab folder or tool missing | Ask the facilitator; do not install or use personal access |
| CLI rejects the model | Confirm the command includes **--model auto**; VS Code's picker is separate |
| Rulebook-loading error | Check the actual working-directory config, shared URL and **gh auth status**; stop the affected run if still active and ask the facilitator |
| Planner appears idle | Check for an unanswered question in the **Planning** terminal; follow the rulebook rather than leaving the prompt paused |
| Planning exceeds its timebox | Use the prepared plan. Leave unfinished planning open; if still active at step 4, skip live execution and continue to prepared review |
| Execution takes too long | Leave it running and use the prepared review and validation; unfinished execution is **pending** |
| Local app cannot bind port 8080 | Do not treat another process's responses as this app's results; ask the facilitator without terminating an unknown process |
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
$goal = Get-Content goals\dotnet.txt -Raw
$goal += ' Keep the plan local. Do not deploy, provision resources, grant access, push changes or install tools.'
modernize plan create $goal `
  --source "$PWD\apps\CaldovaAuthGateway" `
  --plan-name caldova-dotnet-modernization `
  --language dotnet `
  --model auto `
  --no-tty
```

The shared workshop rulebook baseline is **1.0**, commit **5564f81d46c25830910e44dea27a32f32720dabc**. Rulebook publication and loading do not establish application compliance.

The full PREL38 pre-day lab includes the live assessment and Java alternative; neither is an extra task in this .NET-only section.
