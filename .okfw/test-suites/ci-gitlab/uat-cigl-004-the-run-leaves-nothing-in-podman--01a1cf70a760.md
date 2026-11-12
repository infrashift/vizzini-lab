---
id: "01a1cf70-a760-7817-b509-7893659f602f"
title: "UAT-CIGL-004: The run leaves nothing in podman"
type: "Test Case"
tags:
  - "uat"
  - "test-case"
  - "ts-cigl"
  - "medium"
created: "2026-11-12T05:07:09-06:00"
timestamp: "2026-11-12T05:07:09-06:00"
description: "Make sure that the test removes its containers, volumes and network."
---

# UAT-CIGL-004: The run leaves nothing in podman

- **Suite:** [TS-CIGL: GitLab CI template](/test-suites/ci-gitlab/ts-cigl-gitlab-ci-template--01a1cf70a61d.md)
- **Priority:** Medium

## Objective
Make sure that the test removes its containers, volumes and network.

## Preconditions
- The TS-CIGL run is complete.

## Steps
| Step | Action | Expected result |
|---|---|---|
| 1 | Find the section `== cleanup`. | The section shows the runner, the job volumes, GitLab and the network removed. |
| 2 | Run `podman ps -a --filter name=vizzini-lab-`. | The output shows no GitLab or runner container. |
| 3 | Run `podman network ls`. | No network starts with `vizzini-lab-gl-`. |

## Pass criteria
The case passes when each step gives its expected result.

## Record
| Date | Tester | Build | Result | Notes |
|---|---|---|---|---|
| | | | | |
