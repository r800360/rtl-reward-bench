// Combinational equivalence with the golden design, N = 8.
module harness (input logic m, input logic signed [7:0] a, b);
  wire signed [7:0] dg, dd;
  wire pg, ng, pd, nd;
  gold_subtractor #(.N(8)) g (.sub_ab(m), .a, .b, .d(dg), .ovf_pos(pg), .ovf_neg(ng));
  subtractor #(.N(8)) u (.sub_ab(m), .a, .b, .d(dd), .ovf_pos(pd), .ovf_neg(nd));
  always_comb assert (dg == dd && pg == pd && ng == nd);
endmodule
