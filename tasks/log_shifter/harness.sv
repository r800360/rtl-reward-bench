// Combinational equivalence with the golden design, N = 8.
module harness (input logic rotate, left, input logic [2:0] amt, input logic [7:0] din);
  wire [7:0] g, d;
  gold_log_shifter #(.N(8)) gs (.rotate, .left, .amt, .din, .dout(g));
  log_shifter #(.N(8)) ds (.rotate, .left, .amt, .din, .dout(d));
  always_comb assert (g == d);
endmodule
