// Combinational equivalence with the golden design, N = 16 (2^33 input combinations).
module harness (input logic [15:0] a, b, input logic cin);
  wire [16:0] sg, sd;
  gold_adder_cla #(.N(16)) g (.a, .b, .cin, .sum(sg));
  adder_cla #(.N(16)) d (.a, .b, .cin, .sum(sd));
  always_comb assert (sg == sd);
endmodule
