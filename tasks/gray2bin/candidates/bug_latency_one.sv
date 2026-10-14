// label: bug
// class: timing (pipeline depth)
// note: the input register is missing, so b follows one edge early; the weak test waits three clocks per value
module gray2bin #(parameter int N = 4) (
  input  logic         clk,
  input  logic         rst_n,
  input  logic [N-1:0] g,
  output logic [N-1:0] b
);
  logic [N-1:0] bc;
  always_comb begin
    bc[N-1] = g[N-1];
    for (int i = N - 2; i >= 0; i--) bc[i] = bc[i+1] ^ g[i];
  end
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n) b <= '0;
    else        b <= bc;
endmodule
