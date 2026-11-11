# UAT run 20261111T153406Z

| tool | version | commit |
|---|---|---|
| vizzini | 5015315 | `50153159ef88` |
| mrman | v0.1.0 | `37a69527789c` |
| garmr | bf96753 | `bf96753b9123` |
| okfw | v2026.10.2-2-g557c304 | `557c304ed561` |

Go: go version go1.27.3 linux/amd64

**Hard checks:** 36/36 passed

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
| race |  | ✅ Minor | ✅ Major |

### Per model

| metric | claude-opus-5-5 | claude-sonnet-5-5 |
|---|---|---|
| recall | 100% | 100% |
| category agreement (caught) | 100% | 100% |
| findings | 11 | 11 |
| Critical/Major/Minor/Trivial | 4/4/3/0 | 4/7/0/0 |
| Architecture findings | 5 | 5 |
| findings on the clean decoy | 0 | 0 |
| unmatched findings | 1 | 1 |
| risk (final/diff/model) | 95/46/95 | 95/46/95 |
| garmr | deny VZ-001,VZ-002,VZA-001 | deny VZ-001,VZ-002,VZA-001 |
| review / describe / improve / plan | 19s / 8s / 14s / 19s | 18s / 8s / 27s / 18s |
| ADO inline threads | – | – |

#### Unmatched findings: claude-opus-5-5

Not in the ground truth; judge by hand.

- src/webhook.ts:3 Critical/Architecture: Fail startup when WEBHOOK_SECRET is missing

#### Unmatched findings: claude-sonnet-5-5

Not in the ground truth; judge by hand.

- src/webhook.ts:3 Critical/Architecture: Missing webhook secret falls back to empty HMAC key

