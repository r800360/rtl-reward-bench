// label: correct
// note: one loop over the output bits in the rising-edge block
module bitrev_pipe #(parameter int N = 4) (
  input  logic         clk,
  input  logic         reverse, invert,
  input  logic [N-1:0] din,
  output logic [N-1:0] dout
);
  logic [N-1:0] q;
  always_ff @(negedge clk) q <= din;
  always_ff @(posedge clk)
    for (int i = 0; i < N; i++) dout[i] <= (reverse ? q[N-1-i] : q[i]) ^ invert;
endmodule
