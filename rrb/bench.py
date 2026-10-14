"""Run every grader on every candidate of every task.

usage: python3 -m rrb.bench [task ...] [--jobs N]
Writes results/grades.csv (one row per task, candidate and grader: verdict; deterministic), results/details/<task>.txt
(every grader's log) and results/timing.csv (tool seconds per row; machine-dependent, not compared by `make check`).
With task names, only those tasks are rerun and their rows replace the old ones in the CSV files.
"""
import concurrent.futures
import csv
import os
import sys

from . import graders
from .tasks import ROOT, all_tasks, load_task

RESULTS = os.path.join(ROOT, "results")


def grade_candidate(tid, cname):
    task = load_task(tid)
    cand = next(c for c in task["candidates"] if c["name"] == cname)
    rows = []
    for g in graders.GRADERS:
        r = graders.run_grader(g, task, cand)
        rows.append((tid, cname, cand["label"], cand["class"], g, r.verdict, r.seconds, r.detail))
    return rows


def main(argv):
    jobs = 1
    if "--jobs" in argv:
        i = argv.index("--jobs")
        jobs = int(argv[i + 1])
        argv = argv[:i] + argv[i + 2:]
    tids = argv or all_tasks()
    work = [(tid, c["name"]) for tid in tids for c in load_task(tid)["candidates"]]
    rows = []
    with concurrent.futures.ThreadPoolExecutor(max_workers=jobs) as ex:
        for res in ex.map(lambda w: grade_candidate(*w), work):
            rows += res
            print(f"{res[0][0]:16s} {res[0][1]:28s} {res[0][2]:8s} " +
                  " ".join(f"{r[4]}={r[5]}" for r in res), flush=True)
    os.makedirs(RESULTS, exist_ok=True)
    grades = [list(r[:6]) for r in rows]
    timing = [[r[0], r[1], r[4], f"{r[6]:.3f}"] for r in rows]
    _write(os.path.join(RESULTS, "grades.csv"), ["task", "candidate", "label", "class", "grader", "verdict"],
           grades, tids, 4)
    _write(os.path.join(RESULTS, "timing.csv"), ["task", "candidate", "grader", "seconds"], timing, tids, 2)
    details = os.path.join(RESULTS, "details")
    os.makedirs(details, exist_ok=True)
    for tid in tids:
        with open(os.path.join(details, f"{tid}.txt"), "w", newline="\n") as f:
            for r in rows:
                if r[0] == tid:
                    f.write(f"== {r[1]} [{r[2]}] {r[4]}: {r[5]}\n{_clean(r[7])}\n")


def _write(path, header, new, tids, gcol):
    """Write a CSV of the new rows plus the old rows of every task that was not rerun (and still exists)."""
    keep = []
    if os.path.exists(path):
        alive = set(all_tasks())
        keep = [r for r in list(csv.reader(open(path)))[1:] if r[0] not in tids and r[0] in alive]
    rows = sorted(keep + new, key=lambda r: (r[0], r[1], graders.GRADERS.index(r[gcol])))
    with open(path, "w", newline="") as f:
        w = csv.writer(f, lineterminator="\n")
        w.writerow(header)
        w.writerows(rows)


def _clean(text):
    """Detail text without run times, memory use, absolute paths or tool timestamps, so results/details is
    reproducible."""
    import re
    text = text.replace(ROOT + "/", "")
    text = re.sub(r"SBY\s+\d+:\d+:\d+\s+", "SBY ", text)
    text = re.sub(r"\[\d+:\d+:\d+\]", "", text)
    text = re.sub(r"\d+(\.\d+)?\s*(s|seconds|ms)\b", "<t>", text)
    drop = ("Walltime", "walltime", "Elapsed", "S i m u l a t i o n", "- Verilator:")
    return "\n".join(l for l in text.splitlines() if not any(d in l for d in drop))


if __name__ == "__main__":
    main(sys.argv[1:])
