# conventions

<!-- okfw:generated — maintained by okfw; edits here are overwritten -->

## Concepts

* [Backward compatibility, shared framework and servicing bar](backward-compatibility-shared-framework-and-servicing-bar--01a1d175ecda.md) - Breaking changes are strongly discouraged; shared-framework assemblies must never break in minor or patch releases, and patch fixes may not change public API.
* [C# coding style and nullability rules](c-coding-style-and-nullability-rules--01a1d175ed15.md) - The C# formatting, nullable-reference-type and file-protection rules the repository's own coding instructions state.
* [Components (Blazor) area workflow and E2E tests](components-blazor-area-workflow-and-e2e-tests--01a1d175ed7b.md) - Changes under src/Components need a reproduced scenario, E2E tests added to the existing test server and assets, and no leftover sample code or stray minified JS.
* [EventSource and EventCounter conventions](eventsource-and-eventcounter-conventions--01a1d175edbf.md) - Naming, visibility, payload and enablement-check rules for EventSource tracing and EventCounters in ASP.NET Core libraries.
* [Project references, dependencies and shared code](project-references-dependencies-and-shared-code--01a1d175ee58.md) - Product projects reference dependencies through Reference items managed centrally in eng/, and code under src/Shared/runtime is mirrored with dotnet/runtime.
* [Public API baselines and API review](public-api-baselines-and-api-review--01a1d175eca9.md) - Every public API addition, removal or change must be recorded in PublicAPI.Unshipped.txt and go through the API review process before it is implemented.
* [SignalR hub protocol invariants](signalr-hub-protocol-invariants--01a1d175f04e.md) - Normative MUST rules from the SignalR hub protocol specification that client and server implementations must keep.
* [Testing expectations](testing-expectations--01a1d175ed4c.md) - Every bug fix or feature needs tests that follow nearby patterns, written with xUnit v3 and Moq, and must keep the Helix CI pipelines green.
* [Trimming and Native AOT compatibility](trimming-and-native-aot-compatibility--01a1d175ee0d.md) - How trimmable ASP.NET Core assemblies are annotated, baselined and tested, and what a reviewer should expect when a change touches trim warnings.

