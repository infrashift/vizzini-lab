# UAT run 20261111T150647Z

| tool | version | commit |
|---|---|---|
| vizzini | 8664551 | `86645513d618` |
| mrman | 2426e91 | `2426e91349fe` |
| garmr | bf96753 | `bf96753b9123` |
| okfw | v2026.10.2-2-g557c304 | `557c304ed561` |

Go: go version go1.27.3 linux/amd64

**Hard checks:** 46/46 passed

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
| floating |  | ✅ Major | ✅ Major |
| returnawait |  | ✅ Minor | ✅ Minor |
| offbyone |  | ✅ Major | ✅ Major |
| race |  | ✅ Minor | ✅ Major |

### Per model

| metric | claude-opus-5-5 | claude-sonnet-5-5 |
|---|---|---|
| recall | 100% | 100% |
| category agreement (caught) | 100% | 100% |
| findings | 15 | 11 |
| Critical/Major/Minor/Trivial | 4/9/2/0 | 4/6/1/0 |
| Architecture findings | 4 | 5 |
| findings on the clean decoy | 0 | 0 |
| unmatched findings | 1 | 1 |
| risk (final/diff/model) | 97/46/97 | 95/46/95 |
| garmr | deny VZ-001,VZ-002,VZA-001 | deny VZ-001,VZ-002,VZA-001 |
| review / describe / improve / plan | 24s / 8s / 31s / 17s | 18s / 7s / 21s / 18s |
| ADO inline threads | 15 | 11 |

#### Unmatched findings: claude-opus-5-5

Not in the ground truth; judge by hand.

- src/webhook.ts:3 Critical/Security: Empty-string fallback for HMAC secret

#### Unmatched findings: claude-sonnet-5-5

Not in the ground truth; judge by hand.

- src/webhook.ts:3 Critical/Architecture: Empty-string fallback for the HMAC secret

