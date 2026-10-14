# maxlen_lfsr

Write a maximal-length Fibonacci LFSR for N = 2 … 8.

```systemverilog
module maxlen_lfsr #(parameter int N = 4) (
  input  logic         clk,
  input  logic         rst_n,    // synchronous, active low
  input  logic         load,     // synchronous, active high
  input  logic [N-1:0] seed,
  output logic [N-1:0] q,
  output logic         done
);
```

* `rst_n` low: `q <= 0` on the clock edge. `load` high: `q <= seed`.
* Otherwise shift left and put the XOR of the tap bits into bit 0. Taps (polynomial): N=2 x²+x+1, N=3 x³+x²+1,
  N=4 x⁴+x³+1, N=5 x⁵+x³+1, N=6 x⁶+x⁵+1, N=7 x⁷+x⁶+1, N=8 x⁸+x⁶+x⁵+x⁴+1 (term xᵏ is bit k−1).
* `done` is high for exactly one clock cycle each time `q` returns to the loaded seed, that is after 2^N − 1 shifts.
  It is low while loading and right after a load (although `q` equals the seed then), and never high for a zero seed.
