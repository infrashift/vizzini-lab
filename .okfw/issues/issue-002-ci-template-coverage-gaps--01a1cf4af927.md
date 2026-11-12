---
id: "01a1cf4a-f927-7bb0-91d1-e9991252d0c0"
title: "ISSUE-002: CI template coverage gaps"
type: "issue"
tags:
  - "issue"
  - "open"
  - "ci"
created: "2026-11-12T04:25:59-06:00"
timestamp: "2026-11-12T04:25:59-06:00"
description: "What the CI template tests do not yet cover: gitlab.com itself, thread replies and resolution on GitHub and GitLab, and runs that post nothing recording their head."
---

# ISSUE-002: CI template coverage gaps

The CI template tests ([architecture](/architecture/ci-template-tests-one-onboarding-sequence-on-three-platforms--01a1cf4af8a0.md)) cover GitHub Actions on github.com, Azure Pipelines on dev.azure.com, and GitLab CI on a self-managed GitLab CE. They do not cover:

## Acceptance criteria
- [ ] **gitlab.com.** On gitlab.com the template skips the mrman host entry, and mrman reads `GITLAB_TOKEN`. That path is untested. Testing it needs a gitlab.com project, runner verification, and possibly a paid tier for project access tokens ([ADR-0008](/decisions/adr-0008-gitlab-ci-runs-on-a-throwaway-self-managed-gitlab-ce-in-podman--01a1cf4af8e3.md)).
- [x] **Replies and resolution on GitLab.** Done in mrman v0.1.6, verified live by TS-CIGL. Before that: mrman's GitLab driver cannot reply to or resolve threads. A `/vizzini` command on GitLab is therefore attempted, and fails, on **every** run (`command_failures` in the bot's result). When mrman gains GitLab replies, flip the GitLab test's command check to "answered once".
- [x] **Replies and resolution on GitHub.** Done in mrman v0.1.6, verified live by TS-CIGH: a command answered, and a thread resolved with the documented `contents: write` opt-in (`GITHUB_TOKEN` cannot resolve without it).
- [ ] **Runs that post nothing do not record their head.** The next run then reviews from the last head the bot commented on, not from the last head it reviewed (a Vizzini follow-up).
