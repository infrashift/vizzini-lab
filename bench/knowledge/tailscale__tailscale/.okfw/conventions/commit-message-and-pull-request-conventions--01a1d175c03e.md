---
id: "01a1d175-c03e-7449-9f52-68c3a31e9b06"
title: "Commit message and pull request conventions"
type: "Guideline"
tags:
  - "commits"
  - "process"
  - "style"
created: "2026-11-12T14:31:57-06:00"
timestamp: "2026-11-12T14:31:57-06:00"
description: "Tailscale commits use Go/Linux-style \"pkg/path: imperative verb\" subjects, a Fixes or Updates line, Signed-off-by, and no fixup commits; each commit in a PR must be logically separate and pass tests."
x:
  paths: ["cmd/**", "ipn/**", "net/**", "wgengine/**", "feature/**", "tsnet/**", "derp/**", "control/**", "util/**", "types/**"]
  source: ["docs/commit-messages.md", ".github/CONTRIBUTING.md", "README.md"]
---

# Commit message and pull request conventions

The project uses Go and Linux kernel commit message style, and explicitly does **not** use Conventional Commits or Semantic Commits, for consistency.

## Subject line

Shape: `net/http: handle foo when bar`.

- Before the colon: the primary affected directory or directories from the repo root (for example `derp/derphttp:`). Many packages can be shortened to top-level names (`derp,magicsock:`), and `{foo,bar}` may group subpackages.
- After the colon: a lowercase verb, ideally imperative ("fix the foobar feature"), not past tense, not `-ing`, not a noun phrase or adjective.
- No trailing period, one space after the colon and none before it.
- As short as possible; many tools prefer under about 76 characters.
- `Fixes #123` does not belong in the subject.

## Body

- Blank line after the subject; wrap at about 76 characters unless longer lines are really needed.
- Every non-cleanup commit needs a `Fixes` or `Updates` line linking to a tracking bug, after the body and separated by a blank line. Only the verbs `Fixes` and `Updates` are used (not `Close`, `Resolves` or `For`). Cross-repo references are fully qualified (`Fixes tailscale/corp#1234`).
- `Updates #cleanup` is only for real cleanups: typo fixes in internal comments, mechanical replacement of a deprecated API with an equivalent one, code movement, removal of dead code that changes no behavior, refactoring in preparation for another change, adding a test that was simply missing, and missed formatting. Panics, customer reports, incidents, behavior changes, constant or parameter tweaks, regression fixes, security fixes or hardening, and feature-flag removal are not cleanups.
- Include `Change-Id` lines (the repo's git hooks add them: `./tool/go run misc/add-git-hooks.go`).
- No Markdown links in commit messages.
- `Signed-off-by` (DCO) is required in public repos such as `tailscale/tailscale` (`git commit -s`).
- When moving code between repos, name the source or target repo and git hash.
- Significant bug fixes or new features may add `RELNOTE: <summary>` near the end.

## Pull requests and history

- File a bug first and explain the problem; for new or changed functionality, agree on the design before writing much code.
- Squash review edits and force-push. Multiple commits in one PR are fine only if each is logically separate and "all tests pass at each stage." No fixup commits: "the history should always bisect to a clean, working tree." A PR with several commits should say so in its body.
- The PR title should match the first commit's subject line.
- Reverts must explain **why**, with a link to the issue. Do not revert a revert; send the change again and reference the original and the revert.
