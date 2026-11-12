---
id: "01a1cf70-a624-7a47-8601-cacf5a5d241e"
title: "UAT-REV-001: The proxy answers in JSON mode for each model"
type: "Test Case"
tags:
  - "uat"
  - "test-case"
  - "ts-rev"
  - "high"
created: "2026-11-12T05:07:08-06:00"
timestamp: "2026-11-12T05:07:08-06:00"
description: "Make sure that LiteLLM reaches each model and returns JSON."
---

# UAT-REV-001: The proxy answers in JSON mode for each model

- **Suite:** [TS-REV: Live review](/test-suites/review/ts-rev-live-review--01a1cf70a5fc.md)
- **Priority:** High

## Objective
Make sure that LiteLLM reaches each model and returns JSON.

## Preconditions
- None.

## Test data
- `MODELS` in `versions.env`: `claude-sonnet-5-5 claude-opus-5-5`.

## Steps
| Step | Action | Expected result |
|---|---|---|
| 1 | Run `make litellm-up`. | The command exits with status 0. |
| 2 | Run `make litellm-smoke`. | The output shows one answer for each model in `MODELS`. |
| 3 | Examine the exit status. | The status is 0. |

## Pass criteria
The case passes when each step gives its expected result.

## Traces to
[ADR-0003](/decisions/adr-0003-litellm-v1-99-4-with-explicit-max-tokens-for-the-claude-5-5-models--01a1caeb8cfe.md)

## Record
| Date | Tester | Build | Result | Notes |
|---|---|---|---|---|
| | | | | |
