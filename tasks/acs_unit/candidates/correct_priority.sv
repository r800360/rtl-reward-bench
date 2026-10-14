// label: correct
// note: an if / else priority chain instead of a case
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
    if (!v0)             sel = v1;
    else if (!v1)        sel = 1'b0;
    else                 sel = c1 < c0;
    pm = valid ? (sel ? c1 : c0) : '0;
  end
endmodule
