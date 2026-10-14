// Strong test: all 16 data words with every error pattern of weight 0, 1 and 2.
`timescale 1ns/1ps
`include "tb_util.svh"
module tb_strong;
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
    for (int x = 0; x < 16; x++) begin
      c = enc(4'(x)); #1;
      `CHECK_EQ({d, corr, dbl}, {4'(x), 2'b00}, $sformatf("data %0h clean", x))
      for (int i = 0; i < 8; i++) begin
        c = enc(4'(x)) ^ (8'd1 << i); #1;
        `CHECK_EQ({d, corr, dbl}, {4'(x), 2'b10}, $sformatf("data %0h, bit %0d wrong", x, i))
        for (int j = i + 1; j < 8; j++) begin
          c = enc(4'(x)) ^ (8'd1 << i) ^ (8'd1 << j); #1;
          `CHECK_EQ({corr, dbl}, 2'b01, $sformatf("data %0h, bits %0d and %0d wrong", x, i, j))
        end
      end
    end
    `TB_FINISH
  end
endmodule
