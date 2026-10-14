// Sequential equivalence with the golden design from a cleared state (N = 4).
module harness (input logic clk, clear_n, load_n, input logic [3:0] d);
  wire [3:0] qg, qd;
  gold_twisted_ring_counter #(.N(4)) g (.clk, .clear_n, .load_n, .d, .q(qg));
  twisted_ring_counter #(.N(4)) dd (.clk, .clear_n, .load_n, .d, .q(qd));
  initial assume (!clear_n);
  always_comb assert (qg == qd);
endmodule
