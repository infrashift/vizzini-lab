# UAT run 20261111T173847Z

| tool | version | commit |
|---|---|---|
| vizzini | f1703d2 | `f1703d25405d` |
| mrman | v0.1.1 | `a56f47e5b796` |
| garmr | bf96753 | `bf96753b9123` |
| okfw | v2026.10.2-2-g557c304 | `557c304ed561` |

Go: go version go1.27.3 linux/amd64

**Hard checks:** 72/72 passed

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
| findings | 11 | 10 |
| Critical/Major/Minor/Trivial | 3/4/3/1 | 3/5/2/0 |
| Architecture findings | 4 | 5 |
| findings on the clean decoy | 0 | 0 |
| unmatched findings | 1 | 0 |
| risk (final/diff/model) | 92/55/92 | 96/55/96 |
| garmr | deny VZ-001,VZ-002,VZA-001 | deny VZ-001,VZ-002,VZA-001 |
| review / describe / improve / plan | 28s / 10s / 14s / 25s | 31s / 9s / 34s / 16s |
| ADO inline threads | – | – |

#### Unmatched findings: claude-opus-5-5

Not in the ground truth; judge by hand.

- src/Services/RateService.cs:7 Trivial/Maintainability: Lint CA1822 will resolve once HttpClient is injected

## Fixture: ts-seeded (TypeScript)

### Seeded defects

| defect | must catch | claude-opus-5-5 | claude-sonnet-5-5 |
|---|---|---|---|
| cmdinj | yes | ✅ Critical | ✅ Critical |
| eval | yes | ✅ Critical | ✅ Critical |
| secret | yes | ✅ Critical | ✅ Critical |
| protopollution | yes | ✅ Major | ✅ Major |
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
| Critical/Major/Minor/Trivial | 4/4/3/0 | 4/6/1/0 |
| Architecture findings | 5 | 5 |
| findings on the clean decoy | 0 | 0 |
| unmatched findings | 1 | 1 |
| risk (final/diff/model) | 96/57/96 | 95/57/95 |
| garmr | deny VZ-001,VZ-002,VZA-001 | deny VZ-001,VZ-002,VZA-001 |
| review / describe / improve / plan | 19s / 9s / 17s / 20s | 18s / 8s / 22s / 18s |
| ADO inline threads | – | – |

#### Unmatched findings: claude-opus-5-5

Not in the ground truth; judge by hand.

- src/webhook.ts:3 Critical/Architecture: Fail startup when WEBHOOK_SECRET is missing

#### Unmatched findings: claude-sonnet-5-5

Not in the ground truth; judge by hand.

- src/webhook.ts:3 Critical/Architecture: Empty-string fallback for the webhook HMAC secret

