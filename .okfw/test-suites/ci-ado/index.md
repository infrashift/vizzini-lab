# test-suites/ci-ado

<!-- okfw:generated — maintained by okfw; edits here are overwritten -->

## Concepts

* [TS-CIADO: Azure Pipelines template](ts-ciado-azure-pipelines-template--01a1cf70a616.md) - Vizzini's Azure Pipelines template as PR build validation on a throwaway self-hosted agent: denied, allowed with the build service permission, then incremental with a /vizzini command.
* [UAT-CIADO-001: The first build is denied and names the identity](uat-ciado-001-the-first-build-is-denied-and-names-the-identity--01a1cf70a71b.md) - Make sure that the first build posts nothing and shows the identity to allow.
* [UAT-CIADO-002: The allowed build service posts threads](uat-ciado-002-the-allowed-build-service-posts-threads--01a1cf70a724.md) - Make sure that the build posts threads when the base branch's policy lists the build service.
* [UAT-CIADO-003: An incremental build answers a /vizzini command](uat-ciado-003-an-incremental-build-answers-a-vizzini-command--01a1cf70a72c.md) - Make sure that the build reviews only the changed file and answers the command once.
* [UAT-CIADO-004: The organization is clean after the run](uat-ciado-004-the-organization-is-clean-after-the-run--01a1cf70a735.md) - Make sure that the test removes the permission and everything else it made.

