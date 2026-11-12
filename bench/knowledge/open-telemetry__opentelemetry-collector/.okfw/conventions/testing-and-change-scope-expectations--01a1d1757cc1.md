---
id: "01a1d175-7cc1-7c22-a903-a1a2d7a15656"
title: "Testing and Change Scope Expectations"
type: "Guideline"
tags:
  - "testing"
  - "review"
  - "pull-requests"
created: "2026-11-12T14:31:40-06:00"
timestamp: "2026-11-12T14:31:40-06:00"
description: "What tests a change must carry and how narrowly a pull request must be scoped in the Collector repository."
x:
  paths: ["**/*_test.go", "internal/testutil/**", "component/componenttest/**", "receiver/**", "processor/**", "exporter/**", "connector/**", "extension/**"]
  source: ["docs/coding-guidelines.md", "docs/component-stability.md", "CONTRIBUTING.md", "AGENTS.md", "docs/rfcs/component-interfaces.md"]
---

# Testing and Change Scope Expectations

**Unit tests**
- Cover important functionality with unit tests. Contributions must not decrease overall code coverage.
- Code changes should have tests that actually validate the change.
- Keep tests fast and use `t.Parallel()` where possible.
- Use `testify/assert` for checks, `testify/require` when the test cannot continue after a failure, `testify/mock` for mocking external resources, and `net/http/httptest` for HTTP interactions.
- Integration tests are encouraged, using container images where possible; otherwise mock the integration.
- Public and extension interface packages SHOULD ship test helpers in a `<package>test` submodule with its own `go.mod`, typically `NewNop()` (no-op) and `NewErr(err)` (every method returns the error) built from `<Method>Func` fields.
- mdatagen generates `generated_telemetry_test.go` sanity tests for metrics declared in `metadata.yaml`.

**Stable components** MUST have:
1. Coverage above the higher of 80% and the repository minimum, with unit tests that SHOULD cover all configuration options.
2. At least one lifecycle test for initialization with a valid configuration, checking context propagation where relevant.
3. At least one benchmark per stable signal.

Performance should also be tested under load many times above normal (see the resource rules).

**Change scope**
- PRs are recommended to stay under 500 lines, excluding `go.mod`/`go.sum`.
- Keep a PR to the single change it delivers: no drive-by cleanup, opportunistic refactors, wording or formatting tweaks unless strictly needed for correctness.
- Refactoring goes in its own PR with no behaviour changes.
- New components arrive in steps: structure first (README, config, factory, `In Development` stability), then the implementation, then `Alpha` and inclusion in `otelcorecol`.
- User-visible behaviour, configuration, defaults, new components and exported API changes need a `.chloggen` entry; test-only, CI and internal-package changes may omit it.
- The project does not accept implementations of specification language before it is in a stable specification release.

Exceptions to these rules need a stated reason in the PR and approver consensus.
