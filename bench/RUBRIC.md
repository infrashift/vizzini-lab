# Judging rubric (vizzini-lab ADR-0013)

You judge code-review findings, one at a time, on their merits. You do not
know, and must not try to guess, which tool or model wrote a finding. Judge
every finding against the actual code: the case's `change.patch` (the change
under review) and, for context, the files in the case's `checkout` directory
(the repository at the change's head). Never run anything from a checkout.

Each case directory has:
- `case.json`: kind (`buggy` or `clean`), the labelled `defects` (id, file and
  lines in head numbering, description; `buggy` cases only), and `checkout`.
- `change.patch`: the reviewed diff (base..head).
- `findings.jsonl`: one finding per line: key, file, start_line, end_line,
  title, body, and a short code excerpt (`>` marks the finding's lines).

## Verdicts (exactly one per finding)

- `defect:<id>` — the finding identifies that labelled defect: it points at
  the defect's code AND describes the same problem (the same wrong behaviour
  or its direct cause). Being on the right lines is not enough: a finding on
  the defect's lines about something else is not `defect:<id>`. A finding
  that describes the defect but anchors a few lines off still counts. If it
  describes two labelled defects, pick the one it is mainly about.
- `valid` — a real, correct problem in the change that a careful reviewer
  would want raised: a bug, a security issue, a resource or concurrency
  problem, a real robustness gap, a misleading API or doc that will cause
  misuse, a missing test for risky logic. It must be true of this code.
- `nit` — correct but trivial: style, naming, comment wording, formatting,
  micro-optimizations, "consider adding a test" with no specific risk,
  defensive checks for cases the code cannot reach.
- `invalid` — wrong about the code (misreads it, claims something the code
  does not do), speculative without basis in the code shown or the checkout,
  about code the change did not touch, or not actionable at all (praise,
  restating the diff).

## How to decide

- Read the finding's lines in `change.patch`, then as much of the checkout
  as you need to settle it (callers, definitions). Settle what you can from
  the code; when the claim depends on something you cannot see or verify and
  the code gives no reason to believe it, it is `invalid` (speculative).
- Severity words in the finding ("critical", "major") do not change the
  verdict. Judge the substance.
- Clean cases have no labelled defects; their findings can still be `valid`.
- Be consistent: the same claim gets the same verdict wherever it appears.

## Output

For each finding, one JSON line in your output file:
{"key": "<key>", "verdict": "defect:<id>|valid|nit|invalid", "reason": "<one sentence citing the code>"}
Every key in your cases' `findings.jsonl` must appear exactly once.
