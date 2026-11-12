---
id: "01a1d173-3183-7722-a442-b92298daaaa4"
title: "Backward compatibility of the Go SDK"
type: "Guideline"
tags:
  - "api"
  - "compatibility"
  - "go"
created: "2026-11-12T14:29:09-06:00"
timestamp: "2026-11-12T14:29:09-06:00"
description: "Public Go definitions under pkg/ must not change in a backward-incompatible way, while cmd/ and internal/ may change freely."
x:
  paths: ["pkg/**"]
  source: ["AGENTS.md", "CONTRIBUTING.md"]
---

# Backward compatibility of the Go SDK

Helm states "a strong commitment to backward compatibility", and both `AGENTS.md` and `CONTRIBUTING.md` single out the Go library in `pkg/`. The rules are defined in Helm Improvement Proposal HIP-0004 (backwards-compatibility rules), which the docs reference for details.

**The rule**

- "The signatures of public APIs, i.e., those in the `pkg/` directory should not change."
- The project is "committed to not changing publicly accessible Go library definitions inside of the `pkg/` directory of our source code in a non-backwards-compatible way."
- "Go libraries inside of `pkg/` MUST remain backward compatible, though code inside of `cmd/` and `internal/` may be changed from release to release without notice."
- Functional behaviour "(as implied or documented) must not be modified in a way that would break existing users' expectations." So keeping a signature while changing what the function does can still be a breaking change.

**The exception**

Incompatible changes are allowed when they are needed to fix a security vulnerability, and then only "minimal breaking changes may be made to address the issue."

**Review checklist**

- Does the diff rename, remove or change the parameters or return values of an exported function, method, type, field, constant or interface in `pkg/`? If so, it is a breaking change unless it fixes a security issue.
- Does it change documented or implied behaviour of an existing `pkg/` API in a way that would surprise current SDK users?
- New exported API in `pkg/` becomes subject to the same promise, so check that it really needs to be public rather than in `internal/`.
- Backward-incompatible issues and PRs are tracked separately for a future major version; the `breaking` label marks PRs with breaking changes such as API changes.
- The pull request template asks contributors to confirm that "this PR has been tested for backwards compatibility".
