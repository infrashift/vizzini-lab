---
id: "01a1d175-ee58-7584-bf70-40dc4561f62f"
title: "Project references, dependencies and shared code"
type: "Guideline"
tags:
  - "build"
  - "dependencies"
  - "architecture"
created: "2026-11-12T14:32:09-06:00"
timestamp: "2026-11-12T14:32:09-06:00"
description: "Product projects reference dependencies through Reference items managed centrally in eng/, and code under src/Shared/runtime is mirrored with dotnet/runtime."
x:
  paths: ["src/**/*.csproj", "eng/Dependencies.props", "eng/Versions.props", "eng/Build.props", "src/Shared/runtime/**", "src/Shared/test/Shared.Tests/runtime/**"]
  source: ["docs/ReferenceResolution.md", "docs/ProjectProperties.md", "docs/AddingNewProjects.md", "src/Shared/runtime/ReadMe.SharedCode.md", "docs/SharedFramework.md"]
---

# Project references, dependencies and shared code

## How a `.csproj` references things

`docs/ReferenceResolution.md` gives these rules for project files:

- Use `<Reference>`. The build resolves each one to the right project or package and version according to the servicing rules.
- Do **not** use `<PackageReference>`.
- Only test projects may use `<ProjectReference>`.
- A new package must be added to `eng/Dependencies.props` and `eng/Versions.props`. If a partner team ships it and its version should update automatically, it also goes in `eng/Version.Details.xml`.
- Name the `.csproj` to match the assembly name.
- Run `eng/scripts/GenerateProjectList.ps1` when adding projects.

The goals behind these rules: versions of external dependencies stay consistent and easy to find, newer packages never have lower dependency versions than earlier releases, and "servicing releases should not add or remove dependencies in existing packages." A patch-branch change that adds or removes a package dependency conflicts with that rule. Shared-framework assemblies also may not take third-party dependencies.

## Project layout and properties

- A new project lives in its own folder, with sources in a `src` subfolder (or `test` for test projects).
- A new `src` project gets `PublicAPI.Shipped.txt` and `PublicAPI.Unshipped.txt`.
- A new top-level area under `src` must also be added to `eng/Build.props`.
- Packaging is controlled by `IsPackable`, `IsShipping`, `IsShippingPackage` and `IsAspNetCoreApp`. A change to these properties changes what ships to customers.

## Code shared with dotnet/runtime

`src/Shared/runtime` (and its tests in `src/Shared/test/Shared.Tests/runtime`) holds HTTP/2 and HTTP/3 protocol infrastructure, such as the HPACK implementation, that is shared with dotnet/runtime. "Any changes to this dir need to be checked into both repositories." A sync workflow brings runtime changes into aspnetcore automatically. Changes that go from aspnetcore to runtime are copied with `CopyToRuntime` and synced manually.

`src/Shared/ServerInfrastructure` holds shared product code that the Http2Cat test framework also uses.
