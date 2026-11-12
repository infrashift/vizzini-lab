# Judging notes (benchmark run 20261112T191951Z)

How the 1,350 findings were judged, and what the owner should review before
publication. Method: lab ADR-0013 and `bench/RUBRIC.md`.

## Judges
- Nine Claude Opus 5.5 agents, each given a group of cases. Within each case, the findings were shuffled across tools, models and rounds. The judges read the diff and the checkout, never the tools' raw output.
- A second-defect pass on the six cases with several labelled defects added an `also` field to 42 labels. A finding there that described two defects had been credited with one; the `also` field credits the others too, for recall only.
- One incident: two judges shared a helper-script name. A check before the merge found no duplicate or conflicting verdict in any output.

## Agreement: a second, independent judge on a random sample of 150
| Grouping | Agreement | Cohen's kappa |
|---|---|---|
| Exact verdict | 91% | 0.90 |
| defect+valid / nit / invalid | 91% | 0.83 |
| invalid vs the rest | 92% | 0.53 |

The judges never disagreed on `defect:<id>` or on `valid`. Every disagreement (13 of 150) was between `nit` and `invalid`, or one step from `valid`. Strict precision and judged recall are therefore robust to the judge. The `nit`/`invalid` line is softer, so the lenient numbers are less certain. The sample is in `second-opinion-sample.jsonl`.

## Calls flagged for the owner's review
These are the judges' own notes, by group. Calls marked FOR OWNER REVIEW
change a recall number if reversed.

## group 0 (152 judged)
- ts-vue-vapor-slot-close-lazy: 5 findings at planReuseOwnClose (240-242), far from defect lines 61-64, describe the same lazy cursor-based locateClaimedEnd close lookup → judged defect:d1 (stretches "points at the defect's code"; FOR OWNER REVIEW). Finding 23 mainly a null guard but states the defect → defect:d1.
- ts-seeded: findings with both `===` timing compare and empty-secret fallback → defect:timing; empty-secret-only → valid (3). One authz finding that also flags un-awaited saveAudit (line 24) → defect:floating. Standalone authorization finding on promote → invalid (speculative).
- rs-rust-analyzer-fetch-semantic: two findings that !op_in_progress() suppresses diagnostics during reloads → nit (not refreshed, not cleared).
## group 2 (149 judged)
- py-django-cacheddb-delete-logging-clean (clean): 14 findings "swallowing failed cache delete leaves logged-out session usable" → invalid (stale cache entry already stayed before when the exception was raised; change only removes the error signal; mirrors save()'s documented log-and-continue). 3 "document the trade-off" → nit. FOR OWNER REVIEW: a strict reader could call these valid.
- cs-efcore-executedelete-commandsource: 9 public-API-break findings (NonQueryExpression/VisitNonQuery removed, override return types narrowed) → valid (accurate; could be intentional refactor). 4 "Type becomes void" → invalid.
- js-undici-h2-maxconcurrentstreams-validation: wrong-replacement deprecation notes → valid (misleading docs); rejection-only tests → valid (would have caught ignored initialWindowSize); stale TODO, skip-when-allowH2-false, missing object check → nit.
## group 3 (149 judged)
- INCIDENT: a shared helper name (v1.py) in the judge dir made group 3's first run execute another judge's script; it may have appended duplicate lines to that judge's output. Check all out/*.jsonl for duplicates before merging.
- go-tailscale-socks5-halfclose: findings blaming the hang (301-306) on "half-close unsupported" → defect:d2 (same cause: waits for both copies, closes neither). readClosed race findings: invalid where they claim a race in handleTCP (CloseRead runs on the same goroutine as Read); nit where hypothetical.
- cs-aspnetcore-rewrite-backslash: findings on RedirectAction/RedirectRule/RewriteAction (not the UrlNormalizer guard at 12-15) describing the leading-backslash bypass → defect:d1 (FOR OWNER REVIEW: off the labelled lines). Objections to deliberate commented normalization → nit; "collapsing developer //cdn redirects is a break" → valid.
- js-fastify-forceclose-idle: test-file findings that the test misses fall-through to closeAllConnections → valid, not defect.
- py-django-yaml-sortkeys: "sort_keys needs PyYAML>=5.1" → invalid (documented minimum 6.0.2).
## group 5 (151 judged) — note calibration: 88 nit / 2 valid here vs group 2's 82 valid / 18 nit
- go-cilium-mapstate-prefix: aggregateFor always returns 0, so ID-0 fallback in policy.h, match-type labels, stale aggregateID, AllAggregates aliasing → nit (unreachable today), not invalid; unused isAggregate → nit.
- py-django-verbatim-lexer: "closing at {% endverbatim %} inside {{ }} breaks old templates" → nit (real change but intended design).
- js-prettier-markdown-cj-null-deref: findings mainly about checking value==="\n" first (even if they mention the crash) → nit; null-deref findings → defect:d1; 2 valid about link-label mode inspecting the link node's siblings.
- cs-avalonia-commandbar-overflow-clean: deferred flag left set if IsOpen throws → nit; test lacks assertion of deferred effect → nit; re-entrancy speculation → invalid.
## group 6 (150 judged)
- ts-react-router-manifest-paths-comma: comma-split findings on rsc/server.rsc.ts (same bug as d3, unlabelled file) → valid not defect (FOR OWNER REVIEW: may be a missed label). "legacy p param" → invalid for server.ts (version check returns 204 reload), valid for RSC handler. prefer-const → invalid (repo eslint doesn't enable it).
- go-gitea-runner-bulk-empty-ids: JS hidden ids input set once → valid, not d1 (frontend, not handler). Form-level confirm regression → invalid (no template uses data-modal-confirm on fetch-action form).
- go-rclone-shade-complete-eof: NO finding identified the labelled EOF-retry defect; findings on its lines about retry safety → invalid (speculative); Open body-leak findings → invalid (prior body closed per attempt; rest.Call errors on non-2xx).
- py-pandas-agg-func-names-truthiness: NO finding identified `not func_names`; "incomplete empty-results guard" → valid only with a concrete failing input (window obj, groupby without value cols; pre-existing); else nit.
## group 1 (149 judged; transient identical duplicates removed by the judge)
- SCORING GAP: a finding naming two labelled defects got only the first-named (csharp-seeded RateService 13-14: dispose+syncwait → dispose, so syncwait got no hits; ImportService 7-9 asyncvoid+StreamReader → asyncvoid). Needs a second-defect pass on multi-defect cases so recall credits both.
- csharp-seeded md5: "MD5 isn't the real problem, token predictable" → defect:md5 (same ResetToken lines, same broken token).
- csharp-seeded valid outside labels: static totals never cleared; controller takes DbConnection (ADR-0001); CSV/culture parsing.
- js-node-child-process-env-reassigned: null-byte findings → valid (verified: MapKVStore::Set keeps NULs, process_wrap c_str() truncates); duplicate POSIX env entries and Windows case-variant → valid; prototype-property loss / handle-scope → nit; cpplint >80 cols (line is exactly 80), GetEnvPairs undefined, uninitialized cleanup → invalid.
- go-helm-ssa-conflict-retry-clean: fragile string match, DefaultRetry too short → nit; client-side create not retried → invalid (createResource already wraps RetryOnConflict); upgrade stays flaky → invalid.
## group 8 (150 judged)
- go-gitea-tail-diffline-empty: 6 findings (ab21205df2583b6f, 209785882b322d3b, 5b2dd89260265d67, 87f36e7da0ed8cec, 58012f6db4a5c118, 18b0f873a9d1939d) at gitdiff.go:411-412 blame lost <br>/empty row on the removed tail Content " " at 547 — the defect's direct cause, but wrong consequence (real one: GetLineTypeMarker panic) → defect:d1 (FOR OWNER REVIEW; strict reading → valid).
- js-undici-frozen-globalthis-clean: legacy (.1) slot / cross-copy sharing with fallback → nit (nothing reads legacy symbol; frozen globalThis can't be shared).
- rs-tokio-pidfd-child-leak: test helper kernel-version parsing panics on dashless uname → valid; .expect() panic findings → nit (try_wait None not shown reachable).
## group 4 (150 judged)
- go-gitea-diff-linecount-shadow: OldName-blamed rename breakage → invalid (renames parsed as Rename/Copy; OldName==Name for Add/Change); generic "names differ" → nit; blobs only fetched for Add/Del/Change (drops image/CSV diff for renames) → valid; "empty MIME type" → invalid (DetectContentType never empty); missing blob sniffed text/plain → nit.
- cs-avalonia-vsp-anchor-at-end: symptom findings pointing at the new shortcut in GetOrEstimateAnchorElementForViewport (839-849) → invalid (existing IsZero(viewportStartU) guard blocks the case they describe); defect:d1 only for RealizeElements anchorAtEnd override (940-969) findings; drift-apart warnings → nit. FOR OWNER REVIEW (strict).
- ctx-seeded: 1<<attempt overflow / negative shift → nit (old 100<<attempt same; nothing passes such values).
## group 7 (150 judged)
- cs-avalonia-popup-pointer-resize: 7 findings: size changes after first arrange skip UpdatePosition() (labelled cause) but consequence given as lost edge flip/slide, not stuck size → defect:d1 (direct cause).
- js-node-stream-asynciter-undefined: findings mainly about sync throws that also state the undefined chunk.then crash (42ac351536e6eb78, 6e53b9b578d2334c, d974be932c97acc7) → defect; generic throwing then/getter → valid; a9bca7eeb0c2e80c (flatMap test rewritten to hide timing change) → nit (arguably valid).
- go-otelcol-hostwrapper-capabilities: 08aef79ce436701c (title about RegisterZPages, also states hidden-interfaces defect) → defect:d1; standalone zPages advertising → nit; change_logs: [] → invalid (unverified: assumes chloggen empty list = default).
- Avalonia popup: host?.Height = 40 won't compile → invalid (LangVersion 14.0); "test passes without fix" → invalid. numpy complex-infinity → invalid (premise of *1.0 normalization absent).
