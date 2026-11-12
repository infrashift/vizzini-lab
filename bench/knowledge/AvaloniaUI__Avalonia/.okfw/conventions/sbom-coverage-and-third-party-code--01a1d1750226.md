---
id: "01a1d175-0226-71af-aeec-832652ce3afa"
title: "SBOM coverage and third-party code"
type: "Guideline"
tags:
  - "security"
  - "supply-chain"
  - "sbom"
  - "licensing"
  - "review"
created: "2026-11-12T14:31:08-06:00"
timestamp: "2026-11-12T14:31:08-06:00"
description: "Every shipped NuGet package must be covered by the CycloneDX SBOM generator, new kinds of shipped dependencies require updating it, and code ported from MIT-compatible projects needs a licence header."
x:
  paths: ["nukebuild/**", "src/**", "native/**"]
  source: [".github/copilot-instructions.md", "docs/porting-code-from-3rd-party-sources.md", "SECURITY.md"]
---

# SBOM coverage and third-party code

## SBOM for shipped packages (EU Cyber Resilience Act)

The project generates a CycloneDX SBOM for each published NuGet package (`nukebuild/SbomGenerator.cs`, `CreateSbom` target) so every shipped package carries an accurate bill of materials, as EU CRA compliance requires. The review guidance asks reviewers to flag the following.

- **New shipped package.** A change that adds a NuGet package published to end users (a new packable project, or a new final package in `nukebuild/numerge.json`) must be covered by SBOM generation. Confirm that `CreateSbom` produces an SBOM for it, and call it out if the package would ship without one.
- **New kinds of shipped dependencies.** If a change alters what is delivered with a component in a way the existing scan does not understand, `nukebuild/SbomGenerator.cs` must be updated so those dependencies appear in the SBOM. Examples given:
  - adding npm/JS dependencies to a previously .NET-only component (such as a bundled web app), or changing how existing bundled JS is built;
  - bundling third-party binaries directly into a package (copy-local, ILRepack, embedded assemblies) instead of referencing them as normal NuGet dependencies;
  - new Numerge merge groups, or any other way of folding a project's output into a package other than ordinary `PackageReference`/`ProjectReference`.
- **Scope.** The SBOM covers what is *delivered* with the package ("scope of delivery", BSI TR-03183-2). Build-only and test-only tooling that is never shipped does not need to be included.

## Code ported from other projects

Code ported or adapted from projects under an MIT-compatible licence must carry an appropriate licence header in the source file. For code taken from WPF the header should say the file is adapted from the Windows Presentation Foundation project (with its URL) and is "Licensed to The Avalonia Project under MIT License, courtesy of The .NET Foundation." If the file is a port of a specific commit of a third-party file, consider including a permalink to it. Ported code without such a header is a review finding.

## Vulnerability reports

`SECURITY.md` asks that vulnerabilities be reported privately through GitHub Security Advisories or by email, not disclosed publicly before a fix. The docs give no secure-coding rules beyond the items above.
