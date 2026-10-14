// label: bug
// class: control logic
// note: applies the inversion only together with the reversal; caught even by the weak test
module bitrev_pipe #(parameter int N = 4) (
  input  logic         clk,
  input  logic         reverse, invert,
  input  logic [N-1:0] din,
  output logic [N-1:0] dout
);
  logic [N-1:0] q, flipped;
  always_ff @(negedge clk) q <= din;
  always_comb for (int i = 0; i < N; i++) flipped[i] = q[N-1-i];
  always_ff @(posedge clk) dout <= reverse ? (flipped ^ {N{invert}}) : q;
endmodule
