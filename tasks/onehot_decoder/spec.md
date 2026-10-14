# onehot_decoder

Write a combinational N-to-2^N decoder with an enable.

```systemverilog
module onehot_decoder #(parameter int N = 2) (
  input  logic               en,
  input  logic [N-1:0]       sel,
  output logic [(1<<N)-1:0]  y
);
```

* When `en` is 1, exactly bit `sel` of `y` is 1 and all other bits are 0.
* When `en` is 0, `y` is all zeros.
* Purely combinational: no latches, no clock.
* Must work for any `N` from 1 to 6.
