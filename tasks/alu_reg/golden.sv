module alu_reg #(parameter int N = 4) (
  input  logic         clk,
  input  logic         rst,
  input  logic [1:0]   op,
  input  logic [N-1:0] a, b,
  output logic [N-1:0] y
);
  logic [N-1:0] r;
  always_comb
    case (op)
      2'b00:   r = a + b;
      2'b01:   r = a - b;
      2'b10:   r = a & b;
      default: r = a | b;
    endcase
  always_ff @(posedge clk, posedge rst)
    if (rst) y <= '0;
    else     y <= r;
endmodule
