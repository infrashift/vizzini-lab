---
id: "01a1d175-ee0d-790c-a083-9e3d56d8f5d4"
title: "Trimming and Native AOT compatibility"
type: "Guideline"
tags:
  - "trimming"
  - "aot"
  - "performance"
created: "2026-11-12T14:32:09-06:00"
timestamp: "2026-11-12T14:32:09-06:00"
description: "How trimmable ASP.NET Core assemblies are annotated, baselined and tested, and what a reviewer should expect when a change touches trim warnings."
x:
  paths: ["src/**/*.WarningSuppressions.xml", "src/**/*.TrimmingTests.proj", "src/**/*.NativeAotTests.proj", "eng/TrimmableProjects.props", "src/Tools/LinkabilityChecker/**"]
  source: ["docs/Trimming.md", "docs/AddingNewProjects.md"]
---

# Trimming and Native AOT compatibility

An assembly that supports trimming knows every type and member it needs at runtime, and the docs describe trimming as a precursor to supporting Native AOT. `docs/Trimming.md` sets these rules.

## Making an assembly trimmable

- Annotate assemblies **bottom up**. Annotating an assembly affects its dependents, so lower-level assemblies go first (for example `Http.Abstractions` before `Http`).
- Set `<IsTrimmable>true</IsTrimmable>` in the project and run `eng/scripts/GenerateProjectList.ps1` so that `eng/TrimmableProjects.props` is updated.
- Add the project to `LinkabilityChecker` (`src/Tools/LinkabilityChecker`). A single assembly built on its own lacks enough type information to produce every warning. LinkabilityChecker runs on the build server and catches new trim warnings that ordinary development work introduces into already-annotated assemblies.

## Warnings and baselines

Fix trim warnings with the attributes described in the .NET trimming documentation, which can add type information, suppress a warning, or mark an API as incompatible with trimming. Known warnings are baselined in each project's `*.WarningSuppressions.xml`, which is regenerated with `dotnet build /p:GenerateLinkerWarningSuppressions=true`. The generated file sometimes writes compiler-generated nested type names with `{...}` instead of `<...>`, and these need to be fixed by hand.

## Trimming tests

Trimming happens only at publish, so these tests are not ordinary xUnit tests:

- A test project is named `*.TrimmingTests.proj` (or `*.NativeAotTests.proj` for Native AOT) and lists `TestConsoleAppSourceFiles`. It is added to `eng/RequiresDelayedBuildProjects.props` so that it builds after the main build.
- Each test is a C# program that exits with code **100** on success. Any other exit code, or a crash, is a failure.
- A test that checks a type *was* trimmed should have a dual test showing the type is preserved in another scenario, so that a typo in the type name cannot make it pass by accident.
- Pass an assembly-qualified name to `Type.GetType`, and suppress IL2057 with `[UnconditionalSuppressMessage]` and a justification.
- Tests that use JSON serialization will probably need to disable the `System.Text.Json.JsonSerializer.IsReflectionEnabledByDefault` feature switch.
- New test files need the copyright header.
