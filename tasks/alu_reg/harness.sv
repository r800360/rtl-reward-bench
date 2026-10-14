// Sequential equivalence with the golden design from reset: same inputs, same output on every step (N = 4).
module harness (input logic clk, rst, input logic [1:0] op, input logic [3:0] a, b);
  wire [3:0] yg, yd;
  gold_alu_reg #(.N(4)) g (.clk, .rst, .op, .a, .b, .y(yg));
  alu_reg #(.N(4)) d (.clk, .rst, .op, .a, .b, .y(yd));
  initial assume (rst);
  always_comb assert (yg == yd);
endmodule
