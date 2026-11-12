"""bench_compare.py: compare tools across two benchmark runs (lab ADR-0013).

    python3 -I uat/bench_compare.py RUN_A TOOL_A RUN_B TOOL_B [MODEL...]

Both runs are scored by uat/bench.py first (scores.json). For each model,
on the real pull requests only (the seeded fixtures excluded), it prints
judged recall and strict precision for A and B, and the paired difference
A - B with a 95% bootstrap interval over cases. "holds" when the interval
excludes 0. Use it to compare a new Vizzini commit with an earlier run.
"""

import json
import os
import random
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import bench  # noqa: E402


def stats(run, tool, model):
    d = json.load(open(os.path.join(run, "scores.json")))
    ndef = {c["case"]: len(c["defects"]) for c in d["cases"]}
    out = {}
    for r in d["rows"]:
        if r["tool"] == tool and r["model"] == model and r["ok"] and not r["case"].endswith("-seeded"):
            fs = r["findings"]
            out[r["case"]] = (ndef[r["case"]] if r["kind"] == "buggy" else 0, len(bench.hit_ids(fs)), len(fs),
                              sum(1 for f in fs if f["label"] and (f["label"].startswith("defect:") or f["label"] == "valid")),
                              sum(1 for f in fs if r["kind"] == "clean"))
    return out


def ratio(st, ids, num, den):
    n, d = sum(st[i][num] for i in ids), sum(st[i][den] for i in ids)
    return n / d if d else 0.0


def main():
    run_a, tool_a, run_b, tool_b, *models = sys.argv[1:]
    models = models or ["claude-sonnet-5-5", "claude-opus-5-5"]
    rng = random.Random(32)
    for m in models:
        a, b = stats(run_a, tool_a, m), stats(run_b, tool_b, m)
        ids = sorted(set(a) & set(b))
        draws = [[rng.choice(ids) for _ in ids] for _ in range(2000)]
        print(f"\n{m}: {tool_a} ({os.path.basename(run_a)}) vs {tool_b} ({os.path.basename(run_b)}), {len(ids)} real cases")
        for name, num, den in (("judged recall", 1, 0), ("strict precision", 3, 2)):
            va, vb = ratio(a, ids, num, den), ratio(b, ids, num, den)
            diffs = sorted(ratio(a, d_, num, den) - ratio(b, d_, num, den) for d_ in draws)
            lo, hi = diffs[50], diffs[1949]
            print(f"  {name:17} {va:5.0%} vs {vb:5.0%}  diff {va - vb:+.0%} [{lo:+.0%}, {hi:+.0%}] {'holds' if lo > 0 or hi < 0 else ''}")
        fa, fb = sum(a[i][2] for i in ids), sum(b[i][2] for i in ids)
        ca, cb = sum(a[i][4] for i in ids), sum(b[i][4] for i in ids)
        print(f"  findings per PR   {fa / len(ids):.1f} vs {fb / len(ids):.1f};  on clean PRs {ca} vs {cb}")


if __name__ == "__main__":
    main()
