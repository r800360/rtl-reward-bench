// Strong test (zero-delay simulation): 0 during reset; then every high and every low phase lasts exactly 30 ns
// (1.5 periods of the 20 ns clock) over 40 output periods; clk_out changes only on clk edges.
`timescale 1ns/1ps
`include "tb_util.svh"
module tb_strong;
  `TB_COUNTERS
  logic clk = 0, rst = 1;
  wire  clk_out;
  realtime last = 0;
  int phases = 0;
  bit started = 0;
  clkdiv3 dut (.clk, .rst, .clk_out);
  always #10 clk = ~clk;
  always @(clk_out) if (!rst) begin
    if (started) begin
      `CHECK_EQ(int'($realtime - last), 30, "phase length (ns)")
      phases++;
    end
    started = 1;
    last = $realtime;
    `CHECK(int'($realtime) % 10 == 0, "clk_out changes on a clk edge")
  end
  initial begin
    repeat (2) @(posedge clk);                        // both edges have seen the reset by now
    repeat (3) @(posedge clk) #1 `CHECK_EQ(clk_out, 1'b0, "0 during reset");
    @(negedge clk) rst = 0;
    repeat (120) @(posedge clk);
    `CHECK(phases >= 75, $sformatf("enough output phases (%0d)", phases))
    `TB_FINISH
  end
endmodule
