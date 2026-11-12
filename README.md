# vizzini-uat

End-to-end and user-acceptance tests that run one C# pull request through all four infrashift tools, with live Claude models:

| tool | role in the UAT |
|---|---|
| [Vizzini](../vizzini-pr-reviewer) | AI review, describe, improve and plan, grounded in Roslyn SARIF and an OKF knowledge base |
| [garmr](../garmr-policy-agent) | local policy evaluation of each review with Vizzini's policy pack |
| [okf-wiki](../okf-wiki) (`okfw`) | the fixture's knowledge base, validated and used to ground reviews |
| [mrman](../mrman) | opens the Azure DevOps PR, shows Vizzini's findings, posts them as review threads |

The models are `claude-sonnet-5-5` and `claude-opus-5-5`, reached through a LiteLLM proxy running in podman.

## Quick start

```sh
make build        # clone the four tools at their pinned SHAs (versions.env), build into .cache/bin
make uat-stub     # token-free dry run of the whole harness against Vizzini's stub model
```

### Live models

Create the Anthropic key as a podman secret **in your own terminal**, so the key never lands in a file or in shell history:

```sh
read -rs K && printf %s "$K" | podman secret create vizzini-anthropic-key - && unset K
make litellm-up litellm-smoke
make uat-vizzini  # Vizzini + garmr + okfw on the seeded fixture and the real-world commits
```

### Full UAT with Azure DevOps and mrman

```sh
mkdir -p ~/.config/vizzini-uat
echo 'ADO_REPO_URL=https://dev.azure.com/ORG/PROJECT/_git/REPO' > ~/.config/vizzini-uat/ado.env
read -rs P && install -m600 /dev/null ~/.config/vizzini-uat/ado.pat && printf %s "$P" > ~/.config/vizzini-uat/ado.pat && unset P
make ado-check
make uat          # attended: it pauses for you to grant mrman's submit (see below)
make ado-down     # abandon the UAT's PRs and delete its branches
```

The PAT needs **Code (Read & Write)**. For each model the UAT pushes the fixture as `uat/<model>-<stamp>`, opens a PR into `uat-base`, and checks that mrman sees every Vizzini finding. It then pauses and asks you to run `mrman pr <url> --vizzini-report ... --auto` yourself. mrman only grants submit to an interactive session, and the UAT will not fake one ([ADR-0002](.okfw/decisions/)). While your TUI is open, the harness posts the findings as comment threads and checks them over the ADO REST API.

### Unattended: vizzini-bot under a garmr policy

```sh
make uat-bot       # live (needs litellm-up); make uat-bot-stub runs without tokens
```

`uat/bot.sh` reviews the fixture's PR the way a CI step would. `vizzini-bot` reviews `git diff uat-base...uat-head` from the checkout and posts through `mrman review submit --grant-policy`, with no person involved. The run has two legs ([ADR-0004](.okfw/decisions/)):

1. **Deny.** mrman's committed default pack must deny your PAT's identity (MRM-002) and post nothing.
2. **Allow.** A run-local copy listing the identity mrman verified with the forge must post one marked thread per finding.

Both decisions are read back from mrman's audit log.

When the fixture has a `fix/` overlay, more legs run on the same PR ([ADR-0005](.okfw/decisions/)) to test thread memory, incremental review, in-thread commands and suppression:

3. **Idle.** The bot runs again at the same head, incrementally. Nothing changed, so it must make no review at all.
4. **Rerun.** The bot runs at the same head with `--full` and reads its threads back. It must duplicate nothing and resolve nothing.
5. **Fix.** A commit fixing the MD5 reset token is pushed to the PR. Only the changed file is reviewed, and the open threads on other files are carried untouched. Only threads on the changed lines whose finding is gone are resolved, each with a reply.
6. **Command.** As your PAT's user, the harness writes `/vizzini explain …` and a malformed `/vizzini …` in one of the bot's threads. The bot answers both in the thread, the second with usage. In live runs, the command's model call must be attributed to its run and PR.
7. **Command again.** Nothing is answered twice.
8. **Dismiss.** As your PAT's user, the harness resolves one of the bot's threads as *won't fix*. The bot replies once with a suppression rule to commit.
9. **Suppress.** The harness merges that rule into the base branch's `.vizzini/suppressions.yaml`, and the bot runs with `--full`. The finding is suppressed, not posted again, and there is no second suggestion.

## What gets checked

`uat/score.py` writes `summary.md` (the Sonnet vs Opus comparison) and `scores.json` into `.cache/runs/<UTC>/`.

**Hard checks** fail the run:
- the report envelope is valid
- every finding is anchored to the diff
- the schema repair loop never gives up
- the must-catch planted defects are found: SQL injection, MD5 reset token, hardcoded credential, null dereference
- the SQL injection's file cites the data-access ADR
- only the relevant OKF documents reach the model
- exactly the changed-line Roslyn diagnostics are injected
- garmr denies on Critical/Major (VZ-001) with the right exit code
- describe, improve and plan answers are schema-valid
- the large real-world commit is reviewed in several chunks
- in the forge leg: mrman carries every finding, and ADO threads sit on the must-catch defects

**Metrics** are reported but never fail the run, because models differ and a finding the ground truth does not list may still be right:
- recall over all 9 planted defects
- category agreement
- findings on the clean decoy file, and unmatched findings
- severities and risk scores
- wall time per mode

## Layout

| path | |
|---|---|
| `versions.env` | pinned tool SHAs, LiteLLM and .NET images, models |
| `uat/build.sh` | build the tools from their pins |
| `uat/run.sh` | the UAT (`--stub`, `--no-forge`, `--no-oss`, `--models`) |
| `uat/bot.sh` | the unattended leg: vizzini-bot, deny then allow (`--stub`, `--fixture`, `--model`) |
| `uat/fixture.sh` | materialize the seeded fixture, patch and Roslyn SARIF |
| `uat/ado.sh` | Azure DevOps branches, PRs and threads |
| `uat/score.py` | hard checks, metrics, `summary.md` |
| `litellm/` | proxy config and `litellm.sh up/down/status/env/smoke` |
| `fixtures/csharp-seeded/` | `base/` + `change/` overlay, `expected.json` ground truth, `issue.json` for plan mode |
| `fixtures/csharp-oss.txt` | pinned real-world commits (serilog, Polly) |
| `uat/ci-github.sh`, `uat/ci-ado.sh`, `uat/ci-gitlab.sh` | Vizzini's CI templates, live on GitHub Actions, Azure Pipelines and a throwaway GitLab CE |
| `ci/ado-agent/` | the throwaway self-hosted Azure Pipelines agent image |
| `results/` | kept run summaries, cited by the wiki and Vizzini's docs |
| `.okfw/` | this repo's wiki: runbooks, architecture, decisions (ADRs) and open issues. Start with `.okfw/architecture/` (the suite map) and `.okfw/runbooks/` |
