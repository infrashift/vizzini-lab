---
id: "01a1d176-591e-7ed9-8465-35639aeedafd"
title: "Errors, retries and exit codes"
type: "Guideline"
tags:
  - "errors"
  - "retries"
  - "reliability"
created: "2026-11-12T14:32:36-06:00"
timestamp: "2026-11-12T14:32:36-06:00"
description: "How rclone classifies errors into retry categories, separates low-level from high-level retries, and maps outcomes to exit codes."
x:
  paths: ["fs/fserrors/**", "lib/pacer/**", "fs/fshttp/**", "fs/operations/**", "fs/sync/**", "backend/**"]
  source: ["CONTRIBUTING.md", "AGENTS.md", "docs/content/docs.md"]
---

# Errors, retries and exit codes

The docs say less about error handling than about other topics. This concept collects what they do state.

## Where the machinery lives

CONTRIBUTING.md describes `fs/fserrors` as "rclone specific error handling" and `lib/pacer` as providing "retries with backoff and paces operations". Backends are told to use `lib/pacer` for rate limiting (AGENTS.md) rather than writing their own retry loops.

## Two levels of retry (docs.md)

- A **low-level retry** repeats a single failing operation, "typically one HTTP request", such as uploading one chunk of a large file. `--low-level-retries` controls how many are attempted, and they show in the log with `-v`.
- A **high-level retry** (`--retries`, default 3) repeats the entire sync when it has failed. It exists because "some remotes can be unreliable".

The `--dump errors` description gives the working definition of a retryable HTTP error: a transport error, an HTTP 429 (too many requests), or an HTTP 5xx server error.

## Error categories and exit codes

docs.md lists the exit codes, and several of them match error classes:

- `5`: temporary error that more retries might fix (Retry errors)
- `6`: less serious errors (NoRetry errors)
- `7`: fatal error that more retries will not fix, such as a suspended account (Fatal errors)
- `3` and `4`: directory not found and file not found
- `1`: uncategorised, `2`: syntax or usage
- `8`, `9`, `10`: max-transfer reached, no files transferred (only with `--error-on-no-transfer`), max-duration reached

The exit codes name the Retry, NoRetry and Fatal error classes, so how an error is classified is visible to users and scripts. The docs do not describe the Go API for classifying errors; read `fs/fserrors` for that.

## Accumulating errors

At startup, a configuration error makes rclone exit immediately, after a log message. While running, rclone accumulates errors and only exits non-zero if failed transfers remain after the retries. Every counted error gets a high-priority log message (visible with `-q`) that names the file. Retry starts and successful retries are logged as well.

## Checking errors

The lint configuration enables `errcheck`, and CONTRIBUTING.md notes that the lint catches mistakes "like forgetting to check an error return". Godoc comments should state which sentinel errors a function returns and when (AGENTS.md).
