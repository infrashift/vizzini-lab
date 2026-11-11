"""Print SQL recording a UAT run's review facts in vizzini_run_facts.

Usage: python3 -I uat/record_runs.py RUN_DIR | litellm/litellm.sh psql -

For every report with a run_id in RUN_DIR (review, describe, improve,
plan; seeded fixtures and real-world commits), one row: run_id, pr_key,
iteration, agent, model, fixture, and for reviews the findings, blocking
(Critical + Major), the gate's exit code and the risk score. LiteLLM
knows what each request cost; these are the facts only the run knows, so
cost per finding can be computed (Vizzini ISSUE-025).
"""
import json
import os
import sys


def lit(v):
    if v is None:
        return "NULL"
    if isinstance(v, int):
        return str(v)
    return "'" + str(v).replace("'", "''") + "'"


def main():
    run = sys.argv[1]
    rows = []
    for dirpath, _, files in os.walk(run):
        for mode in ("review", "describe", "improve", "plan"):
            if mode + ".json" not in files or mode + ".code" not in files:
                continue
            try:
                r = json.load(open(os.path.join(dirpath, mode + ".json")))
            except ValueError:
                continue
            if not isinstance(r, dict) or not r.get("run_id"):
                continue
            rel = os.path.relpath(dirpath, run).split(os.sep)
            model = rel[-1] if rel[0] != "oss" else rel[1]
            fixture = rel[0] if rel[0] != "oss" else "oss/" + rel[2]
            code = open(os.path.join(dirpath, mode + ".code")).read().strip()
            # Findings and the gate exist only for reviews.
            findings = r.get("findings") if mode == "review" else None
            rows.append("(" + ", ".join([
                lit(r["run_id"]), lit(r.get("pr_key")), lit(r.get("iteration")), lit(r.get("agent")), lit(model),
                lit(fixture), lit(len(findings)) if findings is not None else "NULL",
                lit(sum(f["severity"] in ("Critical", "Major") for f in findings)) if findings is not None else "NULL",
                (lit(int(code)) if code.lstrip("-").isdigit() else "NULL") if mode == "review" else "NULL",
                lit(r.get("risk_score")),
            ]) + ")")
    if not rows:
        return
    print("INSERT INTO vizzini_run_facts (run_id, pr_key, iteration, agent, model, fixture, findings, blocking, gate_exit, risk_score) VALUES")
    print(",\n".join(rows))
    print("ON CONFLICT (run_id) DO NOTHING;")


if __name__ == "__main__":
    main()
