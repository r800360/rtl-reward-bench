// Weak test: five small differences in both directions, no overflow (N = 4).
`timescale 1ns/1ps
`include "tb_util.svh"
module tb_weak;
  `TB_COUNTERS
  logic amb;
  logic signed [3:0] a, b;
  wire  signed [3:0] d;
  wire  po, no;
  subtractor #(.N(4)) dut (.sub_ab(amb), .a, .b, .d, .ovf_pos(po), .ovf_neg(no));
  task automatic t(input logic m, input int x, input int y, input int want);
    amb = m; a = 4'(x); b = 4'(y);
    #1 `CHECK_EQ(d, 4'(want), $sformatf("%0d, %0d", x, y))
    `CHECK_EQ({po, no}, 2'b00, "no overflow")
  endtask
  initial begin
    t(1, 5, 3, 2); t(1, 3, 5, -2); t(0, 5, 3, -2); t(1, -2, -3, 1); t(0, 0, 4, 4);
    `TB_FINISH
  end
endmodule
