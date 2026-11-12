---
id: "01a1d176-58c8-7454-bbf6-03fbc024de49"
title: "Testing expectations"
type: "Guideline"
tags:
  - "testing"
  - "integration"
  - "ci"
created: "2026-11-12T14:32:36-06:00"
timestamp: "2026-11-12T14:32:36-06:00"
description: "Which tests a change needs in rclone, from unit tests and quicktest to backend integration tests and test_all."
x:
  paths: ["fstest/**", "backend/**/*_test.go", "fs/**/*_test.go", "vfs/**/*_test.go", "cmd/**/*_test.go", "cmdtest/**"]
  source: ["CONTRIBUTING.md", "AGENTS.md", ".github/PULL_REQUEST_TEMPLATE.md", "fstest/testserver/init.d/README.md"]
---

# Testing expectations

## What tests must do

AGENTS.md: "Make sure added tests **actually test the code you have written** and test the intention behind the change. If you are fixing a problem, write the tests first to reproduce the problem before starting on the fix." Re-use the existing test scaffolding. CONTRIBUTING.md requires unit tests for new features.

## Test layers

- **Unit tests and quicktest.** `make quicktest` (or `RCLONE_CONFIG="/notfound" go test ./...`) runs everything that needs no cloud credentials, and CI runs it on every push. `make racequicktest` adds the race detector. As a minimum, `go build` and `make quicktest` must pass.
- **Backend tests.** Rclone does not mock cloud providers. CONTRIBUTING.md says that mocking all their interfaces is "difficult (and in some respects pointless)". Instead, tests run against specially named remotes in the config file, such as `TestDrive`, and are skipped when that remote is not defined. Each backend's `remote_test.go` calls `fstests.Run()` from `fstest/fstests`, which is the generic backend test suite.
- **Integration tests.** `fs/operations` and `fs/sync` tests usually run against the local filesystem, but they can target any remote with `-remote TestRemote:`. A backend that implements `ListR` must also be tested with `-fast-list`.
- **test_all.** `go run ./fstest/test_all -backends remote` runs the integration tests with retries and an HTML report. New backends are added to `fstest/test_all/config.yaml`. The full suite runs daily on the integration test server.

## Merge gates for backends

Before a new or changed backend can be merged, the project requires two things:

1. a clean run of `test_all` for that backend, with the result included in the PR;
2. a test account, so the maintainers can run it daily. "A backend that we cannot test is likely to break and may be removed."

## Code quality checks

`make check` or `golangci-lint run ./...` runs the same lint as CI. It uses golangci-lint v2 with the settings in `.golangci.yml`. The enabled linters are errcheck, govet, ineffassign, staticcheck, unused, gocritic, misspell, revive and unconvert, and `goimports` formatting is enforced. The lint catches easy mistakes "like forgetting to check an error return".

## Test servers

Scripts in `fstest/testserver/init.d` start and stop local servers for test_all. They must include the `run.bash` boilerplate, which does reference counting. Each must allocate a unique port in `PORTS.md` and bind ports to localhost so they are not reachable from outside.
