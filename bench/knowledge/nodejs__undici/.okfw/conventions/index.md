# conventions

<!-- okfw:generated — maintained by okfw; edits here are overwritten -->

## Concepts

* [API stability, compatibility and documentation conventions](api-stability-compatibility-and-documentation-conventions--01a1d1769314.md) - How undici marks API stability, which surfaces are public, how cross-version compatibility is kept, and how API docs and types must be kept in sync with code.
* [Dispatcher and handler contract](dispatcher-and-handler-contract--01a1d1768868.md) - The low-level dispatch(options, handler) contract that every concrete dispatcher and handler in undici implements, including the controller-based handler callbacks.
* [Error classes and codes](error-classes-and-codes--01a1d1769213.md) - undici's typed error hierarchy, the stable name/code contract on each error, and why callers should match on error.code.
* [Interceptors and compose](interceptors-and-compose--01a1d17688d7.md) - How undici interceptors are shaped and composed, and the rules a custom or built-in interceptor must follow when wrapping a handler.
* [Pull request checklist and project tooling](pull-request-checklist-and-project-tooling--01a1d17687fa.md) - What undici's contribution guide and pull request template expect from every code change: tests, documentation, passing lint and tests, and stated breaking changes.
* [Response body consumption and client lifecycle](response-body-consumption-and-client-lifecycle--01a1d1768dc9.md) - undici's rules for consuming or cancelling every response body and for how Client close and destroy move through the client lifecycle.
* [Security threat model](security-threat-model--01a1d17692e8.md) - What undici trusts and does not trust, which classes of bugs it treats as vulnerabilities, and the protocol-level limits the docs document.
* [Vendored llhttp WebAssembly parser](vendored-llhttp-webassembly-parser--01a1d1769340.md) - undici's HTTP/1.1 parser is a vendored WebAssembly build of llhttp, updated by a documented copy-and-rebuild procedure rather than by editing the generated files.
* [Writing reliable tests](writing-reliable-tests--01a1d1768830.md) - Test patterns the undici docs prescribe: Node's test runner, an in-process server, cleanup via t.after, short keep-alive timeouts, and a guard against silent reconnects.

