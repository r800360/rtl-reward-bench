// Strong test, against a model written from the specification: generators loaded one at a time and both at once
// (load = 11), the history holding while loading (din keeps changing), 300 random bits per generator pair, and an
// asynchronous reset in mid-stream that clears the history but keeps the generators.
`timescale 1ns/1ps
`include "tb_util.svh"
module tb_strong;
  parameter int N = 5;
  `TB_COUNTERS
  logic clk = 0, rst_n = 0, din = 0;
  logic [1:0] load = 0;
  logic [N-1:0] g = 0, h = 0, m0 = 0, m1 = 0;
  wire  [1:0] dout;
  conv_encoder_cfg #(.N(N)) dut (.clk, .rst_n, .load, .g, .din, .dout);
  always #5 clk = ~clk;
  task automatic edge_step();
    @(posedge clk) #1;
    if (load[0]) m0 = g;
    if (load[1]) m1 = g;
    if (rst_n && load == 2'b00) h = {din, h[N-1:1]};
    `CHECK_EQ(dout, {^(m1 & h), ^(m0 & h)}, "dout after a clock edge")
  endtask
  initial begin
    for (int pass = 0; pass < 3; pass++) begin
      @(negedge clk) begin g = N'($urandom) | N'(1); load = (pass == 2) ? 2'b11 : 2'b01; din = 1'($urandom); end
      edge_step();
      if (pass != 2) begin
        @(negedge clk) begin g = N'($urandom) | N'(1); load = 2'b10; din = 1'($urandom); end
        edge_step();
      end
      @(negedge clk) begin load = 2'b00; rst_n = 1; end
      edge_step();                                      // the first edge after reset shifts din in
      for (int i = 0; i < 300; i++) begin
        @(negedge clk) din = 1'($urandom);
        edge_step();
      end
      // asynchronous reset between edges: history cleared at once, generators kept
      @(negedge clk) #2 rst_n = 0;
      h = '0;
      #1 `CHECK_EQ(dout, 2'b00, "reset clears the history at once")
      @(negedge clk) rst_n = 1;
      edge_step();
      for (int i = 0; i < 20; i++) begin
        @(negedge clk) din = 1'($urandom);
        edge_step();
      end
    end
    `TB_FINISH
  end
endmodule
