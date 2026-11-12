---
id: "01a1d0fc-a7cd-7730-b0b8-ed3264f146ff"
title: "UAT-WF-020: Reconsider with a live model"
type: "Test Case"
tags:
  - "uat"
  - "test-case"
  - "ts-wf"
  - "high"
created: "2026-11-12T12:19:41-06:00"
timestamp: "2026-11-12T12:19:41-06:00"
description: "Make sure that a live model answers /vizzini reconsider with a real argument, and that the bot acts on each verdict."
---

# UAT-WF-020: Reconsider with a live model

- **Suite:** [TS-WF: Full review workflow](/test-suites/workflow/ts-wf-full-review-workflow--01a1cfa4f447.md)
- **Priority:** High
- **Mode:** Automated, tester-verified. Uses live model tokens.
- **Requirement:** REQ-WF-13

## Objective
Make sure that a live model answers `/vizzini reconsider` with a real argument, and that the bot acts on each verdict. UAT-WF-007 and UAT-WF-008 use stubllm, which gives a scripted verdict.

## Preconditions
- The [first-time setup](/runbooks/runbook-first-time-setup--01a1cf4a8f24.md) is complete. `make ado-check` passes.
- LiteLLM is running: `make litellm-up`, then `make litellm-smoke` passes.

## Fixture
| File | Finding (from stubllm) | Developer's argument | Expected verdict |
|---|---|---|---|
| `wf/form.go:4` | gosec G101 on `const passwordField = "password"`, a form field name | The value is the field's name, not a credential. G101 matches on the identifier. | withdrawn |
| `wf/login.go:5` | gosec G401: MD5 hashes stored passwords | "MD5 is fine here", with no evidence | stands |

stubllm writes the findings, so the threads are the same in each run. Only the reconsider answers come from the live model.

## Steps
| Step | Action | Expected result |
|---|---|---|
| 1 | Run `make uat-reconsider MODEL=claude-sonnet-5-5`. Write down the `<run>` path. | The output ends with `result: PASS`, then `PR <id> abandoned`. |
| 2 | Find `## Hard checks` in `<run>/summary.md`. | Each item shows `[x]`. |
| 3 | Read `## Model quality`. | The line `verdicts as expected` shows a count. Record it in *Notes*. |
| 4 | Read `## The answers`. | Each answer gives a reason. The `stands` answer replies to the developer's points and tells what evidence would change the verdict. |
| 5 | Do steps 1 to 4 again with `MODEL=claude-opus-5-5`. | The same results as steps 1 to 4. |

## Pass criteria
The case passes when each hard check passes for each model. A verdict that is not the expected verdict does not make the case fail: it is a model-quality finding. Record it in *Notes* (vizzini-lab CLAUDE.md rule 4).

## Traces to
Vizzini ISSUE-029 and ADR-0023.

## Record
| Date | Tester | Build | Result | Notes |
|---|---|---|---|---|
| 2026-11-12 | Claude (agent) | see results/2026-11-12-live-reconsider.md | PASS | Sonnet 5.5 and Opus 5.5: 8/8 hard checks, verdicts 2/2 as expected |
