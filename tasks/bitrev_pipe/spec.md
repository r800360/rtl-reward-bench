# bitrev_pipe

Write a two-stage pipeline that uses both clock edges.

```systemverilog
module bitrev_pipe #(parameter int N = 4) (
  input  logic         clk,     // 50 % duty cycle
  input  logic         reverse, invert,
  input  logic [N-1:0] din,
  output logic [N-1:0] dout
);
```

* On each **falling** edge of `clk`, register `din`.
* On the following **rising** edge (half a cycle later), register into `dout` that word with its bit order reversed
  if `reverse` is 1 and every bit inverted if `invert` is 1 (`reverse` and `invert` are sampled on the rising edge).
* Example, N = 4, din = 1110: 1110 (neither), 0111 (reverse), 0001 (invert), 1000 (both).
