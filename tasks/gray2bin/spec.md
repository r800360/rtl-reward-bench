# gray2bin

Write an N-bit Gray-to-binary converter with registered input and output.

```systemverilog
module gray2bin #(parameter int N = 4) (
  input  logic         clk,
  input  logic         rst_n,   // asynchronous, active low: both registers to 0
  input  logic [N-1:0] g,
  output logic [N-1:0] b
);
```

* `b[N-1] = g[N-1]` and `b[i] = b[i+1] ^ g[i]`, so `b[i]` is the XOR of `g[N-1:i]`.
* The input is registered, the conversion is combinational, and the result is registered: a value applied before one
  rising edge appears on `b` right after the following rising edge (latency 2 edges).
