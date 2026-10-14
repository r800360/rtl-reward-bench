# clkdiv3

Write a divide-by-3 clock generator with a 50 % duty cycle.

```systemverilog
module clkdiv3 (
  input  logic clk,
  input  logic rst,       // synchronous, active high
  output logic clk_out
);
```

* While `rst` is high, `clk_out` is 0.
* After reset, `clk_out` has a period of exactly 3 `clk` periods and is high for 1.5 of them (50 % duty cycle).
* `clk_out` will be used as a clock, so it must be **glitch-free**: it may only be driven by flip-flops, or by logic
  in which no more than one input can change at any clock edge.
