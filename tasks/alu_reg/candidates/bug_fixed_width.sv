// label: bug
// class: not parameterized
// note: the arithmetic is done in 4 bits whatever N is; right at the default N = 4 only
module alu_reg #(parameter int N = 4) (
  input  logic         clk,
  input  logic         rst,
  input  logic [1:0]   op,
  input  logic [N-1:0] a, b,
  output logic [N-1:0] y
);
  logic [3:0] x, z, r;
  assign x = 4'(a);
  assign z = 4'(b);
  always_comb
    case (op)
      2'b00:   r = x + z;
      2'b01:   r = x - z;
      2'b10:   r = x & z;
      default: r = x | z;
    endcase
  always_ff @(posedge clk, posedge rst)
    if (rst) y <= '0;
    else     y <= N'(r);
endmodule
