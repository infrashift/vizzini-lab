---
id: "01a1d175-ed7b-7a3d-a658-7593c8b6a783"
title: "Components (Blazor) area workflow and E2E tests"
type: "Guideline"
tags:
  - "components"
  - "blazor"
  - "testing"
  - "e2e"
created: "2026-11-12T14:32:09-06:00"
timestamp: "2026-11-12T14:32:09-06:00"
description: "Changes under src/Components need a reproduced scenario, E2E tests added to the existing test server and assets, and no leftover sample code or stray minified JS."
x:
  paths: ["src/Components/**"]
  source: ["src/Components/AGENTS.md", ".github/instructions/components.instructions.md", "docs/UpdatingMinifiedJsFiles.md"]
---

# Components (Blazor) area workflow and E2E tests

`src/Components/AGENTS.md` sets a required workflow for features and bug fixes in the Components area, and `.github/instructions/components.instructions.md` applies it to `src/Components/**`.

## Reproduce first, then fix

- For a bug, "You MUST have reproduced the problem before attempting to fix it."
- Build the scenario first in a sample project under `src/Components/Samples` (for example `BlazorUnitedApp` and `BlazorUnitedApp.Client`), develop the fix there, and validate it in a browser.
- Only after the sample works, write E2E tests.
- After the E2E tests pass, **remove the sample code**: "The sample was only for development and interactive testing; the E2E tests now provide the permanent test coverage." A PR should not leave scenario code behind in `src/Components/Samples`.

## E2E test structure

- E2E tests live in `src/Components/test/E2ETest` and run with Selenium.
- Test scenarios live in `src/Components/test/testassets`. The `Components.TestServer` project hosts several server configurations; "Avoid adding new startup files unless strictly necessary."
- Check first whether E2E tests already cover the area, and add to existing test files when possible.
- "Prefer extending existing test components and assets over creating a set of new ones if it doesn't complicate the existing ones excessively."
- Do not run all E2E tests locally; full runs belong on CI.

## Build notes that affect reviews

- A change to public APIs that other projects depend on must be checked by building the dependent projects, not only the one project (that is, not with `--no-dependencies`).
- JavaScript in `src/Components/Web.JS` is built with `npm run build`.

## Minified JS files

The minified Blazor `.js` outputs under `src/Components/Web.JS/dist/Release` are not committed directly. They are kept in a separate submodule repository (`src/submodules/BlazorMinifiedJs`) to avoid merge conflicts and to support offline source-build. A PR that changes them must first update that repository and then bump the submodule commit in the aspnetcore PR.
