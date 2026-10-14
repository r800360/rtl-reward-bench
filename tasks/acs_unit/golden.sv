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
    case ({v0, v1})
      2'b00:   sel = 1'b0;
      2'b01:   sel = 1'b1;
      2'b10:   sel = 1'b0;
      default: sel = c0 > c1;
    endcase
    valid = v0 | v1;
    pm = !valid ? '0 : (sel ? c1 : c0);
  end
endmodule
