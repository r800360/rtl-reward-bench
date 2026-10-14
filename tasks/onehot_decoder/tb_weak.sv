// Weak test, in the style of a hand-written lab bench: enable held high, a few select values, and it only checks
// that one bit is set (and that sel = 0 selects bit 0).
`timescale 1ns/1ps
`include "tb_util.svh"
module tb_weak;
  `TB_COUNTERS
  logic en = 1;
  logic [1:0] sel;
  wire  [3:0] y;
  onehot_decoder #(.N(2)) dut (.en(en), .sel(sel), .y(y));
  initial begin
    sel = 0; #1 `CHECK_EQ(y[0], 1'b1, "sel 0 selects bit 0")
    for (int s = 1; s < 4; s++) begin
      sel = 2'(s); #1 `CHECK($onehot(y), $sformatf("sel %0d: one bit set", s))
    end
    `TB_FINISH
  end
endmodule
