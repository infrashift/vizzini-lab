---
id: "01a1caeb-8ce7-7987-be8d-6371fc2e55ce"
title: "ADR-0002: The mrman submit grant stays a human step"
type: "ADR"
tags:
  - "adr"
  - "mrman"
  - "security"
created: "2026-11-11T08:03:17-06:00"
timestamp: "2026-11-11T08:03:17-06:00"
description: "The UAT never fakes a terminal to grant mrman's --auto submit; it pauses and a person runs the TUI with --auto."
---

# ADR-0002: The mrman submit grant stays a human step

**Status:** Accepted

## Context
`mrman review submit` needs a grant that only the interactive TUI's `--auto` can issue. `--auto` is refused together with `--json` and needs a TTY on stdin, so that an agent cannot grant itself the right to post reviews (mrman `internal/cli/agentgrant.go`). A harness could allocate a pty and get around this.

## Decision
The UAT does not allocate a pty to obtain a grant. In the forge leg it prints the `mrman pr <url> --vizzini-report ... --auto` command and waits. A person opens the TUI, checks that the Vizzini findings render (the visual acceptance check), and leaves it running while the harness posts the findings with `mrman review add` / `submit --event comment`.

## Consequences
The full `make uat` is attended. `make uat-vizzini` and `make uat-stub` stay fully automatic. The default grant covers only `comment` and `draft`, so the UAT never approves or blocks a PR.
