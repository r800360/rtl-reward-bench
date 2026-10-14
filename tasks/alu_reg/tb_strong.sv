// Strong test: every operand pair and operation for N <= 4 (3000 random vectors otherwise), result checked after
// each rising edge; reset asserted between clock edges must clear y at once and hold it.
`timescale 1ns/1ps
`include "tb_util.svh"
module tb_strong;
  parameter int N = 4;
  `TB_COUNTERS
  logic clk = 0, rst = 1;
  logic [1:0] op = 0;
  logic [N-1:0] a = 0, b = 0;
  wire  [N-1:0] y;
  alu_reg #(.N(N)) dut (.clk, .rst, .op, .a, .b, .y);
  always #5 clk = ~clk;

  function automatic logic [N-1:0] model(logic [1:0] o, logic [N-1:0] x, logic [N-1:0] z);
    case (o)
      2'b00:   return x + z;
      2'b01:   return x - z;
      2'b10:   return x & z;
      default: return x | z;
    endcase
  endfunction

  task automatic t(input logic [1:0] o, input logic [N-1:0] x, input logic [N-1:0] z);
    @(negedge clk) begin op = o; a = x; b = z; end
    @(posedge clk) #1 `CHECK_EQ(y, model(o, x, z), $sformatf("op %0d a %0d b %0d", o, x, z))
  endtask

  initial begin
    repeat (2) @(posedge clk);
    @(negedge clk) rst = 0;
    if (N <= 4) begin
      for (int o = 0; o < 4; o++)
        for (int x = 0; x < (1 << N); x++)
          for (int z = 0; z < (1 << N); z++) t(2'(o), N'(x), N'(z));
    end else
      for (int i = 0; i < 3000; i++) t(2'($urandom), N'($urandom), N'($urandom));
    // asynchronous reset in the middle of a clock period
    t(2'b11, '1, '1);
    @(negedge clk) #2 rst = 1;
    #1 `CHECK_EQ(y, '0, "reset clears y before the next clock edge")
    @(posedge clk) #1 `CHECK_EQ(y, '0, "reset holds y at 0")
    @(negedge clk) rst = 0;
    t(2'b00, N'(1), N'(1));
    `TB_FINISH
  end
endmodule
