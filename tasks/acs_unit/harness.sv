// Combinational equivalence with the golden ACS for every input (W = 8).
module harness (input logic v0, v1, input logic [1:0] bm0, bm1, input logic [7:0] pm0, pm1);
  wire sg, vg, sd, vd;
  wire [7:0] pg, pd;
  gold_acs_unit #(.W(8)) g (.v0, .v1, .bm0, .bm1, .pm0, .pm1, .sel(sg), .valid(vg), .pm(pg));
  acs_unit #(.W(8)) u (.v0, .v1, .bm0, .bm1, .pm0, .pm1, .sel(sd), .valid(vd), .pm(pd));
  always_comb assert (sg == sd && vg == vd && pg == pd);
endmodule
