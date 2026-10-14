# log_shifter

Write an N-bit barrel shifter built **only** from instances of the provided 2:1 multiplexer
`mux2 (input a0, a1, s, output y)` (y = s ? a1 : a0). No operators, gates, `?:`, `case` or `always` blocks in
`log_shifter` itself: every selection must be a `mux2` instance.

```systemverilog
module log_shifter #(parameter int N = 4) (
  input  logic                 rotate,   // 0: shift (vacated bits become 0), 1: rotate
  input  logic                 left,     // 0: move bits right (toward bit 0), 1: move bits left
  input  logic [$clog2(N)-1:0] amt,      // 0 .. N-1 positions
  input  logic [N-1:0]         din,
  output logic [N-1:0]         dout
);
```

N is a power of two from 2 to 32.
