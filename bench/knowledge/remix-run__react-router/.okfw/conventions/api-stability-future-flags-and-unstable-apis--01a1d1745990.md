---
id: "01a1d174-5990-739c-93c5-97140ae121ad"
title: "API Stability, Future Flags and Unstable APIs"
type: "Guideline"
tags:
  - "api"
  - "compatibility"
  - "future-flags"
  - "unstable"
created: "2026-11-12T14:30:25-06:00"
timestamp: "2026-11-12T14:30:25-06:00"
description: "Breaking changes ship behind opt-in future flags, experimental APIs ship with an unstable_ prefix, and new features move through staged governance before becoming stable."
x:
  paths: ["packages/react-router/lib/**", "packages/react-router/index.ts", "packages/react-router-dev/config/**", "packages/react-router/lib/types/future.ts"]
  source: ["docs/community/api-development-strategy.md", "docs/community/contributing.md", "GOVERNANCE.md", "docs/upgrading/future.md", "decisions/0014-context-middleware.md", "decisions/0005-remixing-react-router.md"]
---

# API Stability, Future Flags and Unstable APIs

React Router is "foundational" to applications, so the project's stated strategy is to keep major upgrades smooth while still changing behavior. The API Development Strategy doc defines the mechanisms a reviewer should check.

## Future flags for breaking changes

- "When an API changes in a breaking way, it is introduced in a future flag." Users opt in to one change at a time before it becomes the default in the next major.
- The contract: "Without enabling the future flag, nothing changes about your app"; enabling the flag changes the behavior for that feature. A change that alters default behavior without a flag breaks this contract.
- Flags are named after the target major (for example `future.v8_middleware` in `react-router.config.ts`) and every current flag is documented in the Future Flags guide.

## Unstable APIs

- Features still being designed are exposed as unstable (`unstable_` prefixed APIs, e.g. `unstable_createContext` in the middleware decision). They "will change without warning and without upgrade paths" and are not documented.
- Because they are not stable or documented, unstable features ship in SemVer patch releases. When one stabilizes into a future flag it ships in a minor and must be documented and added to the Future Flags guide.

## Governance stages

GOVERNANCE.md describes a staged process: Proposal, Consideration, Alpha (a PR implementing the feature in an "unstable" state), Beta (merged unstable API), Stabilization (at least one month in Beta, plus a PR that stabilizes the API and "should also include documentation"), and Stable. Trivial features may skip stages.

## Small APIs and deprecation

- The contributing guide says "small APIs are usually better" and the team is reluctant to add API without an obvious limitation in the current one.
- Past decisions show the preferred pattern for renames and removals: keep the old API in a deprecated form that maps to the new one (e.g. `useTransition` kept as a deprecated wrapper over `useNavigation`), and make new props optional with defaults that preserve old behavior (e.g. `<ScrollRestoration getKey>` defaulting to `location.key`).
