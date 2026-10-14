// Strong test: every a, b and direction against integer arithmetic (N <= 6), random vectors otherwise.
`timescale 1ns/1ps
`include "tb_util.svh"
module tb_strong;
  parameter int N = 4;
  `TB_COUNTERS
  logic amb;
  logic signed [N-1:0] a, b;
  wire  signed [N-1:0] d;
  wire  po, no;
  subtractor #(.N(N)) dut (.sub_ab(amb), .a, .b, .d, .ovf_pos(po), .ovf_neg(no));
  task automatic t(input logic m, input logic signed [N-1:0] x, input logic signed [N-1:0] y);
    longint dif, lo, hi;
    amb = m; a = x; b = y;
    dif = m ? longint'(x) - longint'(y) : longint'(y) - longint'(x);
    hi = (longint'(1) <<< (N - 1)) - 1;
    lo = -(longint'(1) <<< (N - 1));
    #1 `CHECK_EQ(d, N'(dif), $sformatf("m=%0d a=%0d b=%0d", m, x, y))
    `CHECK_EQ(po, dif > hi, $sformatf("ovf_pos m=%0d a=%0d b=%0d", m, x, y))
    `CHECK_EQ(no, dif < lo, $sformatf("ovf_neg m=%0d a=%0d b=%0d", m, x, y))
  endtask
  initial begin
    if (N <= 6) begin
      for (int m = 0; m < 2; m++)
        for (int x = 0; x < (1 << N); x++)
          for (int y = 0; y < (1 << N); y++) t(m[0], N'(x), N'(y));
    end else
      for (int i = 0; i < 20000; i++) t(1'($urandom), N'($urandom), N'($urandom));
    `TB_FINISH
  end
endmodule
