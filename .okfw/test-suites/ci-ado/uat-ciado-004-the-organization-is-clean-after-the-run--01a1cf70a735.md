---
id: "01a1cf70-a735-7ced-b4c9-01c6407c53ac"
title: "UAT-CIADO-004: The organization is clean after the run"
type: "Test Case"
tags:
  - "uat"
  - "test-case"
  - "ts-ciado"
  - "high"
created: "2026-11-12T05:07:08-06:00"
timestamp: "2026-11-12T05:07:08-06:00"
description: "Make sure that the test removes the permission and everything else it made."
---

# UAT-CIADO-004: The organization is clean after the run

- **Suite:** [TS-CIADO: Azure Pipelines template](/test-suites/ci-ado/ts-ciado-azure-pipelines-template--01a1cf70a616.md)
- **Priority:** High

## Objective
Make sure that the test removes the permission and everything else it made.

## Preconditions
- The TS-CIADO run is complete.

## Steps
| Step | Action | Expected result |
|---|---|---|
| 1 | Find the section `== cleanup`. | The section shows the permission removed or restored, the PR abandoned, the policy, pipeline and branches deleted, and the agent stopped. |
| 2 | In ADO, open *Project settings* > *Repositories* > the repository > *Security*. Select `<Project> Build Service (<org>)`. | *Contribute to pull requests* is *Not set*, or the value it had before the run. |
| 3 | Open *Pipelines*. | No pipeline has the name `vizzini-bot-test-<stamp>`. |
| 4 | Open *Organization settings* > *Agent pools* > *Default* > *Agents*. | No agent has the name `vizzini-uat-<stamp>`. |
| 5 | Open *Repos* > *Branches*. | No branch starts with `ci/`. |
| 6 | Run `podman ps -a --filter name=vizzini-uat-`. | The output shows no agent container. |

> **CAUTION:** If the permission is still set, remove it now. See [cleanup](/runbooks/runbook-clean-up-after-an-interrupted-run--01a1cf4af83a.md).

## Pass criteria
The case passes when each step gives its expected result.

## Traces to
[ADR-0007](/decisions/adr-0007-azure-pipelines-runs-on-a-throwaway-self-hosted-podman-agent--01a1cf4af8d2.md)

## Record
| Date | Tester | Build | Result | Notes |
|---|---|---|---|---|
| | | | | |
