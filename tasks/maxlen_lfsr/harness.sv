// Sequential equivalence with the golden design from reset (N = 4).
module harness (input logic clk, rst_n, load, input logic [3:0] seed);
  wire [3:0] qg, qd;
  wire       dg, dd;
  gold_maxlen_lfsr #(.N(4)) g (.clk, .rst_n, .load, .seed, .q(qg), .done(dg));
  maxlen_lfsr #(.N(4)) d (.clk, .rst_n, .load, .seed, .q(qd), .done(dd));
  logic past = 1'b0;
  always_ff @(posedge clk) past <= 1'b1;
  initial assume (!rst_n);
  always_comb if (past) assert (qg == qd && dg == dd);
endmodule
