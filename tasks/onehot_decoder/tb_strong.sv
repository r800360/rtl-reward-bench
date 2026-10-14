// Strong test: every en/sel combination against the specification, for the parameter N.
`timescale 1ns/1ps
`include "tb_util.svh"
module tb_strong;
  parameter int N = 2;
  `TB_COUNTERS
  logic en;
  logic [N-1:0] sel;
  wire  [(1<<N)-1:0] y;
  logic [(1<<N)-1:0] want;
  onehot_decoder #(.N(N)) dut (.en(en), .sel(sel), .y(y));
  initial begin
    for (int pass = 0; pass < 2; pass++)            // twice, so a latch keeping an old value is exposed
      for (int e = 1; e >= 0; e--)
        for (int s = 0; s < (1 << N); s++) begin
          en = e[0]; sel = N'(s);
          want = '0;
          if (e) want[s] = 1'b1;
          #1 `CHECK_EQ(y, want, $sformatf("en=%0d sel=%0d", e, s))
        end
    `TB_FINISH
  end
endmodule
