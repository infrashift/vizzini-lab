---
id: "01a1d175-0140-70d7-b47e-d7752428163d"
title: "API and binary compatibility within a major version"
type: "Guideline"
tags:
  - "api-compat"
  - "breaking-changes"
  - "review"
created: "2026-11-12T14:31:08-06:00"
timestamp: "2026-11-12T14:31:08-06:00"
description: "Avalonia keeps strict source and binary compatibility within a major version, enforced by an automated API check in CI, and only allows approved breaking changes in narrow cases."
x:
  paths: ["src/**", "api/**"]
  source: ["docs/api-compat.md", "CONTRIBUTING.md", ".github/PULL_REQUEST_TEMPLATE.md", "build/ApiCompatAttributeExcludeList.txt"]
---

# API and binary compatibility within a major version

Avalonia maintains strict **source and binary compatibility** within major versions. An automated API compatibility check runs on every CI build, and the build fails if a breaking change is detected (`docs/api-compat.md`, `CONTRIBUTING.md`).

## What a reviewer should check

- **No source or binary breaks during a major release cycle.** Removing or renaming public members, changing signatures, and similar changes to public API are not allowed unless one of the exceptions below applies and the core team has approved it.
- **Exceptions that may be approved** (approval by the core team is required in all cases):
  - the `master` branch is targeting a new major version;
  - the code was exposed as public API by accident and is unlikely to have external users;
  - the API is explicitly marked as unstable or experimental.
- **Suppression file changes.** When a break is approved, CI is bypassed by regenerating the API suppression file (`nuke --update-api-suppression true`) and committing it in a **separate commit**. The docs say the suppression file should only be updated after the break has been reviewed and approved, so a PR that edits files under `api/` without a recorded approval deserves a question.
- **Deferring a break.** If something should change at the next major release, leave a `TODOXX:` comment where `XX` is the next major version number (for example `TODO12:`) instead of breaking now.
- **Behavioral breaks.** These are not caught by the tool. Contributors are asked to consider them carefully and to point them out in the PR description; the PR template has a "Breaking changes" section for this.
- **Obsoletions.** The PR template says `Obsolete` and deprecation attributes on APIs MUST only be added when discussed with the core team.

## Baseline

Compatibility is checked against a baseline version, by default the first release of the current major version (for 11.0.5 the baseline is 11.0.0). It can be overridden with the `api-baseline` nuke parameter and otherwise falls back to the version in `SharedVersion.props`.

The repository's `build/ApiCompatAttributeExcludeList.txt` lists `Avalonia.Metadata.NotClientImplementableAttribute` and `Avalonia.Metadata.UnstableAttribute`, the metadata attributes that relate to which APIs carry compatibility promises; the docs do not describe their use in more detail.
