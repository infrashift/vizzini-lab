# test-suites/ci-github

<!-- okfw:generated — maintained by okfw; edits here are overwritten -->

## Concepts

* [TS-CIGH: GitHub Actions template](ts-cigh-github-actions-template--01a1cf70a60f.md) - Vizzini's GitHub Actions template on a throwaway PR in infrashift/vizzini-uat: the denied first run, the allowed identity, and the incremental second commit.
* [UAT-CIGH-001: The first run is denied and names the identity](uat-cigh-001-the-first-run-is-denied-and-names-the-identity--01a1cf70a6fa.md) - Make sure that the first run posts nothing and shows the identity to allow.
* [UAT-CIGH-002: The allowed identity posts review comments](uat-cigh-002-the-allowed-identity-posts-review-comments--01a1cf70a702.md) - Make sure that the job posts when the base branch's policy lists `github-actions[bot]`.
* [UAT-CIGH-003: A second commit is reviewed incrementally](uat-cigh-003-a-second-commit-is-reviewed-incrementally--01a1cf70a70b.md) - Make sure that the job reviews only the changed file and posts no duplicate.
* [UAT-CIGH-004: The run leaves no PR or branch](uat-cigh-004-the-run-leaves-no-pr-or-branch--01a1cf70a713.md) - Make sure that the test removes what it made on GitHub.

