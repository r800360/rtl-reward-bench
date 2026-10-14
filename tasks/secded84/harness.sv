// Combinational equivalence with the golden decoder for every received word.
module harness (input logic [7:0] c);
  wire [3:0] dg, dd;
  wire cg, bg, cd, bd;
  gold_secded84 g (.c, .d(dg), .corrected(cg), .double_err(bg));
  secded84 u (.c, .d(dd), .corrected(cd), .double_err(bd));
  always_comb assert (dg == dd && cg == cd && bg == bd);
endmodule
