// Weak test: after a clear, the counter must come back to 0 after exactly 2N clocks and visit 2N different states
// on the way (N = 4). It checks the period, not the order of the states.
`timescale 1ns/1ps
`include "tb_util.svh"
module tb_weak;
  `TB_COUNTERS
  logic clk = 0, clear_n = 0, load_n = 1;
  logic [3:0] d = 0;
  wire  [3:0] q;
  bit seen [16];
  int distinct = 0;
  twisted_ring_counter #(.N(4)) dut (.clk, .clear_n, .load_n, .d, .q);
  always #5 clk = ~clk;
  initial begin
    #12 clear_n = 1;
    for (int i = 0; i < 8; i++) begin
      if (!seen[q]) begin seen[q] = 1; distinct++; end
      @(posedge clk) #1;
    end
    `CHECK_EQ(q, 4'd0, "back to 0 after 2N clocks")
    `CHECK_EQ(distinct, 8, "2N distinct states")
    `TB_FINISH
  end
endmodule
