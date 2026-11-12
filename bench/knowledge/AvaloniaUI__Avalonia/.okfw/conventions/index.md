# conventions

<!-- okfw:generated — maintained by okfw; edits here are overwritten -->

## Concepts

* [API and binary compatibility within a major version](api-and-binary-compatibility-within-a-major-version--01a1d1750140.md) - Avalonia keeps strict source and binary compatibility within a major version, enforced by an automated API check in CI, and only allows approved breaking changes in narrow cases.
* [COM reference management in Avalonia.Native](com-reference-management-in-avalonia-native--01a1d17501ca.md) - The macOS native backend must never store raw COM pointers; retained references use ComPtr, ComObjectWeakPtr or ComStaticPtr, and avn.idl methods return interfaces through HRESULT out-parameters.
* [Coding style and PR scope](coding-style-and-pr-scope--01a1d1750187.md) - Avalonia follows the .NET Core coding style, bans #region, wants XML docs on public methods, and rejects unrelated or formatting-only changes inside a PR.
* [New controls need automation peers](new-controls-need-automation-peers--01a1d17501ac.md) - New controls should expose themselves to the operating system's accessibility APIs through an AutomationPeer, and their hard-to-unit-test behaviour should get integration tests.
* [SBOM coverage and third-party code](sbom-coverage-and-third-party-code--01a1d1750226.md) - Every shipped NuGet package must be covered by the CycloneDX SBOM generator, new kinds of shipped dependencies require updating it, and code ported from MIT-compatible projects needs a licence header.
* [Testing expectations for bug fixes and features](testing-expectations-for-bug-fixes-and-features--01a1d1750163.md) - Bug fixes should come with a failing test committed before the fix, features need unit or integration tests, and each kind of problem has its own test project.
* [Wayland backend threading and state model](wayland-backend-threading-and-state-model--01a1d17501e8.md) - The Wayland backend runs all Wayland work on a dedicated worker thread that is also the render thread, forbids shared state between it and the UI thread, and keeps persistent state so it can survive compositor restarts.
* [Wayland protocol and NWayland rules](wayland-protocol-and-nwayland-rules--01a1d1750206.md) - Rules for binding Wayland globals, handling dynamic and multiple globals, dispatching wl_pointer frames in order, and using the NWayland bindings correctly.

