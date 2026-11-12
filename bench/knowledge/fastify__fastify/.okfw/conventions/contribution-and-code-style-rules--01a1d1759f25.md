---
id: "01a1d175-9f25-765a-9f63-61cd781e65af"
title: "Contribution and Code Style Rules"
type: "Guideline"
tags:
  - "fastify"
  - "contributing"
  - "style"
  - "review"
created: "2026-11-12T14:31:49-06:00"
timestamp: "2026-11-12T14:31:49-06:00"
description: "Ground rules every Fastify core change must meet before merge: StandardJS style, green tests and CI, review for API changes, and no version bumps."
x:
  paths: ["lib/**", "fastify.js", "fastify.d.ts", "types/**", "test/**", "build/**"]
  source: ["CONTRIBUTING.md", "docs/Guides/Contributing.md", "docs/Guides/Write-Plugin.md"]
---

# Contribution and Code Style Rules

These are the rules the project's contributor docs state for any pull request against core.

## Code style

- Code is formatted with [StandardJS](https://standardjs.com). The informal contributing guide warns that some popular auto-formatters "do not follow a style that conforms to this project's styles", so a diff that reformats code away from StandardJS is a problem.
- "Contributors should attempt to adhere to the prevailing code style." A change should look like the code around it.
- The recommended editor setup runs ESLint as the JavaScript formatter, so lint is the arbiter of style, not personal preference.

## Merge conditions

- The contribution must pass all tests: "If there are test failures, you will need to address them before we can merge your contribution."
- "All integrated CI services must be green before a pull request can be merged."
- At least two contributors, or one core member, must approve.
- SemVer-major changes must be merged by a lead maintainer.

## Scope of a change

- "External API changes and significant modifications" should go through an internal pull request so other contributors can give feedback. A reviewer should flag public API changes that arrive without that discussion.
- Major contributions such as new features should start with an issue; minor ones (typo fixes) can go straight to a pull request.
- "Do not bump version numbers in pull requests." Releases are the prerogative of the lead maintainers, so edits to the `version` field in `package.json` do not belong in a feature or fix PR.

## Version branches

Every major version has its own branch (`1.x` through `4.x`; current work is on `main`). Changes meant for an older line must be based on that line's branch. See "Warnings and Deprecation Policy" for how breaking changes are staged.

## Plugins

Official plugins follow the same rules with small adjustments: semver versioning, Node.js compatibility matching Fastify's main branch, and bot PRs merged only with green CI.
