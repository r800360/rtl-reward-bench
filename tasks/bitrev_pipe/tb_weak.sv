// Weak test: the four combinations of the example, each held for two full clock cycles before dout is checked.
`timescale 1ns/1ps
`include "tb_util.svh"
module tb_weak;
  `TB_COUNTERS
  logic clk = 0, reverse = 0, invert = 0;
  logic [3:0] din = 4'b1110;
  wire  [3:0] dout;
  bitrev_pipe #(.N(4)) dut (.clk, .reverse, .invert, .din, .dout);
  always #5 clk = ~clk;
  task automatic t(input logic r, input logic i, input logic [3:0] want);
    reverse = r; invert = i;
    repeat (2) @(posedge clk);
    #1 `CHECK_EQ(dout, want, $sformatf("reverse %0d invert %0d", r, i))
  endtask
  initial begin
    t(0, 0, 4'b1110); t(1, 0, 4'b0111); t(0, 1, 4'b0001); t(1, 1, 4'b1000);
    `TB_FINISH
  end
endmodule
