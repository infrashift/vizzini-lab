# conventions

<!-- okfw:generated — maintained by okfw; edits here are overwritten -->

## Concepts

* [Adding New Modules, Globals, and Native APIs](adding-new-modules-globals-and-native-apis--01a1d1757d8e.md) - New core modules, global-scope APIs and Node-API additions have stricter labeling, flagging and review requirements than ordinary changes.
* [C++ Style Rules for src](c-style-rules-for-src--01a1d1757dda.md) - Node.js-specific C++ formatting, naming, ownership and casting rules that cpplint does not enforce and reviewers check by hand.
* [Explicit Resource Management Disposers](explicit-resource-management-disposers--01a1d1757f07.md) - Rules for implementing and using Symbol.dispose and Symbol.asyncDispose on core objects.
* [Internal Errors and Error Codes](internal-errors-and-error-codes--01a1d1757cd7.md) - Errors thrown by Node.js APIs must come from internal/errors with a permanent code, be documented in errors.md, and be tested by code rather than message.
* [Primordials and Prototype-Pollution Safety in lib](primordials-and-prototype-pollution-safety-in-lib--01a1d1757c76.md) - Core JavaScript in lib/ should use primordials and avoid implicit calls to user-mutable built-ins, except where hot-path performance is explicitly favored.
* [Public vs Internal API, Breaking Changes, and Deprecations](public-vs-internal-api-breaking-changes-and-deprecations--01a1d1757d24.md) - Rules for what counts as public API, what makes a change semver-major, and how deprecations must progress.
* [Security Threat Model for Reviewing Changes](security-threat-model-for-reviewing-changes--01a1d1757ec9.md) - What Node.js trusts and does not trust, used to judge whether a change opens a vulnerability.
* [Test Expectations for Changes](test-expectations-for-changes--01a1d1757e7f.md) - Every fix and feature needs a focused test in test/ that follows the common-module conventions and avoids sources of flakiness.
* [V8 Handles, Maybe Values, and Environment Cleanup in C++](v8-handles-maybe-values-and-environment-cleanup-in-c--01a1d1757e37.md) - Correctness rules for V8 handles, empty Maybe results, BaseObject lifetimes, libuv handles/requests and calling into JavaScript from src/.

