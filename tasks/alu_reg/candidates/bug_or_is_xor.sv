// label: bug
// class: wrong operator
// note: op 11 computes a ^ b; the weak test only ORs 1 with 0, where XOR gives the same
module alu_reg #(parameter int N = 4) (
  input  logic         clk,
  input  logic         rst,
  input  logic [1:0]   op,
  input  logic [N-1:0] a, b,
  output logic [N-1:0] y
);
  always_ff @(posedge clk, posedge rst)
    if (rst) y <= '0;
    else
      case (op)
        2'b00:   y <= a + b;
        2'b01:   y <= a - b;
        2'b10:   y <= a & b;
        default: y <= a ^ b;
      endcase
endmodule
