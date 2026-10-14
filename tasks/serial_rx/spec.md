# serial_rx

Write a UART receiver: 8 data bits, LSB first, no parity, one stop bit; the line idles high.

```systemverilog
module serial_rx #(parameter int CLKS_PER_BIT = 16) (
  input  logic       clk,
  input  logic       rst_n,      // synchronous, active low
  input  logic       rx,         // asynchronous to clk
  output logic       valid,      // one cycle per correctly received byte
  output logic [7:0] data,       // the last byte received; holds until the next one
  output logic       frame_err   // one cycle when the stop bit is low (no valid, data unchanged)
);
```

* Sample each bit near its middle, so that a transmitter up to ±3 % off the nominal rate is still received.
* A low pulse on the idle line shorter than half a bit is not a start bit.
* `rx` comes from another clock domain: synchronize it before use.
