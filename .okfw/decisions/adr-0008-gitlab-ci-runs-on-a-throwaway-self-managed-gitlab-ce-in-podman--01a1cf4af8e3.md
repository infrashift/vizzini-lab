---
id: "01a1cf4a-f8e3-791b-ab46-d4c4facfaa07"
title: "ADR-0008: GitLab CI runs on a throwaway self-managed GitLab CE in podman"
type: "ADR"
tags:
  - "adr"
  - "ci"
  - "gitlab"
created: "2026-11-12T04:25:59-06:00"
timestamp: "2026-11-12T04:25:59-06:00"
description: "uat/ci-gitlab.sh tests the GitLab template on a GitLab CE and gitlab-runner started in podman for the run, which needs no account or token and covers the self-managed path, at the cost of not covering gitlab.com."
---

# ADR-0008: GitLab CI runs on a throwaway self-managed GitLab CE in podman

**Status:** Accepted
**Date:** 2026-11-12
**Related:** [CI template tests](/architecture/ci-template-tests-one-onboarding-sequence-on-three-platforms--01a1cf4af8a0.md), Vizzini ADR-0021

## Context
Until this test, Vizzini's GitLab CI template had only been linted. There was no GitLab account or token on this machine. gitlab.com would also need runner identity verification, and possibly a paid tier for project access tokens. A self-managed instance is also where adopters' setups differ most.

## Decision
- **The instance:** GitLab CE 19.5.1 and gitlab-runner v19.5.1, both by digest in `versions.env`. They run in podman on a private network (`vizzini-lab-gl-<stamp>`). GitLab is published on 127.0.0.1:18480 only and named `gitlab.uat.test` inside the network.
- **Tokens, all made for the run:**
  - **Root:** generated locally and installed with `gitlab-rails runner`, read from the environment.
  - **Runner:** created through `POST /user/runners` and registered with the docker executor on this user's rootless podman socket.
  - **Bot:** a **Reporter** project access token with scope `api`, saved as the masked CI/CD variable `VIZZINI_GITLAB_TOKEN`, as the template documents.
- **No disk for bulk data:** GitLab's data and the jobs' Go module and build caches are on **tmpfs**. The first attempt filled the host disk.
- **A DNS line per job:** a runner-side pre-build script logs the job container's DNS server and whether github.com resolves. One early job failed to resolve it, and that failure never recurred.
- **Cleanup:** the exit trap removes both containers and their volumes, the job containers and volumes created during the run, and the network.

## Consequences
- **Free, private, repeatable:** nothing leaves the machine except the job's downloads (GitHub, the Go proxy, the mrman release).
- **It found a real bug.** mrman reads `GITLAB_TOKEN` only for gitlab.com, so the template could not post on a self-managed instance. The template now writes a `[[forge.hosts]]` entry (Vizzini 1dfff26), and this test checks it.
- **gitlab.com is not covered** ([ISSUE-002](/issues/issue-002-ci-template-coverage-gaps--01a1cf4af927.md)).
- **The runner can drive this user's podman.** Only the test's own jobs run on it, and they get no socket.
- **Cost:** about 4 GB of images, about 3 GB of RAM at peak, about 12 minutes.
