---
id: "01a1d176-5947-7b02-96bd-1d20e93e839e"
title: "Security boundaries and secret handling"
type: "Guideline"
tags:
  - "security"
  - "rc"
  - "secrets"
created: "2026-11-12T14:32:36-06:00"
timestamp: "2026-11-12T14:32:36-06:00"
description: "The security model the docs state for the rc API, credential redaction and test servers."
x:
  paths: ["fs/rc/**", "cmd/rcd/**", "fs/config/**", "fs/fshttp/**", "librclone/**", "fstest/testserver/**"]
  source: ["docs/content/rc.md", "docs/content/docs.md", "fstest/testserver/init.d/README.md", "CONTRIBUTING.md"]
---

# Security boundaries and secret handling

## The rc API is shell access

docs/content/rc.md: "**Access to the rc API is equivalent to shell access as the user running rclone.**" Anyone who can reach it and pass authentication can:

- run OS commands. `core/command` re-executes rclone with arbitrary arguments, and several backend options shell out to programs, so even `config/create` can lead to command execution;
- read and write any file the process can reach, through `operations/*` or `sync/*` pointed at a `local` remote, or through `--rc-files` and `--rc-serve`;
- read back stored credentials through `config/dump` and similar calls;
- change runtime options, manage remotes, and quit the process.

There is no per-endpoint capability or scope system: authentication is all-or-nothing. The documented safe defaults are:

- the rc binds to loopback (`localhost:5572`) by default;
- methods that access remotes require authorisation unless `--rc-no-auth` is set, and that flag should not be used on a non-loopback bind;
- authentication and TLS should be used whenever untrusted parties can reach the port.

For review, this means a change to `fs/rc` or `cmd/rcd` that widens the default bind, relaxes the authorisation needed for remote-accessing methods, or adds a method that touches files or credentials changes this security model. Such a change needs to be judged against these documented defaults. librclone exposes the same RPC in-process.

## Secrets in config and logs

- Option blocks carry `IsPassword` and `Sensitive` fields. `Sensitive` options are redacted by `rclone config redacted` (rc.md).
- `--dump headers` leaves out `Authorization:` headers, and only `--dump auth` includes them. `auth` also makes `rclone config -vv` show answers, passwords and tokens that "are otherwise redacted". `--dump curl` masks auth by default (docs.md). These are the documented redaction defaults.
- Users are told to obscure any secrets in `-vv` logs before attaching them to issues (CONTRIBUTING.md).

## Test servers

Test server scripts must bind any ports to localhost "so they aren't accessible externally", and each must use a unique port allocated in `PORTS.md` (fstest/testserver/init.d/README.md).

The docs do not give broader secure-coding rules beyond these points.
