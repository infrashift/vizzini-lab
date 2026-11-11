# UAT run 20261111T161313Z

| tool | version | commit |
|---|---|---|
| vizzini | ffe8e03 | `ffe8e0352048` |
| mrman | v0.1.1 | `a56f47e5b796` |
| garmr | bf96753 | `bf96753b9123` |
| okfw | v2026.10.2-2-g557c304 | `557c304ed561` |

Go: go version go1.27.3 linux/amd64

**Hard checks:** 132/132 passed

## Fixture: csharp-seeded (C#)

### Seeded defects

| defect | must catch | claude-opus-5-5 | claude-sonnet-5-5 |
|---|---|---|---|
| sqli | yes | ✅ Critical | ✅ Critical |
| md5 | yes | ✅ Critical | ✅ Critical |
| secret | yes | ✅ Critical | ✅ Critical |
| nullderef | yes | ✅ Major | ✅ Major |
| asyncvoid |  | ✅ Major | ✅ Major |
| syncwait |  | ✅ Major | ✅ Major |
| offbyone |  | ✅ Minor | ✅ Major |
| dispose |  | ✅ Major | ✅ Major |
| race |  | ✅ Major | ✅ Major |

### Per model

| metric | claude-opus-5-5 | claude-sonnet-5-5 |
|---|---|---|
| recall | 100% | 100% |
| category agreement (caught) | 100% | 100% |
| findings | 9 | 11 |
| Critical/Major/Minor/Trivial | 3/4/1/1 | 3/6/1/1 |
| Architecture findings | 4 | 6 |
| findings on the clean decoy | 0 | 0 |
| unmatched findings | 1 | 1 |
| risk (final/diff/model) | 92/55/92 | 95/55/95 |
| garmr | deny VZ-001,VZ-002,VZA-001 | deny VZ-001,VZ-002,VZA-001 |
| review / describe / improve / plan | 19s / 8s / 30s / 24s | 34s / 9s / 29s / 18s |
| ADO inline threads | 9 | 11 |

#### Unmatched findings: claude-opus-5-5

Not in the ground truth; judge by hand.

- src/Services/RateService.cs:7 Trivial/Maintainability: ToUsd uses no instance state

#### Unmatched findings: claude-sonnet-5-5

Not in the ground truth; judge by hand.

- src/Services/RateService.cs:7 Trivial/Maintainability: CA1822: ToUsd uses no instance state

## Fixture: ts-seeded (TypeScript)

### Seeded defects

| defect | must catch | claude-opus-5-5 | claude-sonnet-5-5 |
|---|---|---|---|
| cmdinj | yes | ✅ Critical | ✅ Critical |
| eval | yes | ✅ Critical | ✅ Critical |
| secret | yes | ✅ Critical | ✅ Critical |
| protopollution | yes | ✅ Critical | ✅ Major |
| timing |  | ✅ Major | ✅ Major |
| redos |  | ✅ Major | ✅ Major |
| floating |  | ✅ Minor | ✅ Major |
| returnawait |  | ✅ Minor | ✅ Minor |
| offbyone |  | ✅ Major | ✅ Major |
| race |  | ✅ Minor | ✅ Major |

### Per model

| metric | claude-opus-5-5 | claude-sonnet-5-5 |
|---|---|---|
| recall | 100% | 100% |
| category agreement (caught) | 100% | 100% |
| findings | 11 | 11 |
| Critical/Major/Minor/Trivial | 5/3/3/0 | 4/6/1/0 |
| Architecture findings | 5 | 5 |
| findings on the clean decoy | 0 | 0 |
| unmatched findings | 1 | 1 |
| risk (final/diff/model) | 95/57/95 | 97/57/97 |
| garmr | deny VZ-001,VZ-002,VZA-001 | deny VZ-001,VZ-002,VZA-001 |
| review / describe / improve / plan | 20s / 9s / 31s / 36s | 23s / 8s / 15s / 17s |
| ADO inline threads | 11 | 11 |

#### Unmatched findings: claude-opus-5-5

Not in the ground truth; judge by hand.

- src/webhook.ts:3 Critical/Architecture: Fail startup when WEBHOOK_SECRET is missing

#### Unmatched findings: claude-sonnet-5-5

Not in the ground truth; judge by hand.

- src/webhook.ts:3 Critical/Architecture: Empty-string fallback for the webhook HMAC secret

## Real-world commits

| model | commit | findings | C/M/m/T | chunks | risk | garmr | review |
|---|---|---|---|---|---|---|---|
| claude-opus-5-5 | large-serilog-failure-listeners | 9 | 0/3/6/0 | 2 | 99 | deny | 35s |
| claude-opus-5-5 | medium-polly-registry-cleanup | 3 | 0/0/2/1 | 1 | 86 | warn | 24s |
| claude-opus-5-5 | small-serilog-alignment-overflow | 0 | 0/0/0/0 | 1 | 11 | allow | 2s |
| claude-sonnet-5-5 | large-serilog-failure-listeners | 7 | 0/2/4/1 | 2 | 99 | deny | 27s |
| claude-sonnet-5-5 | medium-polly-registry-cleanup | 0 | 0/0/0/0 | 1 | 86 | warn | 15s |
| claude-sonnet-5-5 | small-serilog-alignment-overflow | 1 | 0/0/0/1 | 1 | 11 | allow | 10s |

### claude-opus-5-5 / large-serilog-failure-listeners

- src/Serilog/Core/Sinks/Batching/BatchingSink.cs:145 Major/Logic: Guard listener calls so a throwing listener can't break the batching loop
- src/Serilog/Core/Sinks/Batching/BatchingSink.cs:270 Major/Logic: Listener exception during Dispose skips target sink disposal
- src/Serilog/Debugging/SelfLog.cs:87 Major/Logic: Remove string.Format around already-interpolated text
- src/Serilog/Configuration/LoggerSinkConfiguration.cs:298 Minor/Maintainability: Unclosed <remarks> tag and missing <returns> in Fallible docs
- src/Serilog/Configuration/LoggerSinkConfiguration.cs:361 Minor/Logic: Partial-interface wrappers now get their own Dispose bypassed or duplicated
- src/Serilog/Core/Sinks/Batching/BatchingSink.cs:200 Minor/Logic: Reused buffer is passed to listeners and then cleared; empty notifications are emitted
- src/Serilog/Core/Sinks/Fallback/DelegatingLoggingFailureListener.cs:21 Minor/Logic: Guard fallback Emit against exceptions
- src/Serilog/Core/Sinks/Fallback/FailureListenerSink.cs:24 Minor/Logic: Possible duplicate failure reports for the same event
- src/Serilog/Core/Sinks/OptionalInterfaceForwardingSink.cs:31 Minor/Logic: Receiver not disposed if inner Dispose throws

### claude-opus-5-5 / medium-polly-registry-cleanup

- src/Polly.Core/Registry/ResiliencePipelineRegistry.cs:146 Minor/Logic: OnPipelineDisposed callbacks now fire for never-exposed pipelines
- src/Polly.Core/Registry/ResiliencePipelineRegistry.cs:146 Minor/Logic: Track discarded-component disposal so registry disposal can await it
- src/Polly.Core/Registry/ResiliencePipelineRegistry.TResult.cs:63 Trivial/Maintainability: Deduplicate race-handling logic across both registries

### claude-sonnet-5-5 / large-serilog-failure-listeners

- src/Serilog/Core/Sinks/Batching/BatchingSink.cs:145 Major/Logic: Listener exceptions can kill the batching loop
- src/Serilog/Debugging/SelfLog.cs:90 Major/Logic: Interpolated string is passed back through string.Format
- src/Serilog/Configuration/LoggerSinkConfiguration.cs:361 Minor/Logic: Wrapping condition is broader than the original and may double-dispose
- src/Serilog/Core/Sinks/Batching/BatchingSink.cs:200 Minor/Logic: DrainOnFailure drops an unreported event and sends empty or cleared buffers to the listener
- src/Serilog/Core/Sinks/Fallback/FailureListenerSink.cs:39 Minor/Logic: Listener exceptions escape from the catch block
- src/Serilog/Core/Sinks/OptionalInterfaceForwardingSink.cs:31 Minor/Logic: A throwing inner Dispose prevents the receiver from being disposed
- src/Serilog/Configuration/LoggerSinkConfiguration.cs:298 Trivial/Maintainability: Unclosed <remarks> tag in Fallible XML docs

### claude-sonnet-5-5 / small-serilog-alignment-overflow

- src/Serilog/Parsing/MessageTemplateParser.cs:155 Trivial/Maintainability: Guard depends on unseen downstream overflow logic

