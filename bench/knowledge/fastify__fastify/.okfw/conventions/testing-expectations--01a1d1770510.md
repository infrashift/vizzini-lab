---
id: "01a1d177-0510-7247-a7d7-6de3d451ce63"
title: "Testing Expectations"
type: "Guideline"
tags:
  - "fastify"
  - "testing"
  - "node-test"
  - "ci"
  - "benchmarks"
created: "2026-11-12T14:33:20-06:00"
timestamp: "2026-11-12T14:33:20-06:00"
description: "What the docs require of tests for a Fastify change: passing suites and green CI, node:test with inject(), clean teardown, the bundler and type test stacks, and benchmarks for performance claims."
x:
  paths: ["test/**", "examples/benchmark/**"]
  source: ["docs/Guides/Contributing.md", "CONTRIBUTING.md", "docs/Guides/Testing.md", "docs/Guides/Write-Plugin.md", "test/bundler/README.md", "docs/Guides/Benchmarking.md", "docs/Reference/Principles.md"]
---

# Testing Expectations

## Merge gate

- "If you open a pull request, please ensure your contribution passes all tests. If there are test failures, you will need to address them before we can merge your contribution."
- "All integrated CI services must be green before a pull request can be merged."
- Principle 7, "Easily testable", makes testing "a first-class concern".

## How tests are written

- The project uses Node's built-in test runner, [`node:test`](https://nodejs.org/api/test.html), chosen "since it offers out-of-the-box parallel testing and code coverage". The testing guide's examples use `test(...)`, `t.after(...)`, and `node:assert`-style assertions.
- `fastify.inject()` (backed by `light-my-request`) is the main way to exercise routes without a network socket. It "ensures all registered plugins have booted up" before the fake request runs.
- When a test does start a server with `listen()` or `ready()`, it should close it: "At the end of your tests it is highly recommended to call `.close()` to ensure that all connections to external services get closed," typically with `t.after(() => fastify.close())`. Clients opened in the test (for example an `undici` client) are closed in the same teardown.
- The plugin docs state the bar plainly: a plugin "**must** be thoroughly tested", and untested plugins are not accepted into the ecosystem list.

## Test layout in the repository

- Unit test files are named `*.test.js` (for example `test/hooks.test.js`, `test/internals/*.test.js`).
- Type definitions have their own tests in `test/types/*.test-d.ts`.
- Bundler tests in `test/bundler/` (webpack, esbuild) are a separate stack. Their files must be named `*-test.js`, **not** `*.test.js`, "otherwise it will be targeted by the regular expression used for unit tests". They only need to show that the build works and the app runs, and run in CI only on the Node.js LTS line.

## Performance changes

Given the "zero overhead" principle, a change that claims or risks a performance effect can be measured with the documented benchmark setup: `npm run benchmark` (autocannon), across branches with `branchcmp`, and across Node.js versions with `npx -p node@<version>`.
