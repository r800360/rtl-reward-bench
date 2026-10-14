// Formal equivalence with the golden design (renamed gold_onehot_decoder): same inputs, same outputs, always.
module harness #(parameter int N = 3) (input logic en, input logic [N-1:0] sel);
  wire [(1<<N)-1:0] yg, yd;
  gold_onehot_decoder #(.N(N)) g (.en(en), .sel(sel), .y(yg));
  onehot_decoder #(.N(N)) d (.en(en), .sel(sel), .y(yd));
  always_comb assert (yg == yd);
endmodule
