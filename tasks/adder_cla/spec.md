# adder_cla

Write an N-bit adder whose carries do not ripple.

```systemverilog
module adder_cla #(parameter int N = 16) (
  input  logic [N-1:0] a, b,
  input  logic         cin,
  output logic [N:0]   sum      // a + b + cin; sum[N] is the carry out
);
```

* Function: `sum = a + b + cin`.
* Speed: for N = 16, the longest path through the design as written must be at most 12 gate levels, measured on
  Yosys's generic gates without re-optimization (`synth -noabc; techmap; ltp`). A ripple-carry adder has about 2N.
