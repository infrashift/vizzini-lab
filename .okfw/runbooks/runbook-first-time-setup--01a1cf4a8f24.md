---
id: "01a1cf4a-8f24-7c5f-895d-a0c4e0520cf9"
title: "Runbook: first-time setup"
type: "Runbook"
tags:
  - "runbook"
  - "setup"
created: "2026-11-12T04:25:32-06:00"
timestamp: "2026-11-12T04:25:32-06:00"
description: "Everything a machine needs before any vizzini-uat suite runs: tools, the two secrets, the ADO repository, gh, the podman socket, and a first build."
---

# Runbook: first-time setup

Do this once per machine. Afterwards, [the suite map](/architecture/suite-map-what-each-make-target-proves--01a1cf4af86d.md) says what each suite needs.

## Tools
- **Go:** the build uses the local toolchain (go1.27.3 when this was written). garmr requires go ≥ 1.26.11, and `GOTOOLCHAIN=auto` fetches it when needed.
- **podman 4.9 or later**, with the user socket for the GitLab test: `systemctl --user enable --now podman.socket`.
- **git, curl, python3** with PyYAML (the CI template tests rewrite YAML), **shellcheck** for `make lint`, and **okfw** on `PATH` for the wiki.
- **gh**, authenticated with the `repo` and `workflow` scopes, for the GitHub Actions test only. That test pushes a workflow file.
- **Disk:** the .NET, Node, LiteLLM, Postgres, GitLab CE and gitlab-runner images take roughly 8 GB. Keep several GB free beyond that; see [troubleshooting](/runbooks/runbook-troubleshooting--01a1cf4af84b.md).

## Secrets
Create each one **in your own terminal**, never through an agent. [Credential handling](/architecture/credential-handling--01a1cf4af8b1.md) says how each is used.

1. **Anthropic key**, as a podman secret, for live models only:
   ```sh
   read -rs K && printf %s "$K" | podman secret create vizzini-anthropic-key - && unset K
   ```
2. **Azure DevOps**, for the forge leg, the bot test and the Azure Pipelines test:
   ```sh
   mkdir -p ~/.config/vizzini-uat
   echo 'ADO_REPO_URL=https://dev.azure.com/ORG/PROJECT/_git/REPO' > ~/.config/vizzini-uat/ado.env
   read -rs P && install -m600 /dev/null ~/.config/vizzini-uat/ado.pat && printf %s "$P" > ~/.config/vizzini-uat/ado.pat && unset P
   make ado-check
   ```
   *Code (Read & Write)* is enough for `make uat` and `make uat-bot`. `make uat-ci-ado` also creates a pipeline and a branch policy, changes a repository permission and registers an agent; it has only been run with a full-access PAT.

The GitLab test needs no secret of yours: every token it uses is made for the run ([ADR-0008](/decisions/adr-0008-gitlab-ci-runs-on-a-throwaway-self-managed-gitlab-ce-in-podman--01a1cf4af8e3.md)).

## First build
```sh
make build       # the four tools at their pins, into .cache/bin (ADR-0001)
make uat-stub    # token-free: proves the harness works on this machine
make lint
```
