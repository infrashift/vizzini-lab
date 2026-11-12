---
id: "01a1cf4a-f906-7031-a84c-a8bce62aeb9e"
title: "ADR-0010: Seeded fixtures per language; only must-catch defects are hard"
type: "ADR"
tags:
  - "adr"
  - "fixtures"
  - "scoring"
created: "2026-11-12T04:25:59-06:00"
timestamp: "2026-11-12T04:25:59-06:00"
description: "Each language gets a seeded fixture with ground truth; the run fails only on harness invariants and must-catch defects, while recall, categories and severities are reported as metrics."
---

# ADR-0010: Seeded fixtures per language; only must-catch defects are hard

**Status:** Accepted
**Date:** 2026-11-11
**Related:** [ISSUE-001](/issues/issue-001-live-uat-with-claude-sonnet-5-5-and-opus-5-5--01a1caeb8d15.md); Vizzini ISSUE-018

## Context
Live models vary between runs, and a finding outside the ground truth may still be right. A suite that fails on model variance gets ignored. A suite that never fails proves nothing.

## Decision
- **One seeded fixture per language:** `csharp-seeded` (Roslyn SARIF) and `ts-seeded` (ESLint SARIF). Each has a `base/`, a `change/` overlay with planted defects and a clean decoy file, and an `expected.json` with each defect's anchors and categories. csharp-seeded also has a `fix/` overlay for the bot's memory legs.
- **Hard checks** are harness invariants plus the **must-catch** defects:
  - C#: SQL injection, MD5, hardcoded secret, null dereference;
  - TypeScript: command injection, eval, hardcoded secret, prototype pollution.
- **Metrics only:** recall over every planted defect, category and severity agreement, findings on the decoy, unmatched findings, risk and wall time.
- **Changing the split** between hard checks and metrics needs a recorded decision. A model-quality miss is a finding to report, never a reason to weaken a check (CLAUDE.md rule 4).

## Consequences
- **Live runs pass or fail on what matters**, and the run summaries compare the models.
- **Ground truth must follow the fixture:** `score.py` exits on a stale anchor.
