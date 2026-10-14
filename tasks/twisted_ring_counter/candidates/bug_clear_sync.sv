// label: bug
// class: asynchronous control made synchronous
// note: clear waits for a clock edge; the weak test holds clear across an edge
module twisted_ring_counter #(parameter int N = 4) (
  input  logic         clk,
  input  logic         clear_n,
  input  logic         load_n,
  input  logic [N-1:0] d,
  output logic [N-1:0] q
);
  always_ff @(posedge clk)
    if (!clear_n)     q <= '0;
    else if (!load_n) q <= d;
    else              q <= {~q[0], q[N-1:1]};
endmodule
