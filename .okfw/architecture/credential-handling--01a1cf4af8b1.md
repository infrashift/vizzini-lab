---
id: "01a1cf4a-f8b1-7c9e-b8ba-85f3c324ec61"
title: "Credential handling"
type: "Architecture"
tags:
  - "architecture"
  - "security"
created: "2026-11-12T04:25:59-06:00"
timestamp: "2026-11-12T04:25:59-06:00"
description: "Where every secret the UAT uses lives, how each reaches the tool that needs it without a command line or a log, and what identity data is redacted."
---

# Credential handling

| secret | lives in | reaches its user through | never |
|---|---|---|---|
| Anthropic key | podman secret `vizzini-anthropic-key`, created by a person | `podman --secret …,type=env` into the LiteLLM container | read, echoed, or written by the harness or an agent |
| LiteLLM master key, DB password | `.cache/litellm/*` (0600) and podman secrets | `litellm.sh env` for Vizzini; podman secrets for the containers | committed |
| ADO PAT | `~/.config/vizzini-uat/ado.pat` (0600) | git: a credential helper that reads an env var; curl: a config on stdin (`-K -`); mrman: `AZURE_DEVOPS_EXT_PAT`; the ADO agent: `VSTS_AGENT_INPUT_TOKEN`, with only the name on podman's command line | on a command line, in a log, in `.cache/runs` |
| `GITHUB_TOKEN` | GitHub, per job | the workflow, scoped to the job | outside GitHub |
| `System.AccessToken` | ADO, per job | the pipeline step's env | outside ADO |
| GitLab root token, runner token, project access token | generated for the run; die with the instance | root: `podman exec -e NAME`, git credential helper, curl config on stdin; the bot token: a masked CI/CD variable | written to disk; the bot token is masked in job logs |

## Identity data
- **The requester** is the PAT owner's forge identity. It goes into Vizzini's reports and LiteLLM's spend metadata for cost attribution ([ADR-0009](/decisions/adr-0009-cost-attribution-from-litellm-spend-logs-never-prompts--01a1cf4af8f4.md)).
- **The forge-verified identity** goes into the bot test's run-local allow policy.
- **Both are personal data.** Logs print three characters and an ellipsis, and neither is ever committed ([layout](/architecture/run-artifacts-and-the-cache-layout--01a1cf4af87e.md)).

## Grants
- **mrman's interactive submit grant** is never faked ([ADR-0002](/decisions/adr-0002-the-mrman-submit-grant-stays-a-human-step--01a1caeb8ce7.md)).
- **Unattended posting** happens only under a garmr policy read from the base branch ([ADR-0004](/decisions/adr-0004-the-unattended-leg-authorizes-by-policy-deny-first--01a1cbfe4052.md)).
- **Platform permissions a test needs** are granted for the run and restored in its exit trap ([ADR-0007](/decisions/adr-0007-azure-pipelines-runs-on-a-throwaway-self-hosted-podman-agent--01a1cf4af8d2.md)).
