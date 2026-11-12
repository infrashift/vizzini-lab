---
id: "01a1d134-1164-717d-acbb-ab2aebf970a8"
title: "ADR-0013: The benchmark compares at equal inputs and judges every finding blind"
type: "ADR"
tags:
  - "adr"
  - "benchmark"
created: "2026-11-12T13:20:12-06:00"
timestamp: "2026-11-12T13:20:12-06:00"
description: "uat/bench.sh runs Vizzini and PR-Agent on the same diffs through the same proxy and models, with default configurations and no lint or knowledge inputs; every finding gets one blind verdict, so precision and judged recall are reproducible."
---

# ADR-0013: The benchmark compares at equal inputs and judges every finding blind

**Status:** Accepted
**Date:** 2026-11-12
**Related:** Vizzini ISSUE-022, ISSUE-023; `uat/bench.sh`, `uat/bench.py`; [ADR-0010](/decisions/adr-0010-seeded-fixtures-per-language-only-must-catch-defects-are-hard--01a1cf4af906.md)

## Context
Vizzini ISSUE-022 asks for a reproducible comparison of Vizzini and PR-Agent: recall and precision on the seeded fixtures and on labelled real pull requests. A comparison is only useful if a reader can trust that neither tool got an advantage, and if "precision" means something more than a guess.

## Decision
- **Same models, same proxy.** Both tools call `claude-sonnet-5-5` and `claude-opus-5-5` through the lab's LiteLLM proxy. PR-Agent runs in its published image, pinned by digest in `versions.env`. 0.49.0 was the newest release at least two weeks old.
- **Default configurations.** PR-Agent runs `review` and `improve` with its defaults (for example, at most 3 key issues), as people deploy it. It runs through its `local` git provider on the case's checkout, so it reads the changed files in full. Vizzini runs `pr-review --mode review` in two ways: with `--repo .` (definitions and callers) and with the diff only (`vizzini-norepo`). The diff-only run measures what repository context adds.
- **Equal inputs.** Neither tool gets lint output (`--lint-json`) or a knowledge base (`--knowledge`). These are Vizzini features that PR-Agent does not have, so they would not test the same thing.
- **Recall, two ways.**
  - **Location recall:** a finding in the same file whose lines overlap a labelled defect's lines, within the case's tolerance (2 lines). This is the issue's rule. It needs no judgement, but it gives credit to a wide finding that only happens to cover a defect.
  - **Judged recall:** a defect is caught only when a finding is judged to describe it (verdict `defect:<id>`).
- **Every finding is judged once, blind.** `bench.py` writes each finding without its tool or model, in shuffled order, to `to-label.jsonl`. The judge gives one verdict, keyed by a hash of the case, location and text, and the verdicts are kept in `bench/labels.json`. The owner reviews `labels.json` before anything is published.
- **Verdicts:**
  - `defect:<id>`: the finding describes that labelled defect.
  - `valid`: a real, correct problem in the change that a reviewer would want to know about.
  - `nit`: correct but trivial (style, naming, docs, a micro-optimization).
  - `invalid`: factually wrong about the code, speculative without basis in the code shown, or not about the change.
- **Precision:** strict = (defect + valid) / judged. Lenient also counts `nit`.
- **Clean cases** (changes with no later fix) measure noise. Every finding on a clean case still gets a verdict, because a clean change can have real problems.
- **PR-Agent's `security_concerns`** is free text with no lines, so it is counted as file-level notes and not as findings.

## Rounds 2 and 3 (added 2026-11-12, at the owner's request)
All three rounds use the same 34 cases, the same models, and the same checkouts. Only Vizzini's inputs grow, and each round shows what one feature adds.
- **Round 1:** the rules above, with equal inputs.
- **Round 2 (`vizzini-lint`):** round 1 plus `--lint-json`, produced by `uat/bench-lint.sh`.
  - **Linters:** static linters only, with one configuration for every case. The projects' own configs and plugins are never used, and nothing is built.
    - golangci-lint v2.15.0, default linters (Go);
    - ruff 0.17.2 with rules E4,E7,E9,F,B (Python);
    - ESLint 9 with the recommended JS and TypeScript rules, from `bench/eslint` (JS/TS).
  - **Go dependencies:** the Go modules the changed packages need are downloaded first, with the network on, and the lint itself then runs with no network.
  - **C# and Rust:** these real cases get no lint, because Roslyn and clippy need a build. The two seeded fixtures keep their own Roslyn and ESLint SARIF.
  - **PR-Agent** has no lint input, so it stays at its round-1 result.
- **Round 3 (`vizzini-lint-kb`, `pa-review-kb`, `pa-improve-kb`):** round 2 plus `--knowledge`.
  - **Real cases:** the knowledge base is an OKF wiki per project, in `bench/knowledge/`. It was written by an agent that saw only the project's documentation files and file listing at the earliest base commit among that project's cases. The agent was never told the cases, defects or fixes, and had no network.
  - **Checks on the wikis:** each one was checked for references to the cases' commits and PRs (none found) and for globs that cover the changed files.
  - **PR-Agent** gets the same wiki text as its `extra_instructions`, for both `review` and `improve`. That makes round 3 a comparison of how each tool uses the knowledge, not of whether it has any.
  - **Seeded fixtures:** their wikis were written by the people who planted the defects, so their round-3 results are for reference only.
- **Carried results:** a case with no lint (round 2) or no wiki (round 3) keeps the previous round's output, and is marked as carried.

## How the judging was done
The judges were nine Claude Opus 5.5 agents. They applied `bench/RUBRIC.md` to the cases they were given, with each case's findings shuffled across tools, models and rounds. They read the diff and, for context, the checkout, but never the tools' raw outputs. Each verdict records a one-sentence reason in `bench/labels.json`, and the owner reviews the labels before publication.

Caveat: the judge model is also one of the models under test. Judging is blind to the tool, but a tool's writing style may still give it away: PR-Agent `improve` findings carry "Improved code", and Vizzini's carry "Suggestion".

## Consequences
- The numbers depend on one judge. The rubric and every verdict, with its reason, are published so that anyone can contest them.
- Real-PR defects come from later fixes that name the change that caused them. A finding about a different real problem is `valid`, not a miss.
- Model memorization: the models' knowledge cutoff is about June 2026. Cases after 2026-07-01 are marked, so results can be split by date.

## Alternatives considered
- **An LLM as the only judge.** Rejected: it would be one more model to trust. It may be added later as a second opinion.
- **Lint and knowledge for Vizzini.** Rejected for the main table, because the inputs would not be equal. These features are measured in `make uat-vizzini`.
