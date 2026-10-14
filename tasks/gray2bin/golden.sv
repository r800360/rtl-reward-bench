module gray2bin #(parameter int N = 4) (
  input  logic         clk,
  input  logic         rst_n,
  input  logic [N-1:0] g,
  output logic [N-1:0] b
);
  logic [N-1:0] gq, bc;
  always_comb begin
    bc[N-1] = gq[N-1];
    for (int i = N - 2; i >= 0; i--) bc[i] = bc[i+1] ^ gq[i];
  end
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n) begin gq <= '0; b <= '0; end
    else        begin gq <= g;  b <= bc; end
endmodule
