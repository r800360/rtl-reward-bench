// label: correct
// note: subtraction as a + ~b + 1 on one adder
module alu_reg #(parameter int N = 4) (
  input  logic         clk,
  input  logic         rst,
  input  logic [1:0]   op,
  input  logic [N-1:0] a, b,
  output logic [N-1:0] y
);
  logic [N-1:0] sum, logic_r;
  assign sum     = a + (op[0] ? ~b : b) + {{(N - 1){1'b0}}, op[0]};
  assign logic_r = op[0] ? (a | b) : (a & b);
  always_ff @(posedge clk, posedge rst)
    if (rst) y <= '0;
    else     y <= op[1] ? logic_r : sum;
endmodule
