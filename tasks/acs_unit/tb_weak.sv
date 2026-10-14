// Weak test: both predecessors valid, distinct costs.
`timescale 1ns/1ps
`include "tb_util.svh"
module tb_weak;
  `TB_COUNTERS
  logic v0 = 1, v1 = 1;
  logic [1:0] bm0, bm1;
  logic [7:0] pm0, pm1;
  wire  sel, valid;
  wire  [7:0] pm;
  acs_unit #(.W(8)) dut (.v0, .v1, .bm0, .bm1, .pm0, .pm1, .sel, .valid, .pm);
  initial begin
    bm0 = 0; bm1 = 2; pm0 = 10; pm1 = 5; #1 `CHECK_EQ({sel, pm}, {1'b1, 8'd7}, "path 1 cheaper")
    bm0 = 1; bm1 = 0; pm0 = 3;  pm1 = 9; #1 `CHECK_EQ({sel, pm}, {1'b0, 8'd4}, "path 0 cheaper")
    `CHECK_EQ(valid, 1'b1, "valid")
    `TB_FINISH
  end
endmodule
