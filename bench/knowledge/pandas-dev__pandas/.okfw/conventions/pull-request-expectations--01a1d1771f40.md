---
id: "01a1d177-1f40-7d60-bb25-6f5c9fa98b42"
title: "Pull request expectations"
type: "Guideline"
tags:
  - "process"
  - "performance"
  - "review"
created: "2026-11-12T14:33:27-06:00"
timestamp: "2026-11-12T14:33:27-06:00"
description: "What a pandas pull request is expected to carry: a linked issue, tests, a release note, benchmark evidence where performance matters, and disclosure of any AI tool use."
x:
  paths: ["pandas/**/*.py", "pandas/_libs/**", "asv_bench/benchmarks/**/*.py", "doc/source/whatsnew/*.rst"]
  source: ["doc/source/development/contributing.rst", "doc/source/development/contributing_codebase.rst", ".github/PULL_REQUEST_TEMPLATE.md", "AGENTS.md"]
---

# Pull request expectations

## Scope and checklist

The contributing guide and PR template ask that a pull request:

- Is linked to the issue it resolves (for example `closes #<issue>`), and that issue must be assigned to the contributor; only trivial changes such as typo fixes may skip the issue.
- Includes tests when fixing a bug or adding a feature, and passes all code checks with CI green.
- Adds type annotations to new arguments, methods and functions.
- Is kept "as simple as possible", because larger PRs take longer to review.

## Release notes

Bug fixes, enhancements and unavoidable breaking changes get an entry in the current `doc/source/whatsnew/vX.Y.Z.rst`, written in full sentences, with the issue number via the `:issue:` role and API references via `:func:`, `:meth:` or `:class:`. Bug-fix entries go in the relevant bug-fix section, rarely in "Other", and should say how a user meets the bug and what goes wrong (for example "produces incorrect results" or "incorrectly raises"). Enhancements usually also need usage examples in the docs and a `versionadded` directive.

## Performance

"Performance matters", and contributors should consider whether a change introduced a regression. Benchmarks are asv benchmarks under `asv_bench/benchmarks`. The guide suggests running `asv continuous -f 1.1 upstream/main HEAD` (optionally limited with `-b`), reporting benchmarks that changed by more than 10%, and pasting a relevant subset of results into the PR to show there is no unexpected regression.

## Automated contributions policy

AI coding assistants may be used responsibly, under rules the docs state as "must":

- Disclose that an automated tool was used, and be specific: the tool, model and version, and any effort setting. The PR template has an explicit checkbox for this.
- Fully review and modify the tool's output, and make sure the contribution follows all documented pandas conventions.
- Do not use AI to speak for you in issues, PRs or review comments (translation and grammar help is allowed, with disclosure). Quoted AI output must be marked with `>` or a code fence.

Maintainers may reject contributions that do not follow the policy and may ban repeat violators. The repository's `AGENTS.md` additionally tells agents never to push, open, or comment on issues or PRs on the upstream repository on the user's behalf.
