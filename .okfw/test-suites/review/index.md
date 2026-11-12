# test-suites/review

<!-- okfw:generated — maintained by okfw; edits here are overwritten -->

## Concepts

* [TS-REV: Live review](ts-rev-live-review--01a1cf70a5fc.md) - Live Claude reviews of the seeded C# and TypeScript fixtures and the real-world commits: report validity, must-catch defects, knowledge, lint, garmr and the other modes.
* [UAT-REV-001: The proxy answers in JSON mode for each model](uat-rev-001-the-proxy-answers-in-json-mode-for-each-model--01a1cf70a624.md) - Make sure that LiteLLM reaches each model and returns JSON.
* [UAT-REV-002: Each review report is valid and anchored to the diff](uat-rev-002-each-review-report-is-valid-and-anchored-to-the-diff--01a1cf70a62c.md) - Make sure that each review gives a valid report and that each finding is on a changed line.
* [UAT-REV-003: The must-catch C# defects are caught](uat-rev-003-the-must-catch-c-defects-are-caught--01a1cf70a634.md) - Make sure that each model finds the four must-catch defects in the C# fixture.
* [UAT-REV-004: The must-catch TypeScript defects are caught](uat-rev-004-the-must-catch-typescript-defects-are-caught--01a1cf70a63c.md) - Make sure that each model finds the four must-catch defects in the TypeScript fixture.
* [UAT-REV-005: The injection finding cites the fixture's ADR](uat-rev-005-the-injection-finding-cites-the-fixtures-adr--01a1cf70a645.md) - Make sure that the review grounds the injection finding in the fixture's knowledge base.
* [UAT-REV-006: Only the relevant knowledge reaches the model](uat-rev-006-only-the-relevant-knowledge-reaches-the-model--01a1cf70a64e.md) - Make sure that Vizzini gives the model the relevant ADRs and no other OKF document.
* [UAT-REV-007: Only the changed-line lint diagnostics are injected](uat-rev-007-only-the-changed-line-lint-diagnostics-are-injected--01a1cf70a658.md) - Make sure that Vizzini gives the model only the linter diagnostics on changed lines.
* [UAT-REV-008: garmr denies a review with Critical or Major findings](uat-rev-008-garmr-denies-a-review-with-critical-or-major-findings--01a1cf70a661.md) - Make sure that garmr evaluates each review and denies a review with blocking findings.
* [UAT-REV-009: describe, improve and plan give schema-valid answers](uat-rev-009-describe-improve-and-plan-give-schema-valid-answers--01a1cf70a669.md) - Make sure that the other Vizzini modes give answers that agree with the schema.
* [UAT-REV-010: A large commit is reviewed in more than one chunk](uat-rev-010-a-large-commit-is-reviewed-in-more-than-one-chunk--01a1cf70a671.md) - Make sure that Vizzini splits a large real-world diff into chunks.
* [UAT-REV-011: The run summary compares the models](uat-rev-011-the-run-summary-compares-the-models--01a1cf70a678.md) - Make sure that the run records the model comparison. The values are metrics. They do not fail the run.

