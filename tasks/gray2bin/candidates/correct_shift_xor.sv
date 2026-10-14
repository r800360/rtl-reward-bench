// label: correct
// note: prefix XOR as a sum of shifted copies
module gray2bin #(parameter int N = 4) (
  input  logic         clk,
  input  logic         rst_n,
  input  logic [N-1:0] g,
  output logic [N-1:0] b
);
  logic [N-1:0] gq, bc;
  always_comb begin
    bc = gq;
    for (int k = 1; k < N; k++) bc = bc ^ (gq >> k);
  end
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n) begin gq <= '0; b <= '0; end
    else        begin gq <= g;  b <= bc; end
endmodule
