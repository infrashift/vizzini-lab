---
id: "01a1d174-93f2-7bbb-8854-87d03229b447"
title: "Breaking Changes and Backward Compatibility"
type: "Guideline"
tags:
  - "compatibility"
  - "settings"
  - "migrations"
  - "review"
created: "2026-11-12T14:30:40-06:00"
timestamp: "2026-11-12T14:30:40-06:00"
description: "What the project counts as a breaking change (API output, admin settings, defaults, manual restore steps), what a breaking PR must include, and the stated rule for partial table migrations."
x:
  paths: ["routers/api/**", "modules/setting/**", "models/migrations/**", "modules/structs/**"]
  source: ["CONTRIBUTING.md", "docs/guideline-backend.md", "AGENTS.md"]
---

# Breaking Changes and Backward Compatibility

CONTRIBUTING.md defines a breaking pull request precisely. A change is breaking if it meets any of these criteria:

- It changes API output in an incompatible way for existing users.
- It removes a setting that an admin could previously set (for example via `app.ini`).
- An admin must do something manually to restore the old behavior.

The document is explicit about edge cases: **adding new settings is not breaking**, but **changing the default value of a setting, or replacing a setting with another one, is breaking**.

## What a breaking PR must contain

A breaking PR must add two things to its summary:

1. A reasoning for why the breaking change is necessary.
2. A `BREAKING` section (headed `## :warning: BREAKING :warning:`) explaining, in terms a typical user understands, how the PR affects users and how to mitigate the change.

"Breaking PRs will not be merged as long as not both of these requirements are met." The title should also mark the change as breaking with Conventional Commits syntax: a `!` immediately before the colon, as `type!:` or `type(scope)!:` (not `type!(scope):`).

## What a reviewer should check

- Edits to `modules/setting/` that rename, remove or change the default of a configuration key are breaking, even when the code change looks small.
- Edits to API structs or handlers that remove or rename fields or change status responses are breaking; the backend guideline says existing API fields should not be removed "unless there is a really good reason".
- If the change is breaking and the PR does not carry the justification and BREAKING section, it is not mergeable under the stated policy.

## Database migrations

The backend guideline's "Knowledge" section states one migration rule: a partial database table migration must use `SyncWithOptions(IgnoreDrop...)`. The docs give no further migration guidance, so reviewers should not assume other documented migration conventions.

## Related

Form handling note from the same section: template variables in "camelCase" or "snake_case" are used for restoring form values from a submitted form. See also the "API v1 Route Conventions and GitHub Compatibility" concept.
