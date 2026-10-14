// Weak test: 20 random vectors at N = 4.
`timescale 1ns/1ps
`include "tb_util.svh"
module tb_weak;
  `TB_COUNTERS
  logic [3:0] a, b;
  logic cin;
  wire  [4:0] sum;
  adder_cla #(.N(4)) dut (.a, .b, .cin, .sum);
  initial begin
    for (int i = 0; i < 20; i++) begin
      {a, b, cin} = 9'($urandom);
      #1 `CHECK_EQ(sum, 5'(a) + 5'(b) + 5'(cin), "sum")
    end
    `TB_FINISH
  end
endmodule
