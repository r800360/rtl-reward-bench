# secded84

Write the decoder of the (8,4) extended Hamming code: single-error correction, double-error detection.

```systemverilog
module secded84 (
  input  logic [7:0] c,          // received {D4, D3, D2, D1, P4, P2, P1, P0}
  output logic [3:0] d,          // corrected data {D4, D3, D2, D1}
  output logic       corrected,  // exactly one bit was wrong (and is fixed), including P0 alone
  output logic       double_err  // two bits were wrong: detected, d is the uncorrected data
);
```

Encoding: P4 = D4^D3^D2, P2 = D4^D3^D1, P1 = D4^D2^D1, P0 = XOR of the seven other bits.
