# Review the public LAB720 final checkpoint

Follow one modernization decision from an assessment finding, through a plan, to the final .NET code. You'll use LAB720's published guide and screenshots, then inspect the three apps and optionally test the gateway on your own machine. This is a **review**, not a live modernization run: the original assessment, editable plan, task history and deliberately flawed `finish` example are not in the public checkpoint.

## Get the checkpoint

Clone this repository or download and extract its source ZIP. If Windows marked the ZIP as downloaded, review the scripts and run `Get-ChildItem .\scripts -File -Recurse | Unblock-File` first. From the repository root, run this in **Windows PowerShell** (included with Windows 11):

```powershell
powershell.exe -NoProfile -ExecutionPolicy RemoteSigned -File .\scripts\review-final.ps1 -TestGateway
```

This downloads and verifies the final checkpoint and runs its gateway tests. `-TestGateway` reuses a stable .NET 10 SDK if available; otherwise it downloads a temporary SDK from Microsoft without administrator access or a permanent PATH change. Allow time and disk space for the SDK and first NuGet restore. The temporary SDK and build outputs are removed afterward; NuGet may keep its normal package cache. **For a read-only review**, omit `-TestGateway`; no SDK or NuGet access is needed. With PowerShell 7 on macOS, Linux or Windows use `pwsh -NoProfile -File ./scripts/review-final.ps1 -TestGateway`.

Open the printed directory (default: `$HOME/lab720-final-review/dotnet`). The script checks the [pinned ZIP](../infra/workload-manifest.json), its manifest and all 84 listed files. To use a previously downloaded ZIP, pass `-FinalArchive` and its path. For a second run, use `-Destination` and a **new** directory; your first review is never overwritten. No SQL database, Docker, Copilot account or Azure subscription is required.

## Trace a finding from assessment to verification

1. **Identify the sign-in dependency.** Read [the gateway findings in step 1](modernize-app-code.md#inspect-the-gateways-database-risks). Which app would you modernize first, and why? Name two risks that changing the target framework alone would leave in place.
2. **Turn one risk into an acceptance check.** Open `rulebook/policies.md` in the downloaded checkpoint. Find the database authentication and encryption rules. Compare them with [the prepared plan excerpt](../img/guide-annotations/annotated/caldova-plan-review-annotated-bca49df6c11b.png). Write down what you'd look for in the gateway code before accepting the change.
3. **Interpret the task history.** In [the execution-start screenshot](../img/guide-annotations/annotated/caldova-task-states-annotated-918df22654f4.png), which two tasks were already successful? Would that prove that the gateway can connect to a database? Use the files below to decide what you can verify without one.

**Check your reasoning:** The portal depends on the gateway for sign-in, so plan the gateway first. The old SQL client, password-based database access and certificate validation need separate attention. A prepared runtime upgrade and Web Forms conversion are not evidence of a working database connection.

## Inspect the modernization decisions

Open the printed `dotnet` directory in any editor. All paths below are relative to that directory.

| Open | What to check |
|---|---|
| The application `.csproj` in each of `apps/CaldovaAuthGateway`, `apps/CaldovaLoanPortal` and `apps/CaldovaRiskEngine` | Each targets `net10.0`. The target framework tells you where the code runs, not whether the apps still work together. |
| `apps/CaldovaAuthGateway/DbConfig.cs` | Find `ActiveDirectoryDefault`, `Encrypt = SqlConnectionEncryptOption.Mandatory` and `TrustServerCertificate = false`. The gateway uses identity-based SQL authentication and requires an encrypted connection with certificate validation. Reading this code does not establish a live SQL connection. |
| `apps/CaldovaLoanPortal/Dockerfile` | Compare the .NET 10 SDK build image with the ASP.NET 10 runtime image. Find `USER $APP_UID` in the runtime stage. No container build is needed for this review. |
| `VALIDATION.md` | Compare **Observed results** with **Still environment-dependent**. Which checks ran in the original rehearsal? Which, such as Azure SQL managed identity, were not exercised? Neither set is evidence from your machine. |

## Record what you verified

With `-TestGateway`, expect **13 passed, 0 failed, 0 skipped**. That's your local result for the **final gateway**. If you omitted the switch, record the tests as **not run**. Neither the earlier task screenshot nor the historical results in `VALIDATION.md` count as tests on your machine. Database-backed sign-in, live planning and execution, and the [prepared `finish` gateway](modernize-app-code.md#6-validate-the-prepared-gateway) remain unverified in this review.
