"""bench_labels.py: merge judges' verdicts into bench/labels.json (lab ADR-0013).

    python3 -I uat/bench_labels.py RUN_DIR JUDGE_NAME VERDICTS.jsonl...

Each input line is {"key", "verdict", "reason"}. A key must be one of the
run's findings (RUN_DIR/to-label.jsonl or already labelled); the verdict must
be "valid", "nit", "invalid" or "defect:<id>" with an id of that finding's
case. A key judged twice in the inputs, or a bad line, stops the merge and
nothing is written. Existing labels are kept; new ones are added with the
judge's name.
"""

import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def main():
    run, judge, *paths = sys.argv[1:]
    pending = {}
    for line in open(os.path.join(run, "to-label.jsonl")):
        it = json.loads(line)
        pending[it["key"]] = {d["id"] for d in it["defects"]}
    labels_path = os.path.join(ROOT, "bench", "labels.json")
    labels = json.load(open(labels_path)) if os.path.exists(labels_path) else {}
    new, errors = {}, []
    for p in paths:
        for n, line in enumerate(open(p), 1):
            if not line.strip():
                continue
            try:
                v = json.loads(line)
                key, verdict, reason = v["key"], v["verdict"], v["reason"].strip()
            except (ValueError, KeyError, AttributeError) as e:
                errors.append(f"{p}:{n}: {e}")
                continue
            if key in new:
                errors.append(f"{p}:{n}: {key} judged twice")
            elif key not in pending:
                errors.append(f"{p}:{n}: {key} is not a pending finding of this run")
            elif not (verdict in ("valid", "nit", "invalid") or
                      (re.fullmatch(r"defect:[\w-]+", verdict) and verdict[7:] in pending[key])):
                errors.append(f"{p}:{n}: bad verdict {verdict!r}")
            elif not reason:
                errors.append(f"{p}:{n}: no reason")
            elif any(a not in pending[key] or a == verdict[7:] for a in v.get("also") or []):
                errors.append(f"{p}:{n}: bad also {v.get('also')!r}")
            else:
                new[key] = {"verdict": verdict, "reason": reason, "judge": judge}
                if v.get("also"):
                    new[key]["also"] = list(v["also"])
    missing = sorted(set(pending) - set(new) - set(labels))
    if errors:
        sys.exit("bench_labels: not merged:\n  " + "\n  ".join(errors[:30]))
    labels.update(new)
    with open(labels_path, "w") as f:
        json.dump(dict(sorted(labels.items())), f, indent=1, ensure_ascii=False)
        f.write("\n")
    print(f"merged {len(new)} verdicts; {len(labels)} labels in all; {len(missing)} findings still unjudged")


if __name__ == "__main__":
    main()
