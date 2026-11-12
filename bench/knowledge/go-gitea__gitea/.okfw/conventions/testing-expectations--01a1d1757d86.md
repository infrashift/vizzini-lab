---
id: "01a1d175-7d86-7e57-85e7-6ff5a2ea26d3"
title: "Testing Expectations"
type: "Guideline"
tags:
  - "testing"
  - "integration"
  - "e2e"
  - "review"
created: "2026-11-12T14:31:40-06:00"
timestamp: "2026-11-12T14:31:40-06:00"
description: "What the docs require of tests in a change: run the suites before submitting, prefer unit tests over integration tests, keep integration and e2e tests fast, and support every database backend the integration suite runs against."
x:
  paths: ["tests/**", "models/**/*_test.go", "modules/**/*_test.go", "routers/**/*_test.go", "services/**/*_test.go", "web_src/js/**/*.test.ts"]
  source: ["CONTRIBUTING.md", "AGENTS.md", "tests/integration/README.md", "docs/community-governance.md"]
---

# Testing Expectations

## Stated rules

- "Before submitting a pull request, run all tests to make sure your changes don't cause a regression elsewhere." (CONTRIBUTING.md)
- Prefer unit tests over integration tests when the logic can be tested in isolation. (AGENTS.md)
- Aim for under 2 seconds of local runtime for each integration and e2e test. (AGENTS.md)
- The AI contribution policy asks contributors to manually test changes and "add appropriate automated tests where feasible".
- Reviewers are asked to verify that tests are complete and aligned with the implementation. (community-governance.md)
- Feature PRs must include a testing description that reviewers can understand.

## Test layers

| Layer | Command | Location |
| - | - | - |
| Go unit tests | `make test-backend[#TestName]`, or `go test -run '^TestName$' ./modulepath/` | `*_test.go` next to the code |
| Integration tests | `make test-integration[#TestName]` | `tests/integration/` |
| End-to-end tests | `make test-e2e` (Playwright); a single file with `GITEA_TEST_E2E_FLAGS='<filepath>' make test-e2e` | `tests/e2e/` |
| Frontend unit tests | `pnpm exec vitest <path-filter>` | `web_src/js/**/*.test.ts` |

E2E timeouts are scaled by `GITEA_TEST_E2E_TIMEOUT_FACTOR` (default 4 on CI, 1 locally), which is one reason the docs ask for fast tests locally.

## Database coverage

Integration tests run against several databases chosen with `GITEA_TEST_DATABASE`: sqlite (the default when empty), MySQL, PostgreSQL and MSSQL. The PostgreSQL setup also uses a MinIO endpoint for storage, and the MySQL setup starts Elasticsearch alongside. A CI workflow (`pull-db-tests.yml`) runs these jobs. A reviewer should therefore treat database code that only works on one backend as a risk, since the suite exercises all of them.

## What a reviewer should check

- New logic comes with tests at the lowest layer that can cover it; an integration test where a unit test would do goes against the stated preference.
- New integration or e2e tests are not slow (the target is sub-2s each).
- PRs that only add or fix tests use the `test` Conventional Commits type.

The docs do not prescribe a test framework, fixture style, or coverage threshold beyond these points.
