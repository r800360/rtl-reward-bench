# alu_reg

Write an N-bit ALU with a registered output.

```systemverilog
module alu_reg #(parameter int N = 4) (
  input  logic         clk,
  input  logic         rst,      // asynchronous, active high
  input  logic [1:0]   op,
  input  logic [N-1:0] a, b,
  output logic [N-1:0] y
);
```

* `op`: 00 → a + b, 01 → a − b, 10 → a & b, 11 → a | b, all modulo 2^N.
* `y` takes the result on every rising edge of `clk`.
* `rst` clears `y` to 0 as soon as it rises (without waiting for a clock edge) and holds it at 0 while high.
* Must work for any `N` from 1 to 32.
