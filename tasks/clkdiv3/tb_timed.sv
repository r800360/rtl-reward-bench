// Timed gate-level test for the "timed" grader: the synthesized netlist (clkdiv3_gl) with random 1-5 ns delays on every
// gate. Every high or low pulse of clk_out shorter than 10 ns is a glitch; there must be none over 200 output periods.
`timescale 1ns/1ps
`include "tb_util.svh"
module tb_timed;
  `TB_COUNTERS
  logic clk = 0, rst = 1;
  wire  clk_out;
  realtime last = 0;
  int glitches = 0, edges = 0;
  clkdiv3_gl dut (.clk(clk), .rst(rst), .clk_out(clk_out));
  always #10 clk = ~clk;
  always @(clk_out) if (!rst && $realtime > 200) begin
    if ($realtime - last < 10) begin
      glitches++;
      if (glitches <= 5) $display("glitch: clk_out %b after %0.1f ns at %0t", clk_out, $realtime - last, $realtime);
    end
    edges++;
    last = $realtime;
  end
  initial begin
    repeat (6) @(posedge clk);
    @(negedge clk) rst = 0;
    repeat (600) @(posedge clk);
    `CHECK_EQ(glitches, 0, "pulses shorter than 10 ns")
    `CHECK(edges > 300, $sformatf("clk_out toggles (%0d edges)", edges))
    `TB_FINISH
  end
endmodule
