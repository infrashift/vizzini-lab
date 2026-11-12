# runbooks

<!-- okfw:generated — maintained by okfw; edits here are overwritten -->

## Concepts

* [Runbook: bump a tool pin](runbook-bump-a-tool-pin--01a1cf4af828.md) - Move versions.env to a new Vizzini, mrman, garmr or okfw revision, rebuild, re-run the suites the change touches, and record the result.
* [Runbook: clean up after an interrupted run](runbook-clean-up-after-an-interrupted-run--01a1cf4af83a.md) - What each suite leaves behind when it is killed mid-run, and how to remove it from Azure DevOps, GitHub, podman and LiteLLM without touching anything else.
* [Runbook: first-time setup](runbook-first-time-setup--01a1cf4a8f24.md) - Everything a machine needs before any vizzini-lab suite runs: tools, the two secrets, the ADO repository, gh, the podman socket, and a first build.
* [Runbook: read a run's costs](runbook-read-a-runs-costs--01a1cf4af85c.md) - Produce and read a run's cost report from LiteLLM's spend logs with uat/costs.sh and litellm.sh psql.
* [Runbook: run the CI template tests](runbook-run-the-ci-template-tests--01a1cf4af818.md) - Run Vizzini's GitHub Actions, Azure Pipelines and GitLab CI templates live with make uat-ci-github, uat-ci-ado and uat-ci-gitlab, and confirm each platform is left clean.
* [Runbook: run the live UAT](runbook-run-the-live-uat--01a1cf4af7f5.md) - Run make uat end to end with live Claude models, the attended mrman grant and the Azure DevOps leg, then record the result.
* [Runbook: run the unattended bot test](runbook-run-the-unattended-bot-test--01a1cf4af807.md) - Run uat/bot.sh, live or against stubllm, and read its nine legs on an Azure DevOps PR.
* [Runbook: troubleshooting](runbook-troubleshooting--01a1cf4af84b.md) - Known failures in the vizzini-lab suites, what each one means, and the fix.

