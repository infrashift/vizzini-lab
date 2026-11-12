---
id: "01a1cf70-a5fc-7a20-b0d4-62b882440694"
title: "TS-REV: Live review"
type: "Test Suite"
tags:
  - "uat"
  - "test-suite"
  - "ts-rev"
created: "2026-11-12T05:07:08-06:00"
timestamp: "2026-11-12T05:07:08-06:00"
description: "Live Claude reviews of the seeded C# and TypeScript fixtures and the real-world commits: report validity, must-catch defects, knowledge, lint, garmr and the other modes."
---

# TS-REV: Live review

- **Command:** `make uat-vizzini`
- **Tokens:** Yes (live models)
- **Attended:** No
- **Plan:** [UAT test plan](/test-suites/uat-test-plan--01a1cf70a5f6.md)

## Scope
Vizzini review, describe, improve and plan with live models. garmr evaluation of each review. The large real-world commit.

## Remote changes
None. The models are called through LiteLLM.

## Preconditions
- The [first-time setup](/runbooks/runbook-first-time-setup--01a1cf4a8f24.md) is complete.
- The podman secret `vizzini-anthropic-key` exists.
- `make build` completes without errors.

## Execution
| Step | Action | Expected result |
|---|---|---|
| 1 | Run `make litellm-up`. | The command exits with status 0. |
| 2 | Run `make litellm-smoke`. | Each model gives an answer. The command exits with status 0. |
| 3 | Run `make uat-vizzini`. | The first line of output is `run: <run>`. |
| 4 | Write down the `<run>` path. | You have the run directory for all cases in this suite. |
| 5 | Wait for the run to stop. | The last line is `hard checks: N/M passed`. |

## Test cases
| ID | Title | Priority |
|---|---|---|
| [UAT-REV-001](/test-suites/review/uat-rev-001-the-proxy-answers-in-json-mode-for-each-model--01a1cf70a624.md) | The proxy answers in JSON mode for each model | High |
| [UAT-REV-002](/test-suites/review/uat-rev-002-each-review-report-is-valid-and-anchored-to-the-diff--01a1cf70a62c.md) | Each review report is valid and anchored to the diff | High |
| [UAT-REV-003](/test-suites/review/uat-rev-003-the-must-catch-c-defects-are-caught--01a1cf70a634.md) | The must-catch C# defects are caught | High |
| [UAT-REV-004](/test-suites/review/uat-rev-004-the-must-catch-typescript-defects-are-caught--01a1cf70a63c.md) | The must-catch TypeScript defects are caught | High |
| [UAT-REV-005](/test-suites/review/uat-rev-005-the-injection-finding-cites-the-fixtures-adr--01a1cf70a645.md) | The injection finding cites the fixture's ADR | High |
| [UAT-REV-006](/test-suites/review/uat-rev-006-only-the-relevant-knowledge-reaches-the-model--01a1cf70a64e.md) | Only the relevant knowledge reaches the model | Medium |
| [UAT-REV-007](/test-suites/review/uat-rev-007-only-the-changed-line-lint-diagnostics-are-injected--01a1cf70a658.md) | Only the changed-line lint diagnostics are injected | Medium |
| [UAT-REV-008](/test-suites/review/uat-rev-008-garmr-denies-a-review-with-critical-or-major-findings--01a1cf70a661.md) | garmr denies a review with Critical or Major findings | High |
| [UAT-REV-009](/test-suites/review/uat-rev-009-describe-improve-and-plan-give-schema-valid-answers--01a1cf70a669.md) | describe, improve and plan give schema-valid answers | Medium |
| [UAT-REV-010](/test-suites/review/uat-rev-010-a-large-commit-is-reviewed-in-more-than-one-chunk--01a1cf70a671.md) | A large commit is reviewed in more than one chunk | Medium |
| [UAT-REV-011](/test-suites/review/uat-rev-011-the-run-summary-compares-the-models--01a1cf70a678.md) | The run summary compares the models | Low |

## After the run
Run `make litellm-down` when you do not need the models again. The spend history stays.

## Traces to
[ADR-0010](/decisions/adr-0010-seeded-fixtures-per-language-only-must-catch-defects-are-hard--01a1cf4af906.md), [Run the live UAT](/runbooks/runbook-run-the-live-uat--01a1cf4af7f5.md)
