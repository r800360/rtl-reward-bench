// Weak test: after reset, count rising edges of clk_out over 30 clk periods; expect 10.
`timescale 1ns/1ps
`include "tb_util.svh"
module tb_weak;
  `TB_COUNTERS
  logic clk = 0, rst = 1;
  wire  clk_out;
  int edges = 0;
  clkdiv3 dut (.clk, .rst, .clk_out);
  always #10 clk = ~clk;
  always @(posedge clk_out) if (!rst) edges++;
  initial begin
    repeat (4) @(posedge clk);
    @(negedge clk) rst = 0;
    edges = 0;
    repeat (30) @(posedge clk);
    `CHECK(edges >= 9 && edges <= 11, $sformatf("about 10 output periods (%0d)", edges))
    `TB_FINISH
  end
endmodule
