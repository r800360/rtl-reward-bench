// label: bug
// class: wrong direction
// note: shifts left (0000 -> 0001 -> 0011 ...), a Johnson counter but not the one specified; same period, so the
// note: weak test's period check passes (a mistake seen in a graded submission)
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
    else              q <= {q[N-2:0], ~q[N-1]};
endmodule
