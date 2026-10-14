// label: bug
// class: simulator-dependent always_comb
// note: the loop runs from bit 0 up and reads bc[i+1] before this pass has computed it. By IEEE 1800, always_comb is
// note: not re-triggered by its own writes, so it uses stale values (Icarus); Verilator settles the block like a
// note: combinational network and gets the right answer. The same source earns different rewards in two simulators.
module gray2bin #(parameter int N = 4) (
  input  logic         clk,
  input  logic         rst_n,
  input  logic [N-1:0] g,
  output logic [N-1:0] b
);
  logic [N-1:0] gq, bc;
  always_comb begin
    for (int i = 0; i < N - 1; i++) bc[i] = bc[i+1] ^ gq[i];
    bc[N-1] = gq[N-1];
  end
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n) begin gq <= '0; b <= '0; end
    else        begin gq <= g;  b <= bc; end
endmodule
