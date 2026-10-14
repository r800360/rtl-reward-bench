# twisted_ring_counter

Write an N-bit Johnson (twisted-ring) counter.

```systemverilog
module twisted_ring_counter #(parameter int N = 4) (
  input  logic         clk,
  input  logic         clear_n,   // asynchronous, active low
  input  logic         load_n,    // synchronous, active low
  input  logic [N-1:0] d,
  output logic [N-1:0] q
);
```

* `clear_n` low: `q` becomes 0 at once and stays 0 while low; it has priority over everything else.
* Otherwise, on each rising edge of `clk`: if `load_n` is low, `q <= d`; else the register shifts **right** by one and
  the complement of the bit shifted out (`q[0]`) enters at the most significant bit.
* From 0 the counter therefore visits 0000 → 1000 → 1100 → 1110 → 1111 → 0111 → 0011 → 0001 → 0000 (N = 4).
* Must work for any `N` from 2 to 16.
