// Weak test in the style of a lab bench: N = 5, generators loaded one at a time (11001 then 10111), then 20 input
// bits, each output compared with a model that shifts on every edge.
`timescale 1ns/1ps
`include "tb_util.svh"
module tb_weak;
  `TB_COUNTERS
  logic clk = 0, rst_n = 0, din = 0;
  logic [1:0] load = 0;
  logic [4:0] g = 0, h = 0;
  wire  [1:0] dout;
  conv_encoder_cfg #(.N(5)) dut (.clk, .rst_n, .load, .g, .din, .dout);
  always #5 clk = ~clk;
  initial begin
    @(negedge clk) begin g = 5'b11001; load = 2'b01; end
    @(negedge clk) begin g = 5'b10111; load = 2'b10; end
    @(negedge clk) begin load = 2'b00; rst_n = 1; end
    for (int i = 0; i < 20; i++) begin
      @(negedge clk) din = 1'($urandom);
      @(posedge clk) #1;
      h = {din, h[4:1]};
      `CHECK_EQ(dout, {^(5'b10111 & h), ^(5'b11001 & h)}, $sformatf("bit %0d", i))
    end
    `TB_FINISH
  end
endmodule
