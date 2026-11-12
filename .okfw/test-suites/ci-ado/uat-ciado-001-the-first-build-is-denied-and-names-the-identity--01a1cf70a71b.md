---
id: "01a1cf70-a71b-7e03-a658-a7f958c4a200"
title: "UAT-CIADO-001: The first build is denied and names the identity"
type: "Test Case"
tags:
  - "uat"
  - "test-case"
  - "ts-ciado"
  - "high"
created: "2026-11-12T05:07:08-06:00"
timestamp: "2026-11-12T05:07:08-06:00"
description: "Make sure that the first build posts nothing and shows the identity to allow."
---

# UAT-CIADO-001: The first build is denied and names the identity

- **Suite:** [TS-CIADO: Azure Pipelines template](/test-suites/ci-ado/ts-ciado-azure-pipelines-template--01a1cf70a616.md)
- **Priority:** High

## Objective
Make sure that the first build posts nothing and shows the identity to allow.

## Preconditions
- The TS-CIADO run is complete.

## Steps
| Step | Action | Expected result |
|---|---|---|
| 1 | Find the line `<Project> Build Service (<org>): Contribute to pull requests on <repo>`. | The line shows. |
| 2 | Find the section `== PR: the policy lists no identity`. | The section shows `build <id>: failed`. |
| 3 | Find the line `System.AccessToken posts as: <Project> Build Service (<org>)`. | The line shows. |
| 4 | Open `<run>/build1.log`. | The log has `exited with code '3'` and `the grant policy denied posting`. |
| 5 | Search `<run>/build1.log` for `MRM-002`. | The log has `"decision":"deny"` and `MRM-002`. |

## Pass criteria
The case passes when each step gives its expected result.

## Traces to
[ADR-0007](/decisions/adr-0007-azure-pipelines-runs-on-a-throwaway-self-hosted-podman-agent--01a1cf4af8d2.md)

## Record
| Date | Tester | Build | Result | Notes |
|---|---|---|---|---|
| | | | | |
