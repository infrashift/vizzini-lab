---
id: "01a1cf4a-f828-7ebd-a6ab-7316c8ca4f5c"
title: "Runbook: bump a tool pin"
type: "Runbook"
tags:
  - "runbook"
  - "build"
  - "pins"
created: "2026-11-12T04:25:59-06:00"
timestamp: "2026-11-12T04:25:59-06:00"
description: "Move versions.env to a new Vizzini, mrman, garmr or okfw revision, rebuild, re-run the suites the change touches, and record the result."
---

# Runbook: bump a tool pin

Every tool is built from a pin in `versions.env` ([ADR-0001](/decisions/adr-0001-a-dedicated-uat-repo-that-builds-every-tool-from-a-pinned-sha--01a1caeb8cd0.md)). A change in another repository is tested by committing it there and moving the pin, never by building a working tree.

## Steps
1. **Commit the change** in the tool's own repository, under that repository's rules.
2. **Edit `versions.env`:** set `<TOOL>_SHA` to the commit or tag, and replace the comment above it with one line saying what the revision brings. A tag that was moved is followed: `build.sh` fetches with `--tags --force`.
3. **Build:** run `make build`, or `uat/build.sh vizzini` for one tool. Check `.cache/bin/build-manifest.json`.
4. **Re-run** the suites the change touches ([suite map](/architecture/suite-map-what-each-make-target-proves--01a1cf4af86d.md)). Start with the token-free ones: `make uat-stub`, then `make uat-bot-stub`.
5. **mrman pins:** `uat/ci-github.sh`, `uat/ci-ado.sh` and `uat/ci-gitlab.sh` each check the installed `mrman version vX.Y.Z` string. That string follows the **template's** `MRMAN_VERSION`, which is pinned in Vizzini, not this repository's `MRMAN_SHA`. Update it when the templates move.
6. **Commit** as `chore: pin <tool> <rev>` with the runs that passed. Pushing needs confirmation (CLAUDE.md rule 6).

## Images
LiteLLM, Postgres, Node, GitLab CE and gitlab-runner are pinned by tag **and** digest in `versions.env`. Choose a release at least two weeks old, and take its digest from the registry, not from a local pull of a floating tag.
