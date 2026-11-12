---
id: "01a1d175-283c-7d2b-bbe7-0eee3f152a6b"
title: "Go unit, privileged and script tests"
type: "Guideline"
tags:
  - "testing"
  - "go"
  - "hive"
  - "script"
created: "2026-11-12T14:31:18-06:00"
timestamp: "2026-11-12T14:31:18-06:00"
description: "Go code is tested with the standard go test framework, privileged tests are gated and skipped by default, and cells are integration-tested with hive scripts."
x:
  paths: ["pkg/**/*_test.go", "daemon/**/*_test.go", "operator/**/*_test.go", "pkg/**/testdata/**", "contrib/examples/script/**"]
  source: ["Documentation/contributing/testing/unit.rst", "Documentation/contributing/development/hive.rst", "Documentation/contributing/development/contributing_guide.rst", "Documentation/contributing/development/statedb.rst"]
---

# Go unit, privileged and script tests

**Coverage expectations.** The PR checklist says: "All code is covered by unit and/or runtime tests where feasible," and all changes should be checked for regressions against the existing test suite. The hive guide adds that each non-trivial cell should come with a test that checks it implements its public API correctly. That test also serves as an example of using the cell.

**Framework.** "Cilium uses the standard `go test` framework. All new tests must use the standard test framework." Run unit tests with `go test ./...`. Tests that need etcd use `make start-kvstores`, or `make integration-tests TESTPKGS=...` which sets up and tears down the prerequisites.

**Privileged tests.** Tests that need root or specific capabilities are marked privileged and "are skipped by default when running `go test`." They run with `sudo make tests-privileged` or `PRIVILEGED_TESTS=true go test -exec "sudo -E" ./pkg/...`. A test that needs privileges should use this marking instead of failing or silently passing for unprivileged runs.

**Test isolation.** Stop hooks must wait for every goroutine and handle the cell created, so tests in one suite do not affect each other; `goleak` is recommended for checking leaks. Config in tests should be set with a config override rather than global flag parsing.

**Hive script tests.** The hive library includes `script`, a txtar-based test engine (a fork of the Go toolchain's internal script package). Scripts embed input files, run commands in a temporary `$WORK` directory, and support prefixes: `!` (expect failure), `*` (retry the section until success) and `!*` (retry until failure). Cells can register their own commands. "New commands should use the naming scheme `<component>/<command>`, e.g. `hive/start` and not build sub-commands." Useful command sets come from `FakeClientCell` (`k8s/*`), StateDB (`db/*`, such as `db/insert`, `db/cmp`, `db/empty`) and metrics. `contrib/examples/script` is the minimal reference, and `git grep scripttest.Test` finds existing users.

**Why this matters.** The StateDB guide says that when a component's inputs and outputs are tables, several components can be combined into an integration test defined only by inputs and expected outputs. This allows "more validation to be performed with fairly simple integration tests rather than with slower and costly end-to-end tests." End-to-end coverage is done separately with `cilium connectivity test`.
