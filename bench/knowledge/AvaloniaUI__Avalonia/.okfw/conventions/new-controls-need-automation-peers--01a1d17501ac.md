---
id: "01a1d175-01ac-765c-b5dc-789e36594cfb"
title: "New controls need automation peers"
type: "Guideline"
tags:
  - "controls"
  - "accessibility"
  - "review"
created: "2026-11-12T14:31:08-06:00"
timestamp: "2026-11-12T14:31:08-06:00"
description: "New controls should expose themselves to the operating system's accessibility APIs through an AutomationPeer, and their hard-to-unit-test behaviour should get integration tests."
x:
  paths: ["src/Avalonia.Controls/**", "src/**/Automation/Peers/**", "tests/Avalonia.IntegrationTests.Appium/**", "samples/IntegrationTestApp/**"]
  source: ["CONTRIBUTING.md", ".github/PULL_REQUEST_TEMPLATE.md", "tests/Avalonia.IntegrationTests.Appium/readme.md", "docs/macos-native.md"]
---

# New controls need automation peers

`CONTRIBUTING.md` lists what a feature PR that **introduces a new control** should consider. These are the points a reviewer can check on such a PR.

## Accessibility

Ideally the control should be exposed to the operating system's automation and accessibility APIs by writing an `AutomationPeer`. In the repository, peers live in `Automation/Peers` folders next to the controls they describe, for example `src/Avalonia.Controls/Automation/Peers/ButtonAutomationPeer.cs`, and derive from the base in `src/Avalonia.Controls/Automation/Peers/AutomationPeer.cs`. A new control without a peer is worth asking about. The guide says "ideally", so it is a strong expectation rather than a hard rule.

## Tests

- If the control brings functionality that is difficult to unit test, an integration test should be written.
- Integration tests live in `tests/Avalonia.IntegrationTests.Appium` and drive `samples/IntegrationTestApp`. They should be run on both Windows (WinAppDriver) and macOS (Appium).
- On macOS the test app must be rebuilt as an app bundle (`samples/IntegrationTestApp/bundle.sh`) after each change to Avalonia or the test app. The macOS developer notes add that macOS accessibility testing with Xcode's Accessibility Inspector also needs the app to run as a bundle.

## Documentation

- Public methods should have XML documentation, and the PR template asks contributors to add XML docs to related classes.
- The PR template also suggests opening a matching PR on the separate `avalonia-docs` repository with user documentation.

## Prior discussion

A new control is a feature. Features should be discussed with the core team in an issue before a PR is opened.
