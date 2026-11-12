---
id: "01a1d175-2856-793e-9d16-8422fe9d0cb1"
title: "Commit structure and Go dependency rules"
type: "Guideline"
tags:
  - "commits"
  - "dependencies"
  - "vendor"
  - "review"
created: "2026-11-12T14:31:18-06:00"
timestamp: "2026-11-12T14:31:18-06:00"
description: "Commits must build and work on their own with proper Fixes tags and sign-off, and new Go dependencies or replace directives must meet the vendor team's criteria."
x:
  paths: ["go.mod", "go.sum", "vendor/**", "pkg/**/*.go", "daemon/**/*.go", "bpf/**"]
  source: ["Documentation/contributing/development/contributing_guide.rst", "Documentation/contributing/development/reviewers_committers/review_vendor.rst", "Documentation/contributing/development/reviewers_committers/review_process.rst", "hack/custom-boilerplate.go.txt"]
---

# Commit structure and Go dependency rules

**Commit rules from the PR checklist:**
- "Each commit must compile and be functional on its own to allow for bisecting of commits."
- Each commit has a title, a description, and a `Fixes: #XXX` line if it addresses an issue, with a blank line between title and description.
- If a commit fixes a commit already in the tree, reference it as `Fixes: <first 12 chars of SHA> ("<full commit title>")`, without breaking the line, so backporters pull in all needed fixes.
- All commits are signed off (DCO, `git commit -s`), using a real name.
- PRs with more than about 200 changed lines or more than 6 commits should be considered for splitting into smaller PRs, for example separate bugfixes or self-contained refactors. Review-feedback commits are squashed into the commits they fix before merge.
- A PR that may be backported must not mix bugfixes and refactoring.

**New dependencies.** PRs touching `go.mod`, `go.sum` or `vendor/` are reviewed by the vendor team. A new dependency must:
1. add functionality not already available from, in order of preference, Go's standard library, an internal package, or an existing dependency;
2. provide functionality that is non-trivial to re-implement;
3. be actively maintained, with commits or releases in the past year;
4. be of generally good quality (strong user base, automated tests with high coverage, documentation);
5. have a CNCF-allowed license. A CI license check exists, with its allow-list in `tools/licensecheck/allowed.go`.

Updates to existing dependencies, usually opened by Renovate, are reviewed to make sure they do not bring breaking changes or licensing issues.

**Replace directives.** Replace directives in `go.mod` do not carry over to modules that import cilium/cilium, so the vendor team discourages them. A replace directive is acceptable only while a needed change is being upstreamed and a fork is used temporarily. It must have a comment above it explaining why, and an issue labeled release-blocker tracking its removal before the next release. If the change cannot be upstreamed, depend on the fork directly instead of using `replace`.

**License header.** The repository's Go boilerplate header is `// SPDX-License-Identifier: Apache-2.0` followed by `// Copyright Authors of Cilium` (`hack/custom-boilerplate.go.txt`).
