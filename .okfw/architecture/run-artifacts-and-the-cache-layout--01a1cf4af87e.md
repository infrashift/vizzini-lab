---
id: "01a1cf4a-f87e-7bd5-8594-84a12b826c4d"
title: "Run artifacts and the .cache layout"
type: "Architecture"
tags:
  - "architecture"
  - "build"
created: "2026-11-12T04:25:59-06:00"
timestamp: "2026-11-12T04:25:59-06:00"
description: "Where builds, tool clones, runs, evidence and local state live under .cache, and which of them are committed to results/."
---

# Run artifacts and the .cache layout

Everything a run makes stays under `.cache/`, which git ignores. Only curated summaries reach `results/`.

| path | what | lifetime |
|---|---|---|
| `.cache/src/<tool>` | clones of Vizzini, mrman, garmr and okf-wiki at their pins ([ADR-0001](/decisions/adr-0001-a-dedicated-uat-repo-that-builds-every-tool-from-a-pinned-sha--01a1caeb8cd0.md)) | until `make clean` |
| `.cache/bin/` | `pr-review`, `vizzini-bot`, `mrman`, `garmr`, `okfw`, `stubllm`, and `build-manifest.json` (what was built, from which commit) | rebuilt by `make build` |
| `.cache/tiktoken/` | the tokenizer encodings, checked against pinned sums | kept |
| `.cache/npm/` | the npm cache for the ESLint container | kept |
| `.cache/oss/` | mirrors of the real-world repositories in `fixtures/csharp-oss.txt` | kept |
| `.cache/litellm/` | `master.key` and `db.password` (0600) for the proxy ([proxy](/architecture/litellm-proxy-with-postgres-spend-logs--01a1cf4af88f.md)) | kept; never committed |
| `.cache/runs/<UTC>/` | one `run.sh` run: the materialized fixture repos, patches, SARIF, per-model reports, `summary.md`, `scores.json`, `costs.md` | until removed |
| `.cache/runs/<UTC>-bot/` | one `bot.sh` run: per-leg reports, mrman data directories and audit logs, the generated allow policy | until removed |
| `.cache/runs/<UTC>-ci-<platform>/` | one CI template test: the generated pipeline and its diff, job logs, API snapshots, `summary.md` | until removed |

## Rules
- **Personal data stays here.** The bot test's allow policy holds the forge display name, and reports carry the requester. Neither is committed; logs show three characters ([credentials](/architecture/credential-handling--01a1cf4af8b1.md)).
- **Kept evidence goes to `results/`:** `results/YYYY-MM-DD-live-<topic>.md` is a copy of a run's summary, cited by issues, ADRs and Vizzini's docs.
