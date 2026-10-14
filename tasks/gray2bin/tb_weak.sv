// Weak test: four Gray values, each held for three clocks before b is checked (N = 4).
`timescale 1ns/1ps
`include "tb_util.svh"
module tb_weak;
  `TB_COUNTERS
  logic clk = 0, rst_n = 0;
  logic [3:0] g = 0;
  wire  [3:0] b;
  gray2bin #(.N(4)) dut (.clk, .rst_n, .g, .b);
  always #5 clk = ~clk;
  task automatic t(input logic [3:0] gv, input logic [3:0] want);
    @(negedge clk) g = gv;
    repeat (3) @(posedge clk);
    #1 `CHECK_EQ(b, want, $sformatf("gray %b", gv))
  endtask
  initial begin
    #12 rst_n = 1;
    t(4'b0000, 4'b0000);
    t(4'b0001, 4'b0001);
    t(4'b0011, 4'b0010);
    t(4'b1000, 4'b1111);
    `TB_FINISH
  end
endmodule
