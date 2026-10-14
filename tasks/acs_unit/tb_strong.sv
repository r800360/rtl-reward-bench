// Strong test: every validity combination and branch-metric pair, path metrics random and equal (ties).
`timescale 1ns/1ps
`include "tb_util.svh"
module tb_strong;
  `TB_COUNTERS
  logic v0, v1;
  logic [1:0] bm0, bm1;
  logic [7:0] pm0, pm1;
  wire  sel, valid;
  wire  [7:0] pm;
  acs_unit #(.W(8)) dut (.v0, .v1, .bm0, .bm1, .pm0, .pm1, .sel, .valid, .pm);
  initial begin
    for (int i = 0; i < 4000; i++) begin
      logic [7:0] c0, c1;
      logic s;
      {v0, v1} = 2'(i);
      bm0 = 2'($urandom); bm1 = 2'($urandom);
      pm0 = 8'($urandom % 64);
      pm1 = (i % 3 == 0) ? pm0 + 8'(bm0) - 8'(bm1) : 8'($urandom % 64);   // every third vector: a tie
      c0 = pm0 + 8'(bm0);
      c1 = pm1 + 8'(bm1);
      s = (v0 && v1) ? (c0 > c1) : (!v0 && v1);
      #1;
      `CHECK_EQ(sel, s, $sformatf("sel v=%b c0=%0d c1=%0d", {v0, v1}, c0, c1))
      `CHECK_EQ(valid, v0 | v1, "valid")
      `CHECK_EQ(pm, (v0 | v1) ? (s ? c1 : c0) : 8'd0, $sformatf("pm v=%b c0=%0d c1=%0d", {v0, v1}, c0, c1))
    end
    `TB_FINISH
  end
endmodule
