# UAT run 20261111T181101Z

| tool | version | commit |
|---|---|---|
| vizzini | cc3f080 | `cc3f08071a9f` |
| mrman | v0.1.1 | `a56f47e5b796` |
| garmr | bf96753 | `bf96753b9123` |
| okfw | v2026.10.2-2-g557c304 | `557c304ed561` |

Go: go version go1.27.3 linux/amd64

**Hard checks:** 23/23 passed

## Fixture: ts-seeded (TypeScript)

### Seeded defects

| defect | must catch | claude-sonnet-5-5 |
|---|---|---|
| cmdinj | yes | ✅ Critical |
| eval | yes | ✅ Critical |
| secret | yes | ✅ Critical |
| protopollution | yes | ✅ Major |
| timing |  | ✅ Critical |
| redos |  | ✅ Minor |
| floating |  | ✅ Major |
| returnawait |  | ✅ Major |
| offbyone |  | ✅ Major |
| race |  | ✅ Major |

### Per model

| metric | claude-sonnet-5-5 |
|---|---|
| recall | 100% |
| category agreement (caught) | 100% |
| findings | 10 |
| Critical/Major/Minor/Trivial | 4/5/1/0 |
| Architecture findings | 4 |
| findings on the clean decoy | 0 |
| unmatched findings | 0 |
| risk (final/diff/model) | 97/57/97 |
| garmr | deny VZ-001,VZ-002,VZA-001 |
| review / describe / improve / plan | 19s / 8s / 21s / 18s |
| ADO inline threads | 10 |
| review tokens in/out (cached) | 3582/2820 (0) |
| review cost (proxy-reported) | $0.0354 |
| review repairs / retries | 0/0 |

