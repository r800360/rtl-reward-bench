// label: correct
// note: the twist written with a shift operator
module twisted_ring_counter #(parameter int N = 4) (
  input  logic         clk,
  input  logic         clear_n,
  input  logic         load_n,
  input  logic [N-1:0] d,
  output logic [N-1:0] q
);
  always_ff @(posedge clk, negedge clear_n)
    if (!clear_n)     q <= '0;
    else if (!load_n) q <= d;
    else              q <= (q >> 1) | ({{(N - 1){1'b0}}, ~q[0]} << (N - 1));
endmodule
