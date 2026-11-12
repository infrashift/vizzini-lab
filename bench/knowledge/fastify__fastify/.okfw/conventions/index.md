# conventions

<!-- okfw:generated — maintained by okfw; edits here are overwritten -->

## Concepts

* [Contribution and Code Style Rules](contribution-and-code-style-rules--01a1d1759f25.md) - Ground rules every Fastify core change must meet before merge: StandardJS style, green tests and CI, review for API changes, and no version bumps.
* [Decorators and Object Shape](decorators-and-object-shape--01a1d1759fbe.md) - Rules for decorate, decorateRequest and decorateReply: declare shape up front, never share reference types across requests, and keep decoration synchronous.
* [Encapsulation and Plugin Scope](encapsulation-and-plugin-scope--01a1d1759f96.md) - How register() creates encapsulated child contexts, when fastify-plugin is the right way to break encapsulation, and the plugin rules a reviewer should check.
* [Error Handling Conventions](error-handling-conventions--01a1d17612a6.md) - How Fastify expects errors to be raised, coded, propagated through encapsulated error handlers, and documented.
* [Hooks and Async Control Flow](hooks-and-async-control-flow--01a1d1761277.md) - Rules for callback versus async hooks and handlers, early replies, and per-hook contracts that prevent double execution and race conditions.
* [Technical Principles](technical-principles--01a1d1759f60.md) - The ten technical principles that guide every Fastify design decision, and what each one means for a code change under review.
* [Testing Expectations](testing-expectations--01a1d1770510.md) - What the docs require of tests for a Fastify change: passing suites and green CI, node:test with inject(), clean teardown, the bundler and type test stacks, and benchmarks for performance claims.
* [Untrusted Input, Validation and Parsing Security](untrusted-input-validation-and-parsing-security--01a1d176b80e.md) - Fastify's threat model and the security rules for body parsing, JSON handling, schema validation and serialization that a change to the request path must preserve.
* [Warnings and Deprecation Policy](warnings-and-deprecation-policy--01a1d1772359.md) - How Fastify announces deprecated behaviour with FSTDEP and FSTWRN process warnings, documents them, and removes them only at the next major under semver and LTS.

