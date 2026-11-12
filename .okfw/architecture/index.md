# architecture

<!-- okfw:generated — maintained by okfw; edits here are overwritten -->

## Concepts

* [CI template tests: one onboarding sequence on three platforms](ci-template-tests-one-onboarding-sequence-on-three-platforms--01a1cf4af8a0.md) - How uat/ci-github.sh, uat/ci-ado.sh and uat/ci-gitlab.sh play the same deny, allow, incremental sequence through Vizzini's CI templates on throwaway infrastructure.
* [Credential handling](credential-handling--01a1cf4af8b1.md) - Where every secret the UAT uses lives, how each reaches the tool that needs it without a command line or a log, and what identity data is redacted.
* [LiteLLM proxy with Postgres spend logs](litellm-proxy-with-postgres-spend-logs--01a1cf4af88f.md) - How the UAT reaches Claude: a podman pod running LiteLLM and Postgres on 127.0.0.1, keyed by podman secrets, recording spend per request without prompts.
* [Run artifacts and the .cache layout](run-artifacts-and-the-cache-layout--01a1cf4af87e.md) - Where builds, tool clones, runs, evidence and local state live under .cache, and which of them are committed to results/.
* [Suite map: what each make target proves](suite-map-what-each-make-target-proves--01a1cf4af86d.md) - The vizzini-lab suites, what each one exercises, what it needs, and what it touches outside this machine.
* [UAT flow: one C# PR through Vizzini, garmr, okf-wiki and mrman](uat-flow-one-c-pr-through-vizzini-garmr-okf-wiki-and-mrman--01a1caeb8cb9.md) - What the UAT runs, in order, and which tool each step proves.

