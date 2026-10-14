# subtractor

Write a configurable signed subtractor with overflow flags (combinational).

```systemverilog
module subtractor #(parameter int N = 4) (
  input  logic                sub_ab,    // 1: D = A - B, 0: D = B - A
  input  logic signed [N-1:0] a, b,
  output logic signed [N-1:0] d,         // the low N bits of the difference
  output logic                ovf_pos,   // the true difference is above 2^(N-1) - 1
  output logic                ovf_neg    // the true difference is below -2^(N-1)
);
```

N from 2 to 32.
