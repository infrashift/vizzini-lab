---
id: "01a1d173-3195-7ec2-b54b-214ee19c4c87"
title: "Testing expectations"
type: "Guideline"
tags:
  - "testing"
  - "go"
created: "2026-11-12T14:29:09-06:00"
timestamp: "2026-11-12T14:29:09-06:00"
description: "Helm tests are table-driven with testify, use golden files in testdata/ for complex output and mock Kubernetes clients for action tests, and run with make test."
x:
  paths: ["**/*_test.go", "**/testdata/**", "pkg/action/**"]
  source: ["AGENTS.md", "CONTRIBUTING.md", ".github/pull_request_template.md"]
---

# Testing expectations

`AGENTS.md` lists the code standards for tests, and `CONTRIBUTING.md` sets how much testing a change needs.

**How tests are written**

- "Use table-driven tests with testify."
- Use "golden files in `testdata/` for complex output." A change that alters command output should come with updated golden files, and a reviewer should check that the golden diff matches the intended behaviour change.
- "Mock Kubernetes clients for action tests." Tests for `pkg/action/` operations should not need a real cluster.

**How tests are run**

- `make test` runs all tests, both style and unit.
- `make test-unit` runs unit tests only; `make test-coverage` runs them with coverage.
- `make test-style` runs linting and wraps `golangci-lint`, so lint failures are test failures.
- `go test -run TestName` runs a specific test.

**How much testing a change needs**

Size labels describe how "dangerous" a PR is, and they are about risk, not only line count: a 30-line change to key functionality may be treated as large. "Any changes from the community labeled as `size/S` or larger should be thoroughly tested before merging." The size guide says `size/XS` changes may need very little testing, `size/S` small amounts of manual testing, and `size/M` (30-99 lines) requires manual validation.

The pull request template asks the author to confirm whether the PR "contains unit tests" and "has been tested for backwards compatibility". A reviewer should expect new behaviour to be covered by unit tests and compatibility to be considered explicitly.

**Performance checks**

When a change needs profiling of memory or CPU use, `CONTRIBUTING.md` describes setting `HELM_PPROF_CPU_PROFILE` and/or `HELM_PPROF_MEM_PROFILE` to file paths to collect runtime profiles, which are then inspected with Go's `pprof` tool.
