"""bench.py: score a head-to-head benchmark run (uat/bench.sh, Vizzini ISSUE-022).

    python3 -I uat/bench.py RUN_DIR [CASES_TSV]

1. Normalizes each tool's output to findings (file, lines, severity, title, body):
   vizzini / vizzini-norepo: pr-review's JSON report;
   pa-review: PR-Agent's key_issues_to_review (its free-text security_concerns
   has no lines, so it is kept apart as file-level notes);
   pa-improve: PR-Agent's code_suggestions; pa = pa-review + pa-improve.
2. Matches findings to the ground truth by location: same file, lines
   overlapping a defect's lines within the fixture's tolerance (the issue's
   rule). That gives location recall, with no judgement involved.
3. Judgement: bench/labels.json holds one verdict per finding, keyed by a
   hash of (case, file, lines, text), so a finding is judged once and reused.
   Verdicts: "defect:<id>" (it describes that labelled defect), "valid" (a
   real, correct problem in the change), "nit" (correct but trivial: style,
   naming, docs), "invalid" (wrong, speculative without basis, or not about
   the change). Findings with no verdict are written, without tool or model,
   to RUN/to-label.jsonl, shuffled, for blind judging.
4. Writes RUN/summary.md and RUN/scores.json.

Judged recall: a defect is caught when some finding is labelled defect:<id>.
Precision (strict): (defect + valid) / judged. Lenient also counts nits.
"""

import hashlib
import json
import os
import random
import re
import statistics
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TOOLS = ["vizzini", "vizzini-norepo", "vizzini-lint", "vizzini-lint-kb", "pa-review", "pa-improve", "pa-review-kb", "pa-improve-kb"]
REPORTED = ["vizzini", "vizzini+filtered", "vizzini-norepo", "vizzini-lint", "vizzini-lint-kb", "pa", "pa-kb", "pa-review", "pa-improve", "pa-review-kb", "pa-improve-kb"]
PER_CASE = ["vizzini", "vizzini-lint", "vizzini-lint-kb", "pa", "pa-kb"]
# pa / pa-kb: PR-Agent review + improve, as one tool.
COMBINED = {"pa": ("pa-review", "pa-improve"), "pa-kb": ("pa-review-kb", "pa-improve-kb")}
PRICES = {"claude-sonnet-5-5": (2e-06, 1e-05), "claude-opus-5-5": (4e-06, 2e-05)}  # LiteLLM /model/info


def load(path, default=None):
    try:
        with open(path) as f:
            return json.load(f)
    except (OSError, ValueError):
        return default


def strip(x):
    return str(x or "").strip()


def to_int(x, default=0):
    try:
        return int(str(x).strip())
    except ValueError:
        return default


def key_of(case, f):
    raw = "\x1f".join([case, f["file"], str(f["start_line"]), str(f["end_line"]), f["title"], f["body"]])
    return hashlib.sha256(raw.encode()).hexdigest()[:16]


# --- ground truth ---------------------------------------------------------------

def anchor_line(fx, file, anchor):
    for sub in ("change", "base"):
        p = os.path.join(fx, sub, file)
        if os.path.exists(p):
            for i, line in enumerate(open(p).read().splitlines(), 1):
                if anchor in line:
                    return i
    sys.exit(f"bench: anchor {anchor!r} not found in {file}; {fx}/expected.json is stale")


def truth(case_id, kind, real_cases):
    """(defects, decoy files, tolerance, case kind: buggy|clean)."""
    if kind == "seeded":
        fx = os.path.join(ROOT, "fixtures", case_id)
        exp = load(os.path.join(fx, "expected.json"))
        defects = []
        for d in exp["defects"]:
            by_file = d.get("anchors_by_file") or {d["file"]: d["anchors"]}
            defects.append({"id": d["id"], "description": d.get("note", ""),
                            "targets": {f: sorted({anchor_line(fx, f, a) for a in anchors}) for f, anchors in by_file.items()}})
        return defects, exp.get("decoys", []), exp.get("tolerance", 2), "buggy"
    c = real_cases[case_id]
    defects = [{"id": f"d{i + 1}", "description": d["description"],
                "targets": {d["file"]: list(range(d["start_line"], d["end_line"] + 1))}}
               for i, d in enumerate(c.get("defects", []))]
    return defects, [], 2, c["kind"]


def hit_ids(findings):
    """The labelled defects that judged findings describe."""
    out = set()
    for f in findings:
        if (f["label"] or "").startswith("defect:"):
            out.add(f["label"][7:])
            out.update(f.get("also") or [])
    return out


def overlaps(f, d, tol):
    lines = d["targets"].get(f["file"])
    return bool(lines) and any(f["start_line"] - tol <= ln <= f["end_line"] + tol for ln in lines)


# --- normalization --------------------------------------------------------------

def normalize(tool, doc):
    """(findings, file-level notes) from one tool's JSON, or None when it failed."""
    if not doc:
        return None
    out, notes = [], []
    if tool.startswith("vizzini"):
        # "<tool>+filtered" is the same report with the noise floor's
        # filtered findings put back (ISSUE-032).
        both = tool.endswith("+filtered")
        for f in (doc.get("findings") or []) + ((doc.get("filtered") or []) if both else []):
            out.append({"file": f["file"], "start_line": f["start_line"], "end_line": f["end_line"],
                        "severity": f.get("severity", ""), "category": f.get("category", ""),
                        "title": f.get("title", ""), "body": (f.get("body", "") + ("\n\nSuggestion: " + f["suggestion"] if f.get("suggestion") else "")).strip()})
    elif tool.startswith("pa-review"):
        r = doc.get("review")
        if r is None:
            return None
        for k in r.get("key_issues_to_review") or []:
            if not isinstance(k, dict):
                continue
            s = to_int(k.get("start_line"))
            out.append({"file": strip(k.get("relevant_file")), "start_line": s, "end_line": max(s, to_int(k.get("end_line"), s)),
                        "severity": "", "category": "", "title": strip(k.get("issue_header")), "body": strip(k.get("issue_content"))})
        sc = strip(r.get("security_concerns"))
        if sc and not re.match(r"^no\b", sc, re.I):
            notes = [ln.strip() for ln in sc.splitlines() if ln.strip()]
    elif tool.startswith("pa-improve"):
        if "code_suggestions" not in doc:
            return None
        for s in doc.get("code_suggestions") or []:
            a = to_int(s.get("relevant_lines_start"))
            score = to_int(s.get("score"), 0)
            out.append({"file": strip(s.get("relevant_file")), "start_line": a, "end_line": max(a, to_int(s.get("relevant_lines_end"), a)),
                        "severity": "Major" if score >= 8 else "Minor" if score >= 5 else "Info",
                        "category": strip(s.get("label")), "title": strip(s.get("one_sentence_summary")),
                        "body": strip(s.get("suggestion_content")) + ("\n\nImproved code:\n" + strip(s.get("improved_code")) if s.get("improved_code") else "")})
    return out, notes


def usage(tool, doc, model):
    """(input tokens, output tokens, cost in USD)."""
    if not doc:
        return 0, 0, 0.0
    if tool.startswith("vizzini"):
        u = doc.get("usage") or {}
        return u.get("input_tokens", 0), u.get("output_tokens", 0), float(u.get("cost_usd") or 0)
    u = doc.get("usage") or {}
    i, o = u.get("prompt_tokens", 0) or 0, u.get("completion_tokens", 0) or 0
    pi, po = PRICES.get(model, (0, 0))
    return i, o, i * pi + o * po


def snippet(case_id, kind, f, ctx=3):
    path = os.path.join(ROOT, ".cache", "bench-repos", case_id, f["file"])
    try:
        lines = open(path, errors="replace").read().splitlines()
    except OSError:
        return "(file not in the head checkout)"
    a, b = max(1, f["start_line"] - ctx), min(len(lines), f["end_line"] + ctx)
    return "\n".join(f"{i:5} {'>' if f['start_line'] <= i <= f['end_line'] else ' '} {lines[i - 1]}" for i in range(a, b + 1))


# --- scoring --------------------------------------------------------------------

def main():
    run = sys.argv[1]
    listing = sys.argv[2] if len(sys.argv) > 2 else os.path.join(run, "cases.all.tsv")
    if not os.path.exists(listing):
        listing = os.path.join(run, "cases.tsv")
    cases = [l.rstrip("\n").split("\t") for l in open(listing) if l.strip()]
    real_cases = {c["id"]: c for c in (load(os.path.join(ROOT, "bench", "cases.json"), {"cases": []})["cases"])}
    labels = load(os.path.join(ROOT, "bench", "labels.json"), {}) or {}
    models = sorted({m for cid, _ in cases for m in (os.listdir(os.path.join(run, cid)) if os.path.isdir(os.path.join(run, cid)) else [])
                     if os.path.isdir(os.path.join(run, cid, m))})
    rows, to_label, per_case = [], {}, []
    # A run of a Vizzini with the noise floor (ISSUE-032) gets a second view,
    # "vizzini+filtered", in every case: a report the floor filtered nothing
    # from has no "filtered" list.
    floor_run = any('"filtered"' in open(p_).read() for p_ in __import__("glob").glob(os.path.join(run, "*", "*", "vizzini.json")))
    for cid, kind in cases:
        defects, decoys, tol, ckind = truth(cid, kind, real_cases)
        for model in models:
            d = os.path.join(run, cid, model)
            if not os.path.isdir(d):
                continue
            present = [t for t in TOOLS if os.path.exists(os.path.join(d, f"{t}.time"))]
            if "vizzini" in present and floor_run:
                present.append("vizzini+filtered")
            for tool in present:
                src = tool.split("+")[0]
                doc = load(os.path.join(d, f"{src}.json"))
                t = (open(os.path.join(d, f"{src}.time")).read().split() if os.path.exists(os.path.join(d, f"{src}.time")) else ["?", "0"])
                # pr-review exits 2 when its severity gate fails: a complete report.
                norm = normalize(tool, doc) if t[0] == "0" or (tool.startswith("vizzini") and t[0] == "2") else None
                i, o, cost = usage(tool, doc, model)
                rec = {"case": cid, "kind": ckind, "model": model, "tool": tool, "ok": norm is not None,
                       "seconds": float(t[1]), "in": i, "out": o, "cost": cost, "findings": [], "notes": [],
                       "carried": os.path.exists(os.path.join(d, f"{src}.carried"))}
                if norm:
                    rec["notes"] = norm[1]
                    for f in norm[0]:
                        f = dict(f, key=key_of(cid, f))
                        f["loc"] = [x["id"] for x in defects if overlaps(f, x, tol)]
                        f["decoy"] = f["file"] in decoys
                        f["label"] = (labels.get(f["key"]) or {}).get("verdict")
                        # A finding that describes more than one labelled defect
                        # names the others in "also" (recall only).
                        f["also"] = list((labels.get(f["key"]) or {}).get("also") or [])
                        if f["label"] is None and f["key"] not in to_label:
                            to_label[f["key"]] = {"key": f["key"], "case": cid, "case_kind": ckind,
                                                  "defects": [{"id": x["id"], "where": x["targets"], "description": x["description"]} for x in defects],
                                                  "file": f["file"], "start_line": f["start_line"], "end_line": f["end_line"],
                                                  "title": f["title"], "body": f["body"], "location_matches": f["loc"],
                                                  "code": snippet(cid, kind, f)}
                        rec["findings"].append(f)
                rows.append(rec)
        per_case.append({"case": cid, "kind": ckind, "defects": [x["id"] for x in defects], "decoys": decoys})

    for cid, _ in cases:
        for model in models:
          for name, parts in COMBINED.items():
            pr = [r for r in rows if r["case"] == cid and r["model"] == model and r["tool"] in parts]
            if len(pr) == 2:
                rows.append({"case": cid, "kind": pr[0]["kind"], "model": model, "tool": name, "ok": all(r["ok"] for r in pr),
                             "carried": all(r["carried"] for r in pr),
                             "seconds": sum(r["seconds"] for r in pr), "in": sum(r["in"] for r in pr), "out": sum(r["out"] for r in pr),
                             "cost": sum(r["cost"] for r in pr), "findings": [f for r in pr for f in r["findings"]],
                             "notes": [n for r in pr for n in r["notes"]]})

    items = list(to_label.values())
    random.Random(22).shuffle(items)
    with open(os.path.join(run, "to-label.jsonl"), "w") as f:
        for it in items:
            f.write(json.dumps(it) + "\n")

    case_defects = {c["case"]: c["defects"] for c in per_case}
    scores = {}
    for tool in REPORTED:
        for model in models:
            rs = [r for r in rows if r["tool"] == tool and r["model"] == model]
            if not rs:
                continue
            ok = [r for r in rs if r["ok"]]
            fs = [f for r in ok for f in r["findings"]]
            n_def = sum(len(case_defects[r["case"]]) for r in rs if r["kind"] == "buggy")
            loc = sum(len({d for f in r["findings"] for d in f["loc"]}) for r in ok)
            judged_hits = sum(len(hit_ids(r["findings"])) for r in ok)
            judged = [f for f in fs if f["label"]]
            good = [f for f in judged if f["label"].startswith("defect:") or f["label"] == "valid"]
            nits = [f for f in judged if f["label"] == "nit"]
            clean = [r for r in ok if r["kind"] == "clean"]
            sec = [r["seconds"] for r in ok]
            scores[f"{tool}/{model}"] = {
                "tool": tool, "model": model, "cases": len(rs), "failed": len(rs) - len(ok),
                "findings": len(fs), "findings_per_case": round(len(fs) / len(ok), 2) if ok else 0,
                "defects": n_def, "location_hits": loc, "location_recall": round(loc / n_def, 3) if n_def else None,
                "judged_hits": judged_hits, "judged_recall": round(judged_hits / n_def, 3) if n_def and len(judged) == len(fs) else None,
                "judged": len(judged), "pending": len(fs) - len(judged),
                "precision_strict": round(len(good) / len(judged), 3) if judged else None,
                "precision_lenient": round((len(good) + len(nits)) / len(judged), 3) if judged else None,
                "invalid": sum(1 for f in judged if f["label"] == "invalid"),
                "clean_cases": len(clean), "clean_findings": sum(len(r["findings"]) for r in clean),
                "clean_invalid": sum(1 for r in clean for f in r["findings"] if f["label"] == "invalid"),
                "decoy_hits": sum(1 for f in fs if f["decoy"]),
                "file_level_notes": sum(len(r["notes"]) for r in ok),
                "carried": sum(1 for r in rs if r.get("carried")),
                "median_seconds": round(statistics.median(sec), 1) if sec else None,
                "tokens_in": sum(r["in"] for r in rs), "tokens_out": sum(r["out"] for r in rs),
                "cost_usd": round(sum(r["cost"] for r in rs), 4),
            }
    # Uncertainty: 95% bootstrap intervals over cases (each configuration ran
    # once, so this covers which cases were drawn, not run-to-run variation),
    # and paired differences for the comparisons the write-up makes.
    def per_case_stats(tool, model):
        out = {}
        for r in rows:
            if r["tool"] == tool and r["model"] == model and r["ok"]:
                fs = r["findings"]
                out[r["case"]] = (len(case_defects[r["case"]]) if r["kind"] == "buggy" else 0, len(hit_ids(fs)),
                                  sum(1 for f in fs if f["label"]),
                                  sum(1 for f in fs if f["label"] and (f["label"].startswith("defect:") or f["label"] == "valid")))
        return out
    def ratio(stats, ids, num, den):
        n, d = sum(stats[i][num] for i in ids if i in stats), sum(stats[i][den] for i in ids if i in stats)
        return n / d if d else None
    rng = random.Random(22)
    ids_all = [c["case"] for c in per_case]
    draws = [[rng.choice(ids_all) for _ in ids_all] for _ in range(2000)]
    def ci(vals):
        vals = sorted(v for v in vals if v is not None)
        return [round(vals[int(0.025 * len(vals))], 3), round(vals[int(0.975 * len(vals)) - 1], 3)] if vals else None
    stats = {(t, m): per_case_stats(t, m) for t in REPORTED for m in models}
    for k, sc in scores.items():
        st = stats[(sc["tool"], sc["model"])]
        sc["judged_recall_ci"] = ci([ratio(st, d, 1, 0) for d in draws])
        sc["precision_strict_ci"] = ci([ratio(st, d, 3, 2) for d in draws])
    pairs = [("vizzini", "vizzini+filtered"), ("vizzini", "pa"), ("vizzini-lint-kb", "pa-kb"), ("vizzini", "vizzini-norepo"),
             ("vizzini-lint", "vizzini"), ("vizzini-lint-kb", "vizzini-lint"), ("pa-kb", "pa")]
    comparisons = []
    for a, b in pairs:
        for m in models:
            sa, sb = stats[(a, m)], stats[(b, m)]
            if not sa or not sb:
                continue
            for name, num, den in (("judged recall", 1, 0), ("strict precision", 3, 2)):
                point = (ratio(sa, ids_all, num, den) or 0) - (ratio(sb, ids_all, num, den) or 0)
                diffs = [(ratio(sa, d, num, den) or 0) - (ratio(sb, d, num, den) or 0) for d in draws]
                lo, hi = ci(diffs)
                comparisons.append({"a": a, "b": b, "model": m, "metric": name, "diff": round(point, 3), "ci": [lo, hi],
                                    "holds": lo > 0 or hi < 0})
    json.dump({"scores": scores, "comparisons": comparisons, "rows": rows, "cases": per_case},
              open(os.path.join(run, "scores.json"), "w"), indent=1)

    pct = lambda x: "—" if x is None else f"{x:.0%}"
    out = [f"# Head-to-head review benchmark: {os.path.basename(run)}\n",
           f"{len(cases)} cases ({sum(1 for c in per_case if c['kind'] == 'buggy')} with labelled defects, "
           f"{sum(1 for c in per_case if c['kind'] == 'clean')} clean); models: {', '.join(models)}. "
           f"{len(items)} findings await a verdict (to-label.jsonl).\n",
           "| Tool | Model | Failed | Carried | Findings/case | Location recall | Judged recall | Precision (strict / lenient) | Invalid | On clean PRs (invalid) | Decoy hits | Median s | Tokens in/out | Cost |",
           "|---|---|---|---|---|---|---|---|---|---|---|---|---|---|"]
    for s in scores.values():
        out.append(f"| {s['tool']} | {s['model']} | {s['failed']}/{s['cases']} | {s['carried']} | {s['findings_per_case']} | "
                   f"{pct(s['location_recall'])} ({s['location_hits']}/{s['defects']}) | "
                   f"{pct(s['judged_recall'])}{'' if s['judged_recall'] is not None else ' (pending)'} | "
                   f"{pct(s['precision_strict'])} / {pct(s['precision_lenient'])}{(' (' + str(s['pending']) + ' pending)') if s['pending'] else ''} | "
                   f"{s['invalid']} | {s['clean_findings']} ({s['clean_invalid']}) | {s['decoy_hits']} | {s['median_seconds']} | "
                   f"{s['tokens_in']}/{s['tokens_out']} | ${s['cost_usd']:.2f} |")
    out.append("\n95% bootstrap intervals over cases:\n")
    out.append("| Tool | Model | Judged recall | Strict precision |")
    out.append("|---|---|---|---|")
    for sc in scores.values():
        r, p_ = sc["judged_recall_ci"], sc["precision_strict_ci"]
        out.append(f"| {sc['tool']} | {sc['model']} | {pct(sc['judged_recall'])} [{pct(r[0]) if r else '—'}, {pct(r[1]) if r else '—'}] | "
                   f"{pct(sc['precision_strict'])} [{pct(p_[0]) if p_ else '—'}, {pct(p_[1]) if p_ else '—'}] |")
    real_ids = [c["case"] for c in per_case if not c["case"].endswith("-seeded")]
    rdraws = [[rng.choice(real_ids) for _ in real_ids] for _ in range(2000)]
    out.append("\n## Real pull requests only (the seeded fixtures excluded), with 95% bootstrap intervals\n")
    out.append("| Tool | Model | Defects found | Judged recall | Strict precision | Lenient precision |")
    out.append("|---|---|---|---|---|---|")
    for sc in scores.values():
        st = stats[(sc["tool"], sc["model"])]
        n = sum(st[i][0] for i in real_ids if i in st)
        h = sum(st[i][1] for i in real_ids if i in st)
        rec, prec = ratio(st, real_ids, 1, 0), ratio(st, real_ids, 3, 2)
        rci, pci = ci([ratio(st, d_, 1, 0) for d_ in rdraws]), ci([ratio(st, d_, 3, 2) for d_ in rdraws])
        fs = [f for r in rows if r["tool"] == sc["tool"] and r["model"] == sc["model"] and r["ok"] and r["case"] in real_ids for f in r["findings"] if f["label"]]
        len_ = sum(1 for f in fs if f["label"] != "invalid") / len(fs) if fs else None
        sc["real"] = {"defects": n, "hits": h, "recall": rec, "recall_ci": rci, "precision_strict": prec, "precision_strict_ci": pci, "precision_lenient": len_}
        out.append(f"| {sc['tool']} | {sc['model']} | {h}/{n} | {pct(rec)} [{pct(rci[0]) if rci else '—'}, {pct(rci[1]) if rci else '—'}] | "
                   f"{pct(prec)} [{pct(pci[0]) if pci else '—'}, {pct(pci[1]) if pci else '—'}] | {pct(len_)} |")
    real_comparisons = []
    for a_, b_ in pairs:
        for m in models:
            sa, sb = stats[(a_, m)], stats[(b_, m)]
            if not sa or not sb:
                continue
            for name, num, den in (("judged recall", 1, 0), ("strict precision", 3, 2)):
                point = (ratio(sa, real_ids, num, den) or 0) - (ratio(sb, real_ids, num, den) or 0)
                lo, hi = ci([(ratio(sa, d_, num, den) or 0) - (ratio(sb, d_, num, den) or 0) for d_ in rdraws])
                real_comparisons.append({"a": a_, "b": b_, "model": m, "metric": name, "diff": round(point, 3),
                                         "ci": [lo, hi], "holds": lo > 0 or hi < 0})
    out.append("\n## Paired comparisons, real pull requests only\n")
    out.append("| A | B | Model | Metric | Difference | Interval | Holds |")
    out.append("|---|---|---|---|---|---|---|")
    for c in real_comparisons:
        out.append(f"| {c['a']} | {c['b']} | {c['model']} | {c['metric']} | {c['diff']:+.0%} | [{c['ci'][0]:+.0%}, {c['ci'][1]:+.0%}] | {'yes' if c['holds'] else 'no'} |")
    json.dump({"scores": scores, "comparisons": comparisons, "real_comparisons": real_comparisons, "rows": rows, "cases": per_case},
              open(os.path.join(run, "scores.json"), "w"), indent=1)
    out.append("\n## Paired comparisons, all cases (A minus B, same cases; 95% bootstrap interval; 'holds' when it excludes 0)\n")
    out.append("| A | B | Model | Metric | Difference | Interval | Holds |")
    out.append("|---|---|---|---|---|---|---|")
    for c in comparisons:
        out.append(f"| {c['a']} | {c['b']} | {c['model']} | {c['metric']} | {c['diff']:+.0%} | [{c['ci'][0]:+.0%}, {c['ci'][1]:+.0%}] | {'yes' if c['holds'] else 'no'} |")
    out.append("\n## Per case (judged hits / defects; findings)\n")
    out.append("| Case | Kind | " + " | ".join(f"{t} {m.replace('claude-', '').replace('-5-5', '')}" for t in PER_CASE for m in models) + " |")
    out.append("|---|---|" + "---|" * (len(PER_CASE) * len(models)))
    for c in per_case:
        cells = []
        for t in PER_CASE:
            for m in models:
                r = next((r for r in rows if r["case"] == c["case"] and r["tool"] == t and r["model"] == m), None)
                if not r:
                    cells.append("")
                elif not r["ok"]:
                    cells.append("failed")
                else:
                    hits = len(hit_ids(r["findings"]))
                    loc = len({d for f in r["findings"] for d in f["loc"]})
                    cells.append((f"{hits}/{len(c['defects'])} ({loc} loc); {len(r['findings'])}" if c["defects"] else f"{len(r['findings'])}")
                                 + (" (carried)" if r.get("carried") else ""))
        out.append(f"| {c['case']} | {c['kind']} | " + " | ".join(cells) + " |")
    text = "\n".join(out) + "\n"
    open(os.path.join(run, "summary.md"), "w").write(text)
    print(text)


if __name__ == "__main__":
    main()
