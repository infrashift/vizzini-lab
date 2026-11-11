# UAT run 20261111T175706Z

| tool | version | commit |
|---|---|---|
| vizzini | 3843b53 | `3843b53e3f4a` |
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
| race |  | ✅ Critical | ✅ Major |

### Per model

| metric | claude-opus-5-5 | claude-sonnet-5-5 |
|---|---|---|
| recall | 100% | 100% |
| category agreement (caught) | 100% | 100% |
| findings | 11 | 9 |
| Critical/Major/Minor/Trivial | 4/4/2/1 | 3/5/1/0 |
| Architecture findings | 4 | 5 |
| findings on the clean decoy | 0 | 0 |
| unmatched findings | 1 | 0 |
| risk (final/diff/model) | 95/55/95 | 96/55/96 |
| garmr | deny VZ-001,VZ-002,VZA-001 | deny VZ-001,VZ-002,VZA-001 |
| review / describe / improve / plan | 25s / 8s / 16s / 25s | 27s / 9s / 38s / 17s |
| ADO inline threads | – | – |
| review tokens in/out (cached) | 4850/2856 (0) | 4850/4055 (0) |
| review cost (proxy-reported) | $0.0765 | $0.0503 |
| review repairs / retries | 0/0 | 0/0 |

#### Unmatched findings: claude-opus-5-5

Not in the ground truth; judge by hand.

- src/Services/RateService.cs:7 Trivial/Maintainability: Resolve CA1822 by injecting HttpClient

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
| returnawait |  | ✅ Minor | ✅ Major |
| offbyone |  | ✅ Major | ✅ Major |
| race |  | ✅ Minor | ✅ Minor |

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
| risk (final/diff/model) | 95/57/95 | 95/57/95 |
| garmr | deny VZ-001,VZ-002,VZA-001 | deny VZ-001,VZ-002,VZA-001 |
| review / describe / improve / plan | 17s / 8s / 15s / 27s | 19s / 8s / 24s / 17s |
| ADO inline threads | – | – |
| review tokens in/out (cached) | 3582/2169 (0) | 3582/3169 (0) |
| review cost (proxy-reported) | $0.0577 | $0.0389 |
| review repairs / retries | 0/0 | 0/0 |

#### Unmatched findings: claude-opus-5-5

Not in the ground truth; judge by hand.

- src/webhook.ts:3 Critical/Architecture: Fail startup when WEBHOOK_SECRET is missing

#### Unmatched findings: claude-sonnet-5-5

Not in the ground truth; judge by hand.

- src/webhook.ts:3 Critical/Architecture: Empty-string fallback for the webhook HMAC secret

