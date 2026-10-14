# acs_unit

Write the add-compare-select unit of one Viterbi trellis state (combinational).

```systemverilog
module acs_unit #(parameter int W = 8) (
  input  logic         v0, v1,        // is predecessor 0 / 1 valid (reachable)?
  input  logic [1:0]   bm0, bm1,      // branch metrics of the two incoming branches
  input  logic [W-1:0] pm0, pm1,      // path metrics of the two predecessors
  output logic         sel,           // 1: predecessor 1 wins
  output logic         valid,
  output logic [W-1:0] pm             // the new path metric
);
```

* Costs: `c0 = pm0 + bm0`, `c1 = pm1 + bm1` (W bits).
* Only one valid: that one wins. Both valid: predecessor 1 wins only if `c0 > c1` (ties go to predecessor 0).
* Neither valid: `sel = 0`, `valid = 0`, `pm = 0`. Otherwise `valid = 1` and `pm` is the winner's cost.
