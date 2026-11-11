# CLAUDE.md — vizzini-uat

Cross-tool UAT for Vizzini, mrman, garmr and okf-wiki. Shell + Python harness only: no product code lives here.

## Rules
1. **Never handle secrets directly.** The Anthropic key is the podman secret `vizzini-anthropic-key`. The ADO PAT is `~/.config/vizzini-uat/ado.pat` (0600). Never echo, log, commit, or pass either on a command line. The user creates both in their own terminal.
2. **Never fake mrman's submit grant** (ADR-0002). No pty tricks, no `script`, no `expect`. The forge leg waits for a person.
3. **Pins, not working trees.** Test a tool change by committing it in that tool's repo and bumping `versions.env`. Never build from, or edit, the sibling checkouts from this repo.
4. **Don't weaken hard checks to make a model pass.** A model-quality miss is a finding to report. Move a check between hard and metric only with a recorded decision.
5. **Ground truth follows the fixture.** If you edit `fixtures/csharp-seeded/change/`, keep `expected.json` anchors valid. `score.py` exits on a stale anchor.
6. **Outward-facing actions need confirmation:** pushing this repo, opening PRs anywhere except the UAT's own ADO PRs during `make uat`, posting comments.

## Commands
- `make build`, `make uat-stub` (no tokens), `make uat-vizzini` (live, no forge), `make uat` (live, attended)
- `make lint` runs shellcheck, the Python compile check, and okfw validate. Run it after every change.

## Knowledge base
`.okfw/` (okfw) holds decisions and open issues. Search before deriving, use `okfw create` / `move` / `delete`, and run `okfw validate --all && okfw validate --okf`.
