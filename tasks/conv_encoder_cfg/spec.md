# conv_encoder_cfg

Write a programmable rate-1/2 convolutional encoder with an N-bit history register.

```systemverilog
module conv_encoder_cfg #(parameter int N = 5) (
  input  logic         clk,
  input  logic         rst_n,     // asynchronous, active low: clears the history only
  input  logic [1:0]   load,      // load[k] = 1: generator k <= g on the clock edge
  input  logic [N-1:0] g,
  input  logic         din,
  output logic [1:0]   dout
);
```

* Three registers: the history `h` and the two generators `g0`, `g1` (no reset; they keep their values through
  `rst_n`).
* `load[0]` and `load[1]` act independently: `load = 11` loads both generators with `g`.
* The history shifts right with `din` entering at the most significant bit, on each rising edge while `load == 00`
  (it holds while any generator is being loaded).
* `dout[k] = ^(gk & h)`, combinational.
* Must work for N from 3 to 9.
