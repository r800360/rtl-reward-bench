// label: bug
// class: synchronous control made asynchronous
// note: load acts as soon as load_n falls instead of at the clock edge; the weak test never loads
module twisted_ring_counter #(parameter int N = 4) (
  input  logic         clk,
  input  logic         clear_n,
  input  logic         load_n,
  input  logic [N-1:0] d,
  output logic [N-1:0] q
);
  always_ff @(posedge clk, negedge clear_n, negedge load_n)
    if (!clear_n)     q <= '0;
    else if (!load_n) q <= d;
    else              q <= {~q[0], q[N-1:1]};
endmodule
