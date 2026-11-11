"""Score a UAT run directory and write summary.md and scores.json into it.

Usage: python3 -I uat/score.py RUN_DIR FIXTURE_DIR [--require mrman,ado] [--stub]

--stub (a run against Vizzini's stubllm) turns the model-quality checks
(must-catch defects, ADR citations) into metrics: the stub only echoes lint.

RUN_DIR layout (written by uat/run.sh):
  fixture.patch, fixture.sarif, fixture/        the seeded repository
  <model>/review.json|.code|.err|.time           pr-review --mode review
  <model>/{describe,improve,plan}.json|.code|... the other modes
  <model>/garmr.json|.code                       garmr eval of review.json
  <model>/mrman.json|.code                       mrman headless session (optional)
  <model>/threads.json                           ADO PR threads (optional)
  oss/<model>/<label>/{review,describe,garmr}.*  real-world commits

Hard checks fail the run (exit 1). Metrics are reported, never fail it:
models differ, and a finding the ground truth does not list may still be
right.
"""
import json
import os
import re
import sys

ENVELOPE = ("vizzini.infrashift.io/v1", "Review")
REPAIR_GAVE_UP = "still invalid after"


class Checks:
    def __init__(self):
        self.rows = []  # (scope, name, ok, detail)

    def add(self, scope, name, ok, detail=""):
        self.rows.append((scope, name, bool(ok), detail))
        mark = "\033[32mPASS\033[0m" if ok else "\033[31mFAIL\033[0m"
        print(f"  {mark} [{scope}] {name}{': ' + detail if detail else ''}")

    @property
    def failed(self):
        return [r for r in self.rows if not r[2]]


def read(path, default=None):
    try:
        with open(path) as f:
            return f.read()
    except FileNotFoundError:
        return default


def read_json(path):
    s = read(path)
    if s is None:
        return None
    try:
        return json.JSONDecoder().raw_decode(s)[0]
    except ValueError:
        return None


def code_of(base):
    s = read(base + ".code")
    return int(s.strip()) if s and s.strip().lstrip("-").isdigit() else None


def time_of(base):
    s = read(base + ".time")
    try:
        return float(s)
    except (TypeError, ValueError):
        return None


def hunks(patch_text):
    """file -> (set of added new-side lines, list of (start, end) new-side hunk ranges)."""
    out, cur, new = {}, None, 0
    for line in patch_text.splitlines():
        if line.startswith("diff --git"):
            cur = None
            continue
        if line.startswith("+++ "):
            cur = line[6:].strip() if line.startswith("+++ b/") else None
            if cur:
                out.setdefault(cur, (set(), []))
            continue
        if line.startswith("--- "):
            continue
        m = re.match(r"@@ -\d+(?:,\d+)? \+(\d+)(?:,(\d+))?", line)
        if m and cur:
            new = int(m.group(1))
            n = int(m.group(2) or 1)
            out[cur][1].append((new, new + max(n, 1) - 1))
            continue
        if cur is None:
            continue
        if line.startswith("+"):
            out[cur][0].add(new)
            new += 1
        elif line.startswith(" "):
            new += 1
    return out


def anchored(f, diff):
    if f["file"] not in diff:
        return False
    return any(f["start_line"] <= e and f["end_line"] >= s for s, e in diff[f["file"]][1])


def anchor_lines(fixture_dir, file, anchors):
    text = read(os.path.join(fixture_dir, "change", file)) or read(os.path.join(fixture_dir, "base", file)) or ""
    lines = text.splitlines()
    out = []
    for a in anchors:
        for i, l in enumerate(lines, 1):
            if a in l:
                out.append(i)
                break
        else:
            raise SystemExit(f"score: anchor {a!r} not found in {file}; expected.json is stale")
    return out


def resolve_defects(fixture_dir, expected):
    out = []
    for d in expected["defects"]:
        by_file = d.get("anchors_by_file") or {d["file"]: d["anchors"]}
        targets = {f: anchor_lines(fixture_dir, f, a) for f, a in by_file.items()}
        out.append({**d, "targets": targets})
    return out


def matches(f, defect, tol):
    lines = defect["targets"].get(f["file"])
    return bool(lines) and any(f["start_line"] - tol <= ln <= f["end_line"] + tol for ln in lines)


def sarif_on_added(sarif, diff, root):
    prefix = "file://" + root.rstrip("/") + "/"
    n = 0
    for run in sarif.get("runs", []):
        for r in run.get("results", []):
            if not r.get("locations"):
                continue
            loc = r["locations"][0]["physicalLocation"]
            uri = loc["artifactLocation"]["uri"]
            line = loc.get("region", {}).get("startLine", 0)
            if uri.startswith(prefix):
                f = uri[len(prefix):]
                if line in diff.get(f, (set(), []))[0]:
                    n += 1
    return n


def check_review(ck, scope, base, diff, require_findings=True):
    r = read_json(base + ".json")
    code = code_of(base)
    err = read(base + ".err", "")
    ck.add(scope, "review exit code is 0 or 2 (policy gate)", code in (0, 2), f"exit {code}; {err.strip()[:200]}")
    ok_env = bool(r) and (r.get("apiVersion"), r.get("kind")) == ENVELOPE
    ck.add(scope, "report envelope", ok_env)
    ck.add(scope, "repair loop never gave up", REPAIR_GAVE_UP not in err, err.strip()[:200])
    if not ok_env:
        return None
    bad = [f for f in r["findings"] if not anchored(f, diff)]
    ck.add(scope, f"all {len(r['findings'])} finding(s) anchored to diff hunks", not bad,
           "; ".join(f"{f['file']}:{f['start_line']}-{f['end_line']}" for f in bad[:5]))
    if require_findings:
        ck.add(scope, "at least one finding", r["findings"])
    return r


def check_garmr(ck, scope, base, review):
    g = read_json(base + ".json")
    code = code_of(base)
    if not g:
        ck.add(scope, "garmr produced a decision", False, f"exit {code}")
        return None
    want_code = 1 if g["decision"] == "deny" else 0
    ck.add(scope, f"garmr exit code matches decision {g['decision']}", code == want_code, f"exit {code}")
    blocking = any(f["severity"] in ("Critical", "Major") for f in (review or {}).get("findings", []))
    failed = sorted(x["rule_id"] for x in g["results"] if not x["passed"])
    if blocking:
        ck.add(scope, "garmr denies a review with Critical/Major findings (VZ-001)",
               g["decision"] == "deny" and "VZ-001" in failed, f"{g['decision']} {failed}")
    return {"decision": g["decision"], "failed": failed}


def check_mode(ck, scope, base, mode, keys):
    if not os.path.exists(base + ".code"):
        return None  # not run (stub mode answers review prompts only)
    d = read_json(base + ".json")
    code = code_of(base)
    ok = code == 0 and isinstance(d, dict) and all(k in d for k in keys)
    ck.add(scope, f"{mode} returns a schema-valid answer", ok, f"exit {code}; {(read(base + '.err', '') or '').strip()[:160]}")
    return d


def score_model(ck, run, fixture_dir, expected, defects, diff, model, require):
    scope = model
    d = os.path.join(run, model)
    print(f"== {model}")
    r = check_review(ck, scope, os.path.join(d, "review"), diff)
    m = {"model": model}
    if r:
        tol = expected.get("tolerance", 2)
        per = {}
        for df in defects:
            hits = [f for f in r["findings"] if matches(f, df, tol)]
            per[df["id"]] = {
                "caught": bool(hits),
                "severity": max((f["severity"] for f in hits), key=lambda s: "Trivial Minor Major Critical".split().index(s), default=None),
                "category_ok": any(f["category"] in df["categories"] for f in hits),
                "cited": sorted({c for f in hits for c in f.get("citations") or []}),
            }
            if df.get("must_catch") and not STUB:
                ck.add(scope, f"must-catch defect {df['id']} caught", hits)
            if df.get("must_cite") and not STUB:
                cited = any(df["must_cite"] in (f.get("citations") or []) for f in r["findings"] if f["file"] in df["targets"])
                ck.add(scope, f"{df['id']}: a finding in its file cites ADR {df['must_cite'][:13]}…", cited)
        decoys = [f for f in r["findings"] if f["file"] in expected.get("decoys", [])]
        unmatched = [f for f in r["findings"] if f["file"] not in expected.get("decoys", [])
                     and not any(matches(f, df, tol) for df in defects)]
        kd = set(r.get("knowledge_docs") or [])
        kn = expected.get("knowledge", {})
        ck.add(scope, "knowledge: no irrelevant OKF document given to the model",
               not kd & set(kn.get("irrelevant", [])), str(sorted(kd)))
        ck.add(scope, "knowledge: the relevant ADRs were given to the model",
               set(kn.get("relevant", [])) <= kd, str(sorted(kd)))
        sarif = read_json(os.path.join(run, "fixture.sarif")) or {}
        want_diag = sarif_on_added(sarif, diff, os.path.join(run, "fixture"))
        ck.add(scope, f"exactly the {want_diag} changed-line Roslyn diagnostic(s) injected",
               r.get("diagnostics") == want_diag, f"diagnostics={r.get('diagnostics')}")
        m.update({
            "per_defect": per,
            "recall": sum(p["caught"] for p in per.values()) / len(per),
            "category_agreement": sum(p["category_ok"] for p in per.values() if p["caught"]) / max(1, sum(p["caught"] for p in per.values())),
            "findings": len(r["findings"]),
            "decoy_findings": len(decoys),
            "unmatched": [f"{f['file']}:{f['start_line']} {f['severity']}/{f['category']}: {f['title']}" for f in unmatched],
            "severities": {s: sum(f["severity"] == s for f in r["findings"]) for s in ("Critical", "Major", "Minor", "Trivial")},
            "architecture_findings": sum(f["category"] == "Architecture" for f in r["findings"]),
            "risk": (r["risk_score"], r["base_risk_score"], r["model_risk_score"]),
            "chunks": r["chunks"],
            "review_seconds": time_of(os.path.join(d, "review")),
            "exit": code_of(os.path.join(d, "review")),
        })
        m["garmr"] = check_garmr(ck, scope, os.path.join(d, "garmr"), r)
    check_mode(ck, scope, os.path.join(d, "describe"), "describe", ("title", "type", "summary", "changes"))
    check_mode(ck, scope, os.path.join(d, "improve"), "improve", ("suggestions",))
    plan = check_mode(ck, scope, os.path.join(d, "plan"), "plan", ())
    m["plan_ok"] = bool(plan)
    for mode in ("describe", "improve", "plan"):
        m[f"{mode}_seconds"] = time_of(os.path.join(d, mode))

    if "mrman" in require or os.path.exists(os.path.join(d, "mrman.json")):
        s = read_json(os.path.join(d, "mrman.json"))
        ck.add(scope, "mrman opened the PR headlessly", s is not None and code_of(os.path.join(d, "mrman")) == 0)
        if s is not None and r:
            got = s.get("vizzini", {}).get("findings")
            ck.add(scope, "mrman session carries every Vizzini finding",
                   isinstance(got, list) and len(got) == len(r["findings"]),
                   f"{len(got) if isinstance(got, list) else got} vs {len(r['findings'])}")
            risk = s.get("vizzini", {}).get("risk_score")
            ck.add(scope, "mrman shows the report's risk score", risk == r["risk_score"], f"{risk} vs {r['risk_score']}")
    if "ado" in require or os.path.exists(os.path.join(d, "threads.json")):
        t = read_json(os.path.join(d, "threads.json"))
        posted = []
        for th in (t or {}).get("value", []):
            ctx = th.get("threadContext") or {}
            if ctx.get("filePath") and ctx.get("rightFileStart"):
                posted.append((ctx["filePath"].lstrip("/"), ctx["rightFileStart"]["line"]))
        ck.add(scope, "ADO PR has inline threads", posted, f"{len(posted)} inline thread(s)")
        if r:
            want = [df for df in defects if df.get("must_catch")]
            tol = expected.get("tolerance", 2)
            missing = [df["id"] for df in want
                       if not any(df["targets"].get(fp) and any(abs(ln - a) <= tol + 3 for a in df["targets"][fp]) for fp, ln in posted)]
            ck.add(scope, "ADO threads sit on every must-catch defect", not missing, f"missing {missing}" if missing else "")
        m["ado_threads"] = len(posted)
    return m


def score_oss(ck, run, model):
    out = []
    root = os.path.join(run, "oss", model)
    if not os.path.isdir(root):
        return out
    for label in sorted(os.listdir(root)):
        d = os.path.join(root, label)
        scope = f"{model}/oss/{label}"
        print(f"== {scope}")
        diff = hunks(read(os.path.join(d, "change.patch"), ""))
        r = check_review(ck, scope, os.path.join(d, "review"), diff, require_findings=False)
        g = check_garmr(ck, scope, os.path.join(d, "garmr"), r) if r else None
        check_mode(ck, scope, os.path.join(d, "describe"), "describe", ("title", "type", "summary", "changes"))
        if r and label.startswith("large"):
            ck.add(scope, "large commit is reviewed in more than one chunk", r["chunks"] > 1, f"chunks={r['chunks']}")
        out.append({
            "label": label,
            "findings": len(r["findings"]) if r else None,
            "chunks": r["chunks"] if r else None,
            "severities": {s: sum(f["severity"] == s for f in r["findings"]) for s in ("Critical", "Major", "Minor", "Trivial")} if r else {},
            "risk": r["risk_score"] if r else None,
            "garmr": g["decision"] if g else None,
            "review_seconds": time_of(os.path.join(d, "review")),
            "titles": [f"{f['file']}:{f['start_line']} {f['severity']}/{f['category']}: {f['title']}" for f in (r or {}).get("findings", [])],
        })
    return out


def fmt_s(x):
    return "–" if x is None else f"{x:.0f}s"


def summary_md(run, models, results, oss, ck, manifest):
    L = [f"# UAT run {os.path.basename(run.rstrip('/'))}", ""]
    if manifest:
        L += ["| tool | version | commit |", "|---|---|---|"]
        for t, v in manifest.get("tools", {}).items():
            L.append(f"| {t} | {v['describe']} | `{v['commit'][:12]}` |")
        L += ["", f"Go: {manifest.get('go', '')}", ""]
    L += [f"**Hard checks:** {len(ck.rows) - len(ck.failed)}/{len(ck.rows)} passed" +
          (" — **FAILED**" if ck.failed else ""), ""]
    if ck.failed:
        L += ["| scope | check | detail |", "|---|---|---|"]
        L += [f"| {s} | {n} | {d[:160]} |" for s, n, _, d in ck.failed]
        L.append("")
    have = [m for m in results if "per_defect" in m]
    if have:
        L += ["## Seeded defects", "", "| defect | must catch | " + " | ".join(m["model"] for m in have) + " |",
              "|---|---|" + "---|" * len(have)]
        for did in have[0]["per_defect"]:
            mc = next((d.get("must_catch") for d in json.load(open(os.path.join(FIXTURE, "expected.json")))["defects"] if d["id"] == did), False)
            cells = []
            for m in have:
                p = m["per_defect"][did]
                cells.append(f"✅ {p['severity']}{'' if p['category_ok'] else ' (category?)'}" if p["caught"] else "❌")
            L.append(f"| {did} | {'yes' if mc else ''} | " + " | ".join(cells) + " |")
        L += ["", "## Per model", "", "| metric | " + " | ".join(m["model"] for m in have) + " |",
              "|---|" + "---|" * len(have)]
        rows = [
            ("recall", lambda m: f"{m['recall']:.0%}"),
            ("category agreement (caught)", lambda m: f"{m['category_agreement']:.0%}"),
            ("findings", lambda m: m["findings"]),
            ("Critical/Major/Minor/Trivial", lambda m: "/".join(str(m["severities"][s]) for s in ("Critical", "Major", "Minor", "Trivial"))),
            ("Architecture findings", lambda m: m["architecture_findings"]),
            ("findings on the clean decoy", lambda m: m["decoy_findings"]),
            ("unmatched findings", lambda m: len(m["unmatched"])),
            ("risk (final/diff/model)", lambda m: "/".join(map(str, m["risk"]))),
            ("garmr", lambda m: f"{m['garmr']['decision']} {','.join(m['garmr']['failed'])}" if m.get("garmr") else "–"),
            ("review / describe / improve / plan", lambda m: " / ".join(fmt_s(m.get(k)) for k in ("review_seconds", "describe_seconds", "improve_seconds", "plan_seconds"))),
            ("ADO inline threads", lambda m: m.get("ado_threads", "–")),
        ]
        for name, fn in rows:
            L.append(f"| {name} | " + " | ".join(str(fn(m)) for m in have) + " |")
        L.append("")
        for m in have:
            if m["unmatched"]:
                L += [f"### Unmatched findings: {m['model']}", "", "Not in the ground truth; judge by hand.", ""]
                L += [f"- {u}" for u in m["unmatched"]]
                L.append("")
    if any(oss.values()):
        L += ["## Real-world commits", "", "| model | commit | findings | C/M/m/T | chunks | risk | garmr | review |",
              "|---|---|---|---|---|---|---|---|"]
        for model, items in oss.items():
            for o in items:
                sv = "/".join(str(o["severities"].get(s, 0)) for s in ("Critical", "Major", "Minor", "Trivial"))
                L.append(f"| {model} | {o['label']} | {o['findings']} | {sv} | {o['chunks']} | {o['risk']} | {o['garmr']} | {fmt_s(o['review_seconds'])} |")
        L.append("")
        for model, items in oss.items():
            for o in items:
                if o["titles"]:
                    L += [f"### {model} / {o['label']}", ""] + [f"- {t}" for t in o["titles"]] + [""]
    return "\n".join(L)


FIXTURE = None
STUB = False


def main():
    global FIXTURE, STUB
    args = sys.argv[1:]
    if "--stub" in args:
        STUB = True
        args.remove("--stub")
    require = set()
    if "--require" in args:
        i = args.index("--require")
        require = set(filter(None, args[i + 1].split(",")))
        del args[i:i + 2]
    run, FIXTURE = args
    expected = json.load(open(os.path.join(FIXTURE, "expected.json")))
    defects = resolve_defects(FIXTURE, expected)
    diff = hunks(read(os.path.join(run, "fixture.patch"), ""))
    models = sorted(m for m in os.listdir(run)
                    if os.path.isdir(os.path.join(run, m)) and os.path.exists(os.path.join(run, m, "review.code")))
    ck = Checks()
    if not models:
        ck.add("run", "at least one model was run", False)
    results = [score_model(ck, run, FIXTURE, expected, defects, diff, m, require) for m in models]
    oss = {m: score_oss(ck, run, m) for m in sorted(os.listdir(os.path.join(run, "oss")))} if os.path.isdir(os.path.join(run, "oss")) else {}
    manifest = read_json(os.path.join(run, "build-manifest.json"))
    md = summary_md(run, models, results, oss, ck, manifest)
    open(os.path.join(run, "summary.md"), "w").write(md + "\n")
    json.dump({"models": results, "oss": oss, "checks": [dict(zip(("scope", "name", "ok", "detail"), r)) for r in ck.rows]},
              open(os.path.join(run, "scores.json"), "w"), indent=2)
    print(f"\nsummary: {os.path.join(run, 'summary.md')}")
    print(f"hard checks: {len(ck.rows) - len(ck.failed)}/{len(ck.rows)} passed")
    sys.exit(1 if ck.failed else 0)


if __name__ == "__main__":
    main()
