---
id: "01a1cf70-a603-70f1-82e9-06b021c9b281"
title: "TS-FRG: Forge and mrman (attended)"
type: "Test Suite"
tags:
  - "uat"
  - "test-suite"
  - "ts-frg"
created: "2026-11-12T05:07:08-06:00"
timestamp: "2026-11-12T05:07:08-06:00"
description: "The attended forge leg of make uat: an Azure DevOps PR per model, mrman's headless session, the tester's submit grant in the TUI, and the posted threads."
---

# TS-FRG: Forge and mrman (attended)

- **Command:** `make uat`
- **Tokens:** Yes (live models)
- **Attended:** Yes. A tester grants submit in the mrman TUI.
- **Plan:** [UAT test plan](/test-suites/uat-test-plan--01a1cf70a5f6.md)

## Scope
mrman with a Vizzini report on a real Azure DevOps PR. The human submit grant. Findings posted as inline threads.

## Remote changes
One ADO PR and branch per fixture and model. The PRs stay open until cleanup.

## Preconditions
- All TS-REV preconditions are true.
- `make ado-check` passes.
- You have a second terminal and a web browser signed in to Azure DevOps.

## Execution
| Step | Action | Expected result |
|---|---|---|
| 1 | Run `make litellm-up`. | The command exits with status 0. |
| 2 | Run `make uat`. | The first line of output is `run: <run>`. |
| 3 | Write down the `<run>` path. | You have the run directory for all cases in this suite. |
| 4 | For each fixture and model, do UAT-FRG-001 to UAT-FRG-005 when the run asks. | The run continues after each grant. |
| 5 | Wait for the run to stop. | The last line is `hard checks: N/M passed`. |

## Test cases
| ID | Title | Priority |
|---|---|---|
| [UAT-FRG-001](/test-suites/forge/uat-frg-001-a-pr-opens-on-azure-devops-for-each-model--01a1cf70a680.md) | A PR opens on Azure DevOps for each model | High |
| [UAT-FRG-002](/test-suites/forge/uat-frg-002-mrman-opens-the-pr-headlessly-with-every-finding--01a1cf70a689.md) | mrman opens the PR headlessly with every finding | High |
| [UAT-FRG-003](/test-suites/forge/uat-frg-003-the-tester-grants-submit-in-the-mrman-tui--01a1cf70a691.md) | The tester grants submit in the mrman TUI | High |
| [UAT-FRG-004](/test-suites/forge/uat-frg-004-the-tester-promotes-a-finding-to-a-draft-comment--01a1cf70a699.md) | The tester promotes a finding to a draft comment | Medium |
| [UAT-FRG-005](/test-suites/forge/uat-frg-005-the-findings-are-posted-as-inline-threads--01a1cf70a6a1.md) | The findings are posted as inline threads | High |
| [UAT-FRG-006](/test-suites/forge/uat-frg-006-cleanup-removes-the-prs-and-branches--01a1cf70a6a9.md) | Cleanup removes the PRs and branches | Medium |

## After the run
Do UAT-FRG-006 to remove the PRs and branches.

## Traces to
[ADR-0002](/decisions/adr-0002-the-mrman-submit-grant-stays-a-human-step--01a1caeb8ce7.md), [Run the live UAT](/runbooks/runbook-run-the-live-uat--01a1cf4af7f5.md)
