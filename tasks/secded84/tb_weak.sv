// Weak test: two code words, received clean and with D4 flipped.
`timescale 1ns/1ps
`include "tb_util.svh"
module tb_weak;
  `TB_COUNTERS
  logic [7:0] c;
  wire  [3:0] d;
  wire  corr, dbl;
  secded84 dut (.c, .d, .corrected(corr), .double_err(dbl));
  function automatic logic [7:0] enc(logic [3:0] x);
    logic p4, p2, p1;
    p4 = x[3] ^ x[2] ^ x[1];
    p2 = x[3] ^ x[2] ^ x[0];
    p1 = x[3] ^ x[1] ^ x[0];
    enc = {x, p4, p2, p1, ^{x, p4, p2, p1}};
  endfunction
  initial begin
    for (int k = 0; k < 2; k++) begin
      logic [3:0] x;
      x = k ? 4'b0101 : 4'b1010;
      c = enc(x);                #1 `CHECK_EQ(d, x, "clean word")
      c = enc(x) ^ 8'b1000_0000; #1 `CHECK_EQ(d, x, "D4 flipped is corrected")
      `CHECK_EQ(corr, 1'b1, "flagged corrected")
    end
    `TB_FINISH
  end
endmodule
