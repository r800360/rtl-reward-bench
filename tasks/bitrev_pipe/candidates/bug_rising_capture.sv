// label: bug
// class: wrong clock edge
// note: captures din on the rising edge, so dout shows the word present half a cycle too early; the weak test holds
// note: din constant, which hides the timing
module bitrev_pipe #(parameter int N = 4) (
  input  logic         clk,
  input  logic         reverse, invert,
  input  logic [N-1:0] din,
  output logic [N-1:0] dout
);
  logic [N-1:0] q, flipped;
  always_ff @(posedge clk) q <= din;
  always_comb for (int i = 0; i < N; i++) flipped[i] = q[N-1-i];
  always_ff @(posedge clk) dout <= (reverse ? flipped : q) ^ {N{invert}};
endmodule
