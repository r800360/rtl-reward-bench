"""A reward environment over the tasks: reset() gives a policy the specification, step(design) grades a design.

    env = RTLRewardEnv("acs_unit")
    obs = env.reset()                       # {"task", "title", "spec"}
    reward, info = env.step(open("my_acs.sv").read())

The reward runs graders cheapest first and stops at the first failure. Two shapes:
    binary  1.0 only if every grader passes (the "full stack" of results/report.md by default)
    staged  the fraction of graders passed before the first failure (denser signal, same maximum)
info holds each grader's verdict, seconds and the end of its log, which is what a policy can be shown as feedback.

usage: python3 -m rrb.env <task> <design.sv> [--staged]
"""
import hashlib
import json
import os
import sys

from . import graders
from .tasks import ROOT, load_task

DEFAULT_STACK = ("compile", "strong_icarus", "strong_verilator", "formal", "synth", "timed")


class RTLRewardEnv:
    def __init__(self, task_id, stack=DEFAULT_STACK, shape="binary"):
        if shape not in ("binary", "staged"):
            raise ValueError("shape must be 'binary' or 'staged'")
        self.task = load_task(task_id)
        self.stack, self.shape = tuple(stack), shape

    def reset(self):
        return {"task": self.task["id"], "title": self.task["title"], "spec": self.task["spec_text"]}

    def step(self, design_text):
        digest = hashlib.sha256(design_text.encode()).hexdigest()[:12]
        d = os.path.join(ROOT, "build", "env", self.task["id"])
        os.makedirs(d, exist_ok=True)
        path = os.path.join(d, f"{digest}.sv")
        with open(path, "w", newline="\n") as f:
            f.write(design_text)
        cand = {"name": f"env_{digest}", "path": path, "label": "unknown", "class": "", "note": ""}
        info, passed = {"design": digest, "graders": []}, 0
        for g in self.stack:
            r = graders.run_grader(g, self.task, cand)
            info["graders"].append({"grader": g, "verdict": r.verdict, "seconds": round(r.seconds, 3),
                                    "log": "\n".join(r.detail.splitlines()[-25:])})
            if r.verdict not in ("pass", "n/a"):
                break
            passed += 1
        done = passed == len(self.stack)
        reward = (1.0 if done else 0.0) if self.shape == "binary" else passed / len(self.stack)
        info["seconds"] = round(sum(x["seconds"] for x in info["graders"]), 3)
        return reward, info


def main(argv):
    shape = "staged" if "--staged" in argv else "binary"
    argv = [a for a in argv if a != "--staged"]
    if len(argv) != 2:
        sys.exit(__doc__)
    env = RTLRewardEnv(argv[0], shape=shape)
    env.reset()
    reward, info = env.step(open(argv[1]).read())
    for g in info["graders"]:
        print(f"{g['grader']:18s} {g['verdict']}")
    print(json.dumps({"reward": reward, "seconds": info["seconds"]}))


if __name__ == "__main__":
    main(sys.argv[1:])
