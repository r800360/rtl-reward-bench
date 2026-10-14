// label: bug
// class: missing qualification
// note: compares the costs whatever the validity bits say, so an unreachable predecessor can win; the weak test keeps
// note: both predecessors valid
module acs_unit #(parameter int W = 8) (
  input  logic         v0, v1,
  input  logic [1:0]   bm0, bm1,
  input  logic [W-1:0] pm0, pm1,
  output logic         sel,
  output logic         valid,
  output logic [W-1:0] pm
);
  logic [W-1:0] c0, c1;
  assign c0 = pm0 + W'(bm0);
  assign c1 = pm1 + W'(bm1);
  always_comb begin
    valid = v0 | v1;
    sel = valid ? (c0 > c1) : 1'b0;
    pm = sel ? c1 : c0;
  end
endmodule
