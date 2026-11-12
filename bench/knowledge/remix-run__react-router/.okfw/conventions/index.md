# conventions

<!-- okfw:generated — maintained by okfw; edits here are overwritten -->

## Concepts

* [API Stability, Future Flags and Unstable APIs](api-stability-future-flags-and-unstable-apis--01a1d1745990.md) - Breaking changes ship behind opt-in future flags, experimental APIs ship with an unstable_ prefix, and new features move through staged governance before becoming stable.
* [Contribution Requirements for Code Changes](contribution-requirements-for-code-changes--01a1d174598a.md) - Every bug fix or feature needs tests, API changes must update docs and examples, and code changes need a changeset and target the dev branch.
* [Framework-Agnostic Router Core](framework-agnostic-router-core--01a1d1745996.md) - Routing, data loading and navigation logic live in a router core that does not depend on React, with history treated as an internal implementation detail.
* [Middleware and Context Semantics](middleware-and-context-semantics--01a1d17459af.md) - Middleware uses a type-safe context API, runs inside the default dataStrategy on the client and once per request on the server, and is data-focused rather than an event system.
* [Navigation Concurrency and Revalidation Semantics](navigation-concurrency-and-revalidation-semantics--01a1d17459a8.md) - The router mirrors browser behavior by cancelling interrupted navigations and stale revalidations, revalidates all active data after mutations, and manages history entries for form submissions.
* [Request Handling in Loaders and Actions](request-handling-in-loaders-and-actions--01a1d17459a2.md) - Requests are passed to user code uncloned, loaders get no body, cancellation uses request.signal, and deferred promises must stay trackable by the router.
* [Route Module Exports and Type Generation](route-module-exports-and-type-generation--01a1d17459b5.md) - Route modules keep separate named exports so treeshaking and HMR work, and route-specific types come from generated code for every route config.
* [Server and Client Code Separation](server-and-client-code-separation--01a1d174599c.md) - Server-only code must be excluded from client bundles by explicit marking and build-time errors, never by relying on treeshaking.

