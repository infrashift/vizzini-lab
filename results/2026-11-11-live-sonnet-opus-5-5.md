# UAT run 20261111T142959Z

| tool | version | commit |
|---|---|---|
| vizzini | b8c014e | `b8c014eeafbe` |
| mrman | 836f5b3 | `836f5b368cad` |
| garmr | bf96753 | `bf96753b9123` |
| okfw | v2026.10.2-2-g557c304 | `557c304ed561` |

Go: go version go1.27.3 linux/amd64

**Hard checks:** 86/86 passed

## Seeded defects

| defect | must catch | claude-opus-5-5 | claude-sonnet-5-5 |
|---|---|---|---|
| sqli | yes | ✅ Critical | ✅ Critical |
| md5 | yes | ✅ Critical | ✅ Critical |
| secret | yes | ✅ Critical | ✅ Critical |
| nullderef | yes | ✅ Major | ✅ Major |
| asyncvoid |  | ✅ Major | ✅ Major |
| syncwait |  | ✅ Major | ✅ Major |
| offbyone |  | ✅ Major | ✅ Major |
| dispose |  | ✅ Major | ✅ Major |
| race |  | ✅ Critical | ✅ Critical |

## Per model

| metric | claude-opus-5-5 | claude-sonnet-5-5 |
|---|---|---|
| recall | 100% | 100% |
| category agreement (caught) | 100% | 100% |
| findings | 14 | 12 |
| Critical/Major/Minor/Trivial | 4/6/3/1 | 4/6/1/1 |
| Architecture findings | 4 | 3 |
| findings on the clean decoy | 0 | 0 |
| unmatched findings | 1 | 1 |
| risk (final/diff/model) | 95/49/95 | 95/49/95 |
| garmr | deny VZ-001,VZ-002,VZA-001 | deny VZ-001,VZ-002,VZA-001 |
| review / describe / improve / plan | 26s / 8s / 16s / 24s | 34s / 10s / 26s / 20s |
| ADO inline threads | 14 | 12 |

### Unmatched findings: claude-opus-5-5

Not in the ground truth; judge by hand.

- src/Services/RateService.cs:7 Trivial/Maintainability: Address CA1822 by injecting HttpClient

### Unmatched findings: claude-sonnet-5-5

Not in the ground truth; judge by hand.

- src/Services/RateService.cs:7 Trivial/Maintainability: ToUsd does not use instance state (CA1822)

## Real-world commits

| model | commit | findings | C/M/m/T | chunks | risk | garmr | review |
|---|---|---|---|---|---|---|---|
| claude-opus-5-5 | large-serilog-failure-listeners | 10 | 0/4/5/1 | 2 | 99 | deny | 42s |
| claude-opus-5-5 | medium-polly-registry-cleanup | 2 | 0/0/1/1 | 1 | 80 | warn | 19s |
| claude-opus-5-5 | small-serilog-alignment-overflow | 0 | 0/0/0/0 | 1 | 8 | allow | 2s |
| claude-sonnet-5-5 | large-serilog-failure-listeners | 8 | 0/1/7/0 | 2 | 99 | deny | 24s |
| claude-sonnet-5-5 | medium-polly-registry-cleanup | 1 | 0/0/1/0 | 1 | 80 | warn | 25s |
| claude-sonnet-5-5 | small-serilog-alignment-overflow | 0 | 0/0/0/0 | 1 | 8 | allow | 2s |

### claude-opus-5-5 / large-serilog-failure-listeners

- src/Serilog/Configuration/LoggerSinkConfiguration.cs:279 Major/Logic: Primary/intermediate sinks may never be disposed in FallbackChain
- src/Serilog/Core/Sinks/Batching/BatchingSink.cs:145 Major/Logic: Guard against exceptions thrown by the failure listener
- src/Serilog/Core/Sinks/Batching/BatchingSink.cs:145 Major/Logic: Listener receives a live, mutable batch that is cleared afterwards
- src/Serilog/Debugging/SelfLog.cs:87 Major/Logic: Stop passing interpolated text to string.Format
- src/Serilog/Configuration/LoggerSinkConfiguration.cs:361 Minor/Logic: Disposable wrappers now get re-wrapped and lose their own disposal
- src/Serilog/Core/Sinks/Batching/BatchingSink.cs:50 Minor/Maintainability: Self-log messages lose target-sink context
- src/Serilog/Core/Sinks/Batching/BatchingSink.cs:219 Minor/Logic: Failure reported even when no events were drained
- src/Serilog/Core/Sinks/Fallback/DelegatingLoggingFailureListener.cs:21 Minor/Logic: Fallback emission failures are unhandled and unreported
- src/Serilog/Core/Sinks/OptionalInterfaceForwardingSink.cs:31 Minor/Logic: Receiver disposal skipped if wrapper dispose throws; possible double dispose
- src/Serilog/Configuration/LoggerSinkConfiguration.cs:298 Trivial/Maintainability: Unclosed <remarks> tag and missing <returns> in XML docs

### claude-opus-5-5 / medium-polly-registry-cleanup

- src/Polly.Core/Registry/ResiliencePipelineRegistry.cs:133 Minor/Maintainability: Extract the duplicated race-and-discard logic
- test/Polly.Core.Tests/Issues/IssuesTests.DiscardedRegistryPipelines_3286.cs:21 Trivial/Maintainability: Avoid disposing the registry twice in the test

### claude-sonnet-5-5 / large-serilog-failure-listeners

- src/Serilog/Debugging/SelfLog.cs:90 Major/Logic: Fully interpolated text is passed to string.Format as a format string
- src/Serilog/Configuration/LoggerSinkConfiguration.cs:272 Minor/Logic: Null elements in callback array not validated
- src/Serilog/Configuration/LoggerSinkConfiguration.cs:298 Minor/Maintainability: Unclosed <remarks> tag and missing <returns> in Fallible docs
- src/Serilog/Configuration/LoggerSinkConfiguration.cs:361 Minor/Logic: Wrap now wraps wrappers that already implement some optional interfaces
- src/Serilog/Core/Sinks/Batching/BatchingSink.cs:145 Minor/Logic: Live mutable _currentBatch handed to failure listener
- src/Serilog/Core/Sinks/Batching/BatchingSink.cs:200 Minor/Logic: DrainOnFailure reuses the buffer, emits empty reports, and can lose events silently
- src/Serilog/Core/Sinks/Fallback/DelegatingLoggingFailureListener.cs:23 Minor/Logic: Fallback sink exceptions are unhandled and abort the remaining events
- src/Serilog/Core/Sinks/OptionalInterfaceForwardingSink.cs:31 Minor/Logic: Receiver is not disposed if the inner sink's Dispose throws

### claude-sonnet-5-5 / medium-polly-registry-cleanup

- src/Polly.Core/Registry/ResiliencePipelineRegistry.cs:146 Minor/Logic: Fire-and-forget disposal of discarded component can fault unobserved and outlive the registry

