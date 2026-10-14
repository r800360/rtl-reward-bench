// Strong test: every Gray value applied on consecutive clocks, each result checked exactly two edges later;
// asynchronous reset between edges.
`timescale 1ns/1ps
`include "tb_util.svh"
module tb_strong;
  parameter int N = 4;
  `TB_COUNTERS
  logic clk = 0, rst_n = 0;
  logic [N-1:0] g = 0, hist [3];
  wire  [N-1:0] b;
  gray2bin #(.N(N)) dut (.clk, .rst_n, .g, .b);
  always #5 clk = ~clk;
  function automatic logic [N-1:0] g2b(logic [N-1:0] x);
    logic [N-1:0] r;
    r[N-1] = x[N-1];
    for (int i = N - 2; i >= 0; i--) r[i] = r[i+1] ^ x[i];
    return r;
  endfunction
  initial begin
    #12 rst_n = 1;
    hist[0] = '0; hist[1] = '0; hist[2] = '0;
    for (int v = 0; v < (1 << N) + 2; v++) begin
      @(negedge clk) g = N'(v);
      hist[2] = hist[1]; hist[1] = hist[0]; hist[0] = g;
      @(posedge clk) #1;
      if (v >= 1) `CHECK_EQ(b, g2b(hist[1]), $sformatf("value applied one clock earlier (%0d)", v - 1))
    end
    @(negedge clk) #1 rst_n = 0;
    #1 `CHECK_EQ(b, '0, "asynchronous reset")
    `TB_FINISH
  end
endmodule
