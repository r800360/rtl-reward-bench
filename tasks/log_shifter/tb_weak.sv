// Weak test: four directed examples (N = 4): shift right 1000 by 1, rotate right 1011 by 1, shift left 0001 by 2,
// rotate left 1011 by 1.
`timescale 1ns/1ps
`include "tb_util.svh"
module tb_weak;
  `TB_COUNTERS
  logic rotate, left;
  logic [1:0] amt;
  logic [3:0] din;
  wire  [3:0] dout;
  log_shifter #(.N(4)) dut (.rotate, .left, .amt, .din, .dout);
  initial begin
    rotate = 0; left = 0; amt = 1; din = 4'b1000; #1 `CHECK_EQ(dout, 4'b0100, "shift right 1")
    rotate = 1; left = 0; amt = 1; din = 4'b1011; #1 `CHECK_EQ(dout, 4'b1101, "rotate right 1")
    rotate = 0; left = 1; amt = 2; din = 4'b0001; #1 `CHECK_EQ(dout, 4'b0100, "shift left 2")
    rotate = 1; left = 1; amt = 1; din = 4'b1011; #1 `CHECK_EQ(dout, 4'b0111, "rotate left 1")
    `TB_FINISH
  end
endmodule
