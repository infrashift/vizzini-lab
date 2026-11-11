# decisions

<!-- okfw:generated — maintained by okfw; edits here are overwritten -->

## Concepts

* [ADR-0001: No dynamic code execution and no shell command strings](adr-0001-no-dynamic-code-execution-and-no-shell-command-strings--01a1cb223889.md) - Never eval or construct code from strings, and start child processes with execFile and an argument array, never a shell command string.
* [ADR-0002: Secrets come only from the environment](adr-0002-secrets-come-only-from-the-environment--01a1cb22389c.md) - API tokens, signing keys and passwords are read from the environment or the secret store at startup; never committed, and never defaulted to an empty value.

