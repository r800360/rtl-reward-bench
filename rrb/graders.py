"""Graders: each takes a task and a candidate design and returns a Result (verdict, tool seconds, detail).

    compile        Icarus elaborates the candidate together with the task's weak testbench (interface check)
    lint           verilator --lint-only -Wall: pass only without warnings
    weak           the task's weak testbench (few directed vectors, partial checks), Icarus
    strong_icarus  the strong self-checking testbench, every parameter set, Icarus
    strong_verilator  the same testbench, Verilator
    formal         SymbiYosys: equivalence with the golden design (or the task's properties)
    synth          Yosys synthesis, plus the task's structural, logic-depth or synchronizer constraints
    timed          gate-level simulation of the synthesized netlist with random gate delays (glitch detection)

A verdict is "pass", "fail" or "error" (the tool could not run the candidate at all, e.g. a syntax error).
Every grader runs in its own directory under build/rrb/<task>/<candidate>/<grader>/.
"""
import json
import os
import re
import shutil
import subprocess
import time

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BUILD = os.path.join(ROOT, "build", "rrb")
TB = os.path.join(ROOT, "tb")
GRADERS = ("compile", "lint", "weak", "strong_icarus", "strong_verilator", "formal", "synth", "timed")


class Result:
    def __init__(self, verdict, seconds, detail=""):
        self.verdict, self.seconds, self.detail = verdict, seconds, detail

    def to_dict(self):
        return {"verdict": self.verdict, "seconds": round(self.seconds, 3), "detail": self.detail}


def _run(cmd, cwd, timeout=600):
    t = time.monotonic()
    try:
        p = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True, timeout=timeout,
                           stdin=subprocess.DEVNULL, errors="replace")
        return p.returncode, p.stdout + p.stderr, time.monotonic() - t
    except subprocess.TimeoutExpired:
        return 124, "timeout", time.monotonic() - t


def _workdir(task, cand, grader):
    d = os.path.join(BUILD, task["id"], cand["name"], grader)
    shutil.rmtree(d, ignore_errors=True)
    os.makedirs(d)
    return d


def _libs(task):
    return [os.path.join(ROOT, "lib", f) for f in task.get("lib", [])]


def _passed(out):
    return re.search(r"^RESULT: PASS", out, re.M) is not None


def _iverilog_run(task, cand, wd, tb, top, params, extra_files=()):
    files = _libs(task) + [cand["path"], os.path.join(task["dir"], tb)] + list(extra_files)
    pflags = [f"-P{top}.{k}={v}" for k, v in params.items()]
    rc, out, t1 = _run(["iverilog", "-g2012", "-I", TB, "-Wno-timescale", "-s", top, *pflags, "-o", "sim.vvp", *files], wd)
    if rc:
        return "error", t1, out
    rc, out2, t2 = _run(["vvp", "-n", "sim.vvp"], wd, timeout=300)
    return ("pass" if _passed(out2) else "fail"), t1 + t2, out2


def compile(task, cand):                                   # noqa: A001 - grader name
    wd = _workdir(task, cand, "compile")
    files = _libs(task) + [cand["path"], os.path.join(task["dir"], task["weak"]["tb"])]
    rc, out, t = _run(["iverilog", "-g2012", "-I", TB, "-Wno-timescale", "-s", task["weak"]["top"], "-o", "x.vvp",
                       *files], wd)
    return Result("pass" if rc == 0 else "fail", t, out[-2000:])


def lint(task, cand):
    wd = _workdir(task, cand, "lint")
    params = [f"-G{k}={v}" for k, v in task.get("synth", {}).get("params", {}).items()]
    rc, out, t = _run(["verilator", "--lint-only", "-Wall", "-Wno-DECLFILENAME", "-Wno-MULTITOP", "-I" + TB,
                       "--top-module", task["top"], *params, *_libs(task), cand["path"]], wd)
    warn = [l for l in out.splitlines() if l.startswith("%")]
    if any(l.startswith("%Error") and "Exiting due to" not in l for l in warn):
        return Result("error", t, "\n".join(warn[:20]))
    return Result("pass" if not warn else "fail", t, "\n".join(warn[:20]))


def weak(task, cand):
    wd = _workdir(task, cand, "weak")
    v, t, out = _iverilog_run(task, cand, wd, task["weak"]["tb"], task["weak"]["top"], {})
    return Result(v, t, out[-2000:])


def strong_icarus(task, cand):
    wd = _workdir(task, cand, "strong_icarus")
    total, verdict, logs = 0.0, "pass", []
    for params in task["strong"].get("params", [{}]):
        v, t, out = _iverilog_run(task, cand, wd, task["strong"]["tb"], task["strong"]["top"], params)
        total += t
        logs.append(f"{params}: {v}")
        if v != "pass":
            verdict = v if verdict == "pass" else verdict
            logs.append(out[-1500:])
    return Result(verdict, total, "\n".join(logs))


def strong_verilator(task, cand):
    wd = _workdir(task, cand, "strong_verilator")
    total, verdict, logs = 0.0, "pass", []
    for i, params in enumerate(task["strong"].get("params", [{}])):
        obj = os.path.join(wd, f"obj{i}")
        files = _libs(task) + [cand["path"], os.path.join(task["dir"], task["strong"]["tb"])]
        pflags = [f"-G{k}={v}" for k, v in params.items()]
        rc, out, t1 = _run(["verilator", "--binary", "--timing", "-I" + TB, "-Wno-fatal", "-Wno-lint", "-Wno-style",
                            "-Wno-TIMESCALEMOD", "--top-module", task["strong"]["top"], *pflags, "-Mdir", obj, "-o",
                            "sim", *files], wd)
        if rc:
            total += t1
            verdict = "error" if verdict == "pass" else verdict
            logs.append(f"{params}: build error\n" + out[-1500:])
            continue
        rc, out2, t2 = _run([os.path.join(obj, "sim")], wd, timeout=300)
        total += t1 + t2
        v = "pass" if _passed(out2) else "fail"
        logs.append(f"{params}: {v}")
        if v != "pass":
            verdict = v if verdict == "pass" else verdict
            logs.append(out2[-1500:])
    return Result(verdict, total, "\n".join(logs))


def _module_names(path):
    return re.findall(r"^\s*module\s+(\w+)", open(path).read(), re.M)


def formal(task, cand):
    if "formal" not in task:
        return Result("n/a", 0.0, "")
    wd = _workdir(task, cand, "formal")
    f = task["formal"]
    golden = os.path.join(task["dir"], task.get("golden", "golden.sv"))
    shutil.copy(golden, os.path.join(wd, "golden.sv"))
    shutil.copy(cand["path"], os.path.join(wd, "candidate.sv"))
    shutil.copy(os.path.join(task["dir"], f["harness"]), os.path.join(wd, "harness.sv"))
    libs = []
    for p in _libs(task):
        shutil.copy(p, wd)
        libs.append(os.path.basename(p))
    renames = "; ".join(f"rename {m} gold_{m}" for m in _module_names(golden))
    defines = " ".join(f"-D{d}" for d in f.get("defines", []))
    engine = {"smtbmc": "smtbmc z3", "pdr": "abc pdr", "bmc3": "abc bmc3"}[f.get("engine", "smtbmc")]
    lines = ["[options]", f"mode {f.get('mode', 'prove')}"]
    if f.get("mode", "prove") != "prove" or f.get("engine", "smtbmc") == "smtbmc":
        lines.append(f"depth {f.get('depth', 20)}")
    lines += ["", "[engines]", engine, "", "[script]"]
    if libs:
        lines.append("read_verilog -sv " + " ".join(libs))
    lines += [f"read_verilog -sv {defines} golden.sv", renames, f"read_verilog -sv {defines} candidate.sv",
              f"read_verilog -sv -formal {defines} harness.sv", f"prep -top {f['top']}", "", "[files]",
              "golden.sv", "candidate.sv", "harness.sv", *libs]
    open(os.path.join(wd, "check.sby"), "w").write("\n".join(lines) + "\n")
    rc, out, t = _run(["sby", "-f", "check.sby"], wd, timeout=900)
    summary = "\n".join(l for l in out.splitlines() if "summary" in l or "DONE" in l or "ERROR" in l)
    if rc == 0:
        return Result("pass", t, summary)
    # a counterexample, even when SBY then fails to replay it as a trace (abc pdr): "returned FAIL"
    if "returned FAIL" in out or "failed assertion" in out or "DONE (FAIL" in out:
        return Result("fail", t, summary)
    return Result("error", t, summary or out[-1500:])


def _yosys(task, cand, wd, script):
    files = " ".join(_libs(task) + [cand["path"]])
    params = " ".join(f"-set {k} {v}" for k, v in task.get("synth", {}).get("params", {}).items())
    chparam = f"chparam {params} {task['top']};" if params else ""
    return _run(["yosys", "-q", "-p", f"read_verilog -sv {files}; hierarchy -top {task['top']}; {chparam} {script}"], wd)


def synth(task, cand):
    wd = _workdir(task, cand, "synth")
    s = task.get("synth", {})
    total = 0.0
    detail = []
    # structure: cells of the top module (before flattening) other than the allowed submodule instances
    if "only_instances" in s:
        allowed = " ".join(f"{task['top']}/t:{m} %d" for m in s["only_instances"])
        rc, out, t = _yosys(task, cand, wd, f"proc; opt_clean; tee -q -o cells.txt select -list {task['top']}/t:* {allowed}")
        total += t
        if rc:
            return Result("error", total, out[-1500:])
        other = [l for l in open(os.path.join(wd, "cells.txt")).read().splitlines() if l.strip()]
        detail.append(f"cells other than {s['only_instances']}: {len(other)}")
        if other:
            return Result("fail", total, "\n".join(detail + other[:10]))
    rc, out, t = _yosys(task, cand, wd, "synth -flatten; abc -g simple; opt_clean; delete t:$scopeinfo; "
                                        "tee -q -o stat.txt stat; write_json netlist.json")
    total += t
    if rc:
        return Result("error", total, out[-1500:])
    stat = open(os.path.join(wd, "stat.txt")).read()
    cells = re.search(r"Number of cells:\s+(\d+)", stat)
    detail.append(f"cells after ABC mapping to 2-input gates: {int(cells.group(1)) if cells else 0}")
    if re.search(r"\$_DLATCH", stat):
        return Result("fail", total, "\n".join(detail + ["latch inferred"]))
    for port, stages in s.get("sync_inputs", {}).items():
        problem = _sync_chain(os.path.join(wd, "netlist.json"), task["top"], port, stages)
        detail.append(f"input {port}: " + (problem or f"enters through a chain of {stages} flip-flops"))
        if problem:
            return Result("fail", total, "\n".join(detail))
    if "max_depth" in s:
        # depth of the architecture as written: generic gates from techmap, without ABC re-optimizing the structure
        rc, out, t = _yosys(task, cand, wd, "synth -flatten -noabc; techmap; opt -fast; opt_clean; "
                                            "tee -q -o ltp.txt ltp -noff")
        total += t
        if rc:
            return Result("error", total, out[-1500:])
        m = re.search(r"length=(\d+)", open(os.path.join(wd, "ltp.txt")).read())
        depth = int(m.group(1)) if m else 0
        detail.append(f"logic depth {depth} (limit {s['max_depth']})")
        if depth > s["max_depth"]:
            return Result("fail", total, "\n".join(detail))
    return Result("pass", total, "\n".join(detail))


def _sync_chain(path, top, port, stages):
    """Structural CDC rule: an asynchronous input must feed exactly one flip-flop D pin, whose output feeds exactly
    one more flip-flop, and so on for `stages` flip-flops, before any logic sees it. Returns a problem or ""."""
    mod = json.load(open(path))["modules"][top]
    loads = {}
    for name, cell in mod["cells"].items():
        for pin, bits in cell["connections"].items():
            if cell["port_directions"].get(pin) == "input":
                for b in bits:
                    loads.setdefault(b, []).append((name, pin))
    bit = mod["ports"][port]["bits"][0]
    for k in range(stages):
        sinks = loads.get(bit, [])
        if len(sinks) != 1:
            return f"stage {k + 1}: drives {len(sinks)} cell inputs, expected one flip-flop"
        name, pin = sinks[0]
        cell = mod["cells"][name]
        if "DFF" not in cell["type"] or pin != "D":
            return f"stage {k + 1}: drives {cell['type']} pin {pin} (logic before synchronization)"
        bit = cell["connections"]["Q"][0]
    return ""


def timed(task, cand):
    """Synthesize to generic gates and flip-flops, then simulate the netlist with a random delay on every gate."""
    tm = task.get("timed")
    if not tm:
        return Result("n/a", 0.0, "")
    wd = _workdir(task, cand, "timed")
    rc, out, t1 = _yosys(task, cand, wd, "synth -flatten; abc -g gates; opt_clean; "
                                         "dfflegalize -cell $_DFF_P_ x -cell $_DFF_N_ x; techmap; opt_clean; "
                                         f"rename {task['top']} {task['top']}_gl; write_verilog -noattr -noexpr netlist.v")
    if rc:
        return Result("error", t1, out[-1500:])
    files = [os.path.join(TB, "timed_cells.v"), os.path.join(wd, "netlist.v"), os.path.join(task["dir"], tm["tb"])]
    rc, out, t2 = _run(["iverilog", "-g2012", "-I", TB, "-Wno-timescale", "-s", tm["top"], "-o", "gl.vvp", *files], wd)
    if rc:
        return Result("error", t1 + t2, out[-1500:])
    total, failed = t1 + t2, []
    for trial in range(tm.get("trials", 8)):                 # a different random delay assignment per trial
        rc, out2, t3 = _run(["vvp", "-n", "gl.vvp", f"+TRIAL={trial}"], wd, timeout=300)
        total += t3
        if not _passed(out2):
            failed.append(f"trial {trial}:\n{out2[-800:]}")
    return Result("fail" if failed else "pass", total, "\n".join(failed[:2]) or "no glitch in any trial")


def run_grader(name, task, cand):
    return globals()[name](task, cand)
