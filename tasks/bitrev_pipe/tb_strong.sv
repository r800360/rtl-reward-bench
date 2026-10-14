// Strong test: a new random word every cycle, applied before the falling edge and changed right after it, so the
// output at the next rising edge must reflect exactly the word sampled on that falling edge.
`timescale 1ns/1ps
`include "tb_util.svh"
module tb_strong;
  parameter int N = 4;
  `TB_COUNTERS
  logic clk = 0, reverse = 0, invert = 0;
  logic [N-1:0] din = 0, sampled, want;
  wire  [N-1:0] dout;
  bitrev_pipe #(.N(N)) dut (.clk, .reverse, .invert, .din, .dout);
  always #5 clk = ~clk;
  initial begin
    for (int k = 0; k < 400; k++) begin
      @(posedge clk) #1 begin din = N'($urandom); reverse = 1'($urandom); invert = 1'($urandom); end
      @(negedge clk) sampled = din;
      #1 din = ~din;                                   // change right after the falling edge
      @(posedge clk) #1;
      for (int i = 0; i < N; i++) want[i] = reverse ? sampled[N-1-i] : sampled[i];
      want = want ^ {N{invert}};
      `CHECK_EQ(dout, want, $sformatf("word %0d", k))
    end
    `TB_FINISH
  end
endmodule
