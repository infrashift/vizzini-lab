---
id: "01a1d176-87fa-7e75-ae9c-c6e750a9fc41"
title: "Pull request checklist and project tooling"
type: "Guideline"
tags:
  - "contributing"
  - "testing"
  - "review"
created: "2026-11-12T14:32:48-06:00"
timestamp: "2026-11-12T14:32:48-06:00"
description: "What undici's contribution guide and pull request template expect from every code change: tests, documentation, passing lint and tests, and stated breaking changes."
x:
  paths: ["lib/**/*.js", "test/**/*.js", "index.js", "index-fetch.js", "types/**/*.d.ts"]
  source: ["CONTRIBUTING.md", ".github/PULL_REQUEST_TEMPLATE.md"]
---

# Pull request checklist and project tooling

The pull request template lists three requirements for code changes:

1. **Include tests for any bug fixes or new features.**
2. **Update documentation if relevant.**
3. **Ensure that tests and linting pass.**

The template's status checklist also has "Tested", "Documented" and an optional "Benchmarked" item, plus a sign-off that the contributor agrees to the Developer's Certificate of Origin in `CONTRIBUTING.md`.

## Breaking changes must be called out

The template has a dedicated "Breaking Changes and Deprecations" section, defined as "changes that modify the existing API" and "removed features". A reviewer should expect any change to public behavior or signatures to be listed there rather than slipped in under "Bug Fixes" or "Features".

## Bug fixes come with a regression test

`CONTRIBUTING.md` says: "If you are submitting a bug fix via a pull request, include a test file `test/issue-XXXX.js` that reproduces the bug and passes with the fix." The reproduction guidance describes what that test should look like: standalone (only `undici` and Node.js built-ins), minimal, run with Node's test runner (`node --test`), and using a local server created with `node:http` (or `node:https` for TLS issues) inside the same file rather than an external service. See the "Writing reliable tests" concept for the test patterns.

## Commands the project defines

- Lint: `npm run lint`
- Test: `npm run test`
- Coverage: `npm run coverage`
- Web Platform Tests: `npm run test:wpt` (initializes the WPT submodule if missing). undici runs a *subset* of the web-platform-tests; when running them, "ensure that any new failures are marked as such". Verbose logs are available with `NODE_DEBUG=UNDICI_WPT`.
- Benchmarks: `cd benchmarks && npm i && npm run bench`.

## What the docs do not say

The contribution guide does not state a written coding style beyond "lint must pass" (the repository has an `eslint.config.js`), and it does not give a coverage threshold. Reviewers should not invent stricter rules on the project's behalf; the lint configuration is the style authority.
