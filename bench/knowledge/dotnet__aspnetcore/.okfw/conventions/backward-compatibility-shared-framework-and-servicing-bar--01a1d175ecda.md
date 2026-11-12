---
id: "01a1d175-ecda-75e5-a871-3db5955eed21"
title: "Backward compatibility, shared framework and servicing bar"
type: "Guideline"
tags:
  - "compatibility"
  - "breaking-changes"
  - "servicing"
created: "2026-11-12T14:32:08-06:00"
timestamp: "2026-11-12T14:32:08-06:00"
description: "Breaking changes are strongly discouraged; shared-framework assemblies must never break in minor or patch releases, and patch fixes may not change public API."
x:
  paths: ["src/**", "eng/SharedFramework.Local.props", "eng/SharedFramework.External.props"]
  source: ["docs/SharedFramework.md", "docs/Servicing.md", "CONTRIBUTING.md", ".github/PULL_REQUEST_TEMPLATE/servicing.md", "docs/ProjectProperties.md", "docs/AddingNewProjects.md"]
---

# Backward compatibility, shared framework and servicing bar

## General contribution bar

CONTRIBUTING.md lists "changes that break backward compatibility" first among the kinds of PR that are less likely to be merged. It also names changes wanted by only one person or company, entirely new feature areas without prior agreement, PRs that are mostly refactoring or code style, and very large PRs. A PR should be "small, focused, and avoid making unrelated changes."

## Shared framework (`Microsoft.AspNetCore.App`)

Assemblies with `<IsAspNetCoreApp>true</IsAspNetCoreApp>` are part of the shared framework, which the docs call the ASP.NET Core *platform*. Rules for it:

- "Breaking changes are highly discouraged." The API of every shared-framework assembly "MUST NOT make breaking changes in patch or minor releases."
- What goes in must be broadly useful and supported for several years.
- The complete closure of dependencies must be in the shared framework or in `Microsoft.NETCore.App`. There are no third-party dependencies, and every package must be fully serviceable by Microsoft.
- Code must be open source and buildable with only open-source tools.

Adding a project to the shared framework also means regenerating the project lists with `eng/scripts/GenerateProjectList.ps1` and adding the project, in alphabetical order, to the lists in `src/Framework/test/TestData.cs`. A CI test fails if this is missed.

## Servicing (patch) changes

Changes that target `release/*` branches must meet the servicing bar. All of the following are expected:

- The fix impacts a significant number of users and has no suitable workaround.
- It **does not change public API**. "Applications should be binary-compatible with all patches for a given major.minor version."
- Behavioral changes only fix unexpected exceptions, failures or crashes, or sit behind opt-in configuration. In rare high-value cases a change may be on by default, but it must then provide an opt-out to restore the previous behavior.

Infrastructure and test-only fixes are generally acceptable. Servicing PRs use a template that asks for customer impact, whether the change is a regression, a risk level with justification, verification (manual verification is required), and whether packaging changes were reviewed.
