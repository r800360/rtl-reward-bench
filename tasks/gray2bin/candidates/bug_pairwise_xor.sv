// label: bug
// class: wrong formula
// note: b[i] = g[i+1] ^ g[i] (one XOR, not the prefix XOR); right for the weak test's values 0000, 0001, 0011
module gray2bin #(parameter int N = 4) (
  input  logic         clk,
  input  logic         rst_n,
  input  logic [N-1:0] g,
  output logic [N-1:0] b
);
  logic [N-1:0] gq;
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n) begin gq <= '0; b <= '0; end
    else        begin gq <= g;  b <= gq ^ (gq >> 1); end
endmodule
