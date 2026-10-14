// Sequential equivalence with the golden design from reset (N = 5).
module harness (input logic clk, rst_n, input logic [4:0] g);
  wire [4:0] bg, bd;
  gold_gray2bin #(.N(5)) gg (.clk, .rst_n, .g, .b(bg));
  gray2bin #(.N(5)) dd (.clk, .rst_n, .g, .b(bd));
  initial assume (!rst_n);
  always_comb assert (bg == bd);
endmodule
