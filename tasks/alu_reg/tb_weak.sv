// Weak test, in the style of a hand-written lab bench: reset held across a clock edge, then one vector per operation
// (5 + 3, 6 - 6, 12 & 10, 1 | 0), each checked after the next rising edge. N = 4.
`timescale 1ns/1ps
`include "tb_util.svh"
module tb_weak;
  `TB_COUNTERS
  logic clk = 0, rst = 1;
  logic [1:0] op = 0;
  logic [3:0] a = 0, b = 0;
  wire  [3:0] y;
  alu_reg #(.N(4)) dut (.clk, .rst, .op, .a, .b, .y);
  always #5 clk = ~clk;
  task automatic t(input logic [1:0] o, input logic [3:0] x, input logic [3:0] z, input logic [3:0] want);
    @(negedge clk) begin op = o; a = x; b = z; end
    @(posedge clk) #1 `CHECK_EQ(y, want, $sformatf("op %0d", o))
  endtask
  initial begin
    repeat (2) @(posedge clk);
    #1 `CHECK_EQ(y, 4'd0, "reset")
    @(negedge clk) rst = 0;
    t(2'b00, 4'd5, 4'd3, 4'd8);
    t(2'b01, 4'd6, 4'd6, 4'd0);
    t(2'b10, 4'd12, 4'd10, 4'd8);
    t(2'b11, 4'd1, 4'd0, 4'd1);
    `TB_FINISH
  end
endmodule
