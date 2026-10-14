"""Tasks and candidates.

A task is a folder tasks/<id>/ with task.json, spec.md (what an agent is given), golden.sv (reference design),
tb_weak.sv, tb_strong.sv, harness.sv (formal) and candidates/*.sv. Each candidate starts with header comments:
    // label: correct | bug
    // class: <kind of bug>          (bugs only)
    // note: <what it does wrong, and which grader can see it>
The golden design is also graded, as the candidate "golden" (label correct).
"""
import json
import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TASKS = os.path.join(ROOT, "tasks")


def _header(path):
    h = {}
    for line in open(path):
        m = re.match(r"//\s*(label|class|note):\s*(.*)", line)
        if m:
            h[m.group(1)] = (h.get(m.group(1), "") + " " + m.group(2)).strip()
        elif line.strip() and not line.startswith("//"):
            break
    return h


def load_task(tid):
    d = os.path.join(TASKS, tid)
    t = json.load(open(os.path.join(d, "task.json")))
    t["dir"] = d
    t["spec_text"] = open(os.path.join(d, "spec.md")).read()
    cands = [{"name": "golden", "path": os.path.join(d, t.get("golden", "golden.sv")), "label": "correct",
              "class": "", "note": "the reference design"}]
    cdir = os.path.join(d, "candidates")
    for f in sorted(os.listdir(cdir)):
        if f.endswith(".sv"):
            h = _header(os.path.join(cdir, f))
            if h.get("label") not in ("correct", "bug"):
                raise ValueError(f"{tid}/{f}: header must start with '// label: correct' or '// label: bug'")
            cands.append({"name": f[:-3], "path": os.path.join(cdir, f), "label": h["label"],
                          "class": h.get("class", ""), "note": h.get("note", "")})
    t["candidates"] = cands
    return t


def all_tasks():
    return sorted(d for d in os.listdir(TASKS) if os.path.isfile(os.path.join(TASKS, d, "task.json")))
