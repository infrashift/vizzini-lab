---
id: "01a1cf4a-f83a-7428-b3f1-0a4d15d8f731"
title: "Runbook: clean up after an interrupted run"
type: "Runbook"
tags:
  - "runbook"
  - "cleanup"
created: "2026-11-12T04:25:59-06:00"
timestamp: "2026-11-12T04:25:59-06:00"
description: "What each suite leaves behind when it is killed mid-run, and how to remove it from Azure DevOps, GitHub, podman and LiteLLM without touching anything else."
---

# Runbook: clean up after an interrupted run

Each suite cleans up in an exit trap. A `kill -9`, a crashed terminal or a lost machine skips the trap. Remove only what the interrupted run made; the run directory's name gives its stamp.

## Azure DevOps (`make uat`, `make uat-bot`)
- **What is left:** a PR titled `vizzini-uat …` and `uat/<fixture>/…` branches. `uat-base`, the default branch, stays.
- **Fix:** abandon the PR in the web UI. `make ado-down` is broader: it abandons every open `vizzini-uat` PR and deletes every `uat/*` branch.

## Azure Pipelines test (`make uat-ci-ado`)
Check each item, and remove only this run's (`<stamp>`):
1. **The permission:** remove it first. In Project settings → Repositories → the UAT repository → Security, set *Contribute to pull requests* for `<Project> Build Service (<org>)` back to **Not set**, or to what it was. The script saves the previous entry and restores it, so a clean exit never needs this step.
2. **Pipeline:** `vizzini-bot-test-<stamp>`, in the `\vizzini-uat` folder.
3. **Branch policy:** the build validation on `ci/base-<stamp>`.
4. **PR and branches:** the PR from `ci/pr-<stamp>`, and the branches `ci/base-<stamp>` and `ci/pr-<stamp>`.
5. **Agent:** `podman stop vizzini-uat-<stamp>` deregisters it from the Default pool, then `podman rm` it. If the container is gone, delete the agent from the pool in Organization settings → Agent pools.

## GitHub Actions test (`make uat-ci-github`)
Check `gh pr list -R infrashift/vizzini-uat` and the repository's `ci/*` branches. Then close the test PR and run `git push origin --delete ci/base-<stamp> ci/pr-<stamp>`.

## GitLab CI test (`make uat-ci-gitlab`)
Everything is local:
- the containers `vizzini-uat-gitlab-<stamp>` and `vizzini-uat-runner-<stamp>`: `podman rm -f -v`;
- the network `vizzini-uat-gl-<stamp>`: `podman network rm`;
- job containers and volumes labelled `com.gitlab.gitlab-runner.type`, created after the run started. Leave older ones alone; they may belong to another runner.

## LiteLLM and local state
- `make litellm-down` stops the pod.
- `litellm/litellm.sh reset` also **deletes the spend-log database**, and with it all cost history ([ADR-0009](/decisions/adr-0009-cost-attribution-from-litellm-spend-logs-never-prompts--01a1cf4af8f4.md)).
- `make clean` removes all of `.cache`: tool clones, binaries, runs and evidence ([layout](/architecture/run-artifacts-and-the-cache-layout--01a1cf4af87e.md)).
