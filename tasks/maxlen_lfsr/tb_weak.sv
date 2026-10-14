// Weak test in the style of a checker bench: N = 4, seed 1111. Load, then wait for done; it passes if done is seen
// within 2^N + 2 clocks and q equals the seed at that moment.
`timescale 1ns/1ps
`include "tb_util.svh"
module tb_weak;
  `TB_COUNTERS
  logic clk = 0, rst_n = 0, load = 0;
  logic [3:0] seed = 4'hF;
  wire  [3:0] q;
  wire        done;
  int seen = 0;
  maxlen_lfsr #(.N(4)) dut (.clk, .rst_n, .load, .seed, .q, .done);
  always #5 clk = ~clk;
  initial begin
    @(negedge clk) rst_n = 1;
    @(negedge clk) load = 1;
    @(negedge clk) load = 0;
    repeat (18) begin
      @(posedge clk) #1;
      if (done && !seen) begin seen = 1; `CHECK_EQ(q, seed, "q equals the seed when done") end
    end
    `CHECK_EQ(seen, 1, "done seen")
    `TB_FINISH
  end
endmodule
