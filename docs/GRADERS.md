# Graders

Every grader takes one task and one design and returns `pass`, `fail`, `error` (the tool could not run the design,
for example a syntax error) or `n/a` (the task does not define that grader). They live in
[`rrb/graders.py`](../rrb/graders.py). Each one runs in its own directory, `build/rrb/<task>/<design>/<grader>/`, so
designs can be graded in parallel. Its log goes to `results/details/<task>.txt`, with run times and absolute paths
removed so the file is the same on every machine.

| Grader | Tool and command | Passes when |
|---|---|---|
| `compile` | `iverilog -g2012 -s tb_weak <design> tb_weak.sv` | the design elaborates against the testbench's instantiation (names, ports, parameters) |
| `lint` | `verilator --lint-only -Wall` at the task's synthesis parameters | Verilator prints no warning at all |
| `weak` | Icarus Verilog 12, the task's `tb_weak.sv` | the testbench prints `RESULT: PASS` |
| `strong_icarus` | Icarus Verilog 12, `tb_strong.sv`, once per parameter set in `task.json` | every run prints `RESULT: PASS` |
| `strong_verilator` | `verilator --binary --timing`, the same testbench and parameter sets | every run prints `RESULT: PASS` |
| `formal` | SymbiYosys 0.52 on `harness.sv` (engines below) | the proof succeeds |
| `synth` | Yosys 0.52 `synth -flatten; abc -g simple`, plus the task's rules | no latch, and every rule holds |
| `timed` | Yosys netlist + Icarus with a random delay on every gate, 8 trials | no trial fails the task's `tb_timed.sv` |

## Testbenches

Every testbench includes [`tb/tb_util.svh`](../tb/tb_util.svh), compares with `!==` (an X on the design side is
always a mismatch) and ends with exactly one line, `RESULT: PASS <n> checks` or `RESULT: FAIL <k> of <n> checks`.
Graders read only that line, so a design that hangs or crashes the simulation fails.

* **Weak** testbenches are what a specification often comes with: a handful of directed vectors at the default
  parameters, with partial checks. They stand for the cheap reward.
* **Strong** testbenches are exhaustive where the input space allows it (all inputs of the combinational tasks at
  small N, all 16 data words with every 0-, 1- and 2-bit error for the Hamming decoder), otherwise thousands of
  random vectors against a behavioral model, and they cover several parameter values, ties, resets in every state,
  inputs that change half a cycle before an edge, and baud-rate offsets.

## Formal

The harness instantiates the golden design and the candidate side by side. The golden file is read first and its
modules are renamed `gold_<name>`, so both can be elaborated together.

* **Combinational tasks**: `assert` on every output for every input, SMT solver (Z3) at depth 1, which is an
  exhaustive equivalence check.
* **Sequential tasks**: lockstep equivalence from reset with free inputs, `abc pdr` (an unbounded proof).
* **`serial_rx`**: protocol properties only (valid lasts one cycle, data changes only with valid, valid and
  frame_err are exclusive), k-induction at depth 24. They say nothing about which byte is received, which is why
  two receiver bugs pass this grader.

Every harness fixes one parameter value (N = 4, 5, 8 or 16). Bugs that appear only at other values (the 4-bit ALU core,
the wrong LFSR taps for N = 8) therefore pass formal and fail the strong testbench, which runs several values.
Tasks whose behavior depends on both clock edges or on delays (`clkdiv3`, `bitrev_pipe`) have no formal grader.
SBY occasionally reports a PDR counterexample and then fails to replay it as a trace; "returned FAIL" in the log
counts as a failure. When a k-induction proof fails, the base case and the induction step run in parallel and
whether the induction step reports before it is stopped varies from run to run, so its lines are left out of the
committed log.

## Synthesis rules

Every design is synthesized to 2-input gates; any latch fails. Tasks add rules that a functional test cannot see:

| Rule | Task | How it is measured |
|---|---|---|
| `only_instances` | `log_shifter` | before flattening, `select` lists every cell of the top module other than `mux2` instances; there must be none |
| `max_depth` | `adder_cla` | `synth -noabc; techmap; opt -fast; ltp -noff` at N = 16: the longest path through generic gates must be at most 12 |
| `sync_inputs` | `serial_rx` | in the synthesized netlist (JSON), the asynchronous input must drive exactly one flip-flop's D pin, whose output drives exactly one more flip-flop, before any logic |

The logic depth is measured without ABC on purpose. ABC re-optimizes the structure for area and can turn a
Kogge-Stone adder into something deeper than a ripple adder, so its depth says nothing about what was written.
`techmap` keeps the architecture; Yosys's own `+` operator becomes its lookahead adder with 16 levels.

## Timed gate-level simulation

[`tb/timed_cells.v`](../tb/timed_cells.v) gives each Yosys gate type a transport delay. Each gate instance draws one
delay between 1 and 5 ns at time 0 (a fixed delay per gate keeps the events of one gate in order, as in hardware);
`+TRIAL=<k>` shifts the random stream, so each of the 8 trials is a different delay assignment. Flip-flops have
1 ns clock-to-Q. Before simulation, Yosys legalizes every flip-flop with reset or enable into a plain D flip-flop
plus gates, so the timed models stay small.

`clkdiv3`'s timed testbench measures every high and low pulse of the output clock: any pulse shorter than 10 ns (half
an input period) is a glitch. Zero-delay simulation and formal cannot see a glitch at all; a design that decodes its
output from several counter bits that change at the same edge produces one in some trials.

## Reward stacks

[`rrb/report.py`](../rrb/report.py) also scores stacks of graders: a stack rewards a design only if every grader in
it passes or is `n/a`. The **full stack** is `compile`, both strong testbenches, `formal`, `synth` and `timed`;
`lint` is left out because it rejects correct designs for style. [`rrb/env.py`](../rrb/env.py) runs a stack in this
order, cheapest first, and stops at the first failure.
