// label: bug
// class: structural rule violated
// note: correct function written with shift operators and ?: instead of mux2 instances; every functional grader
// note: passes it, only the structural check sees the violation (a mistake seen in a graded submission, in part)
module log_shifter #(parameter int N = 4) (
  input  logic                 rotate,
  input  logic                 left,
  input  logic [$clog2(N)-1:0] amt,
  input  logic [N-1:0]         din,
  output logic [N-1:0]         dout
);
  logic [2*N-1:0] wl, wr;
  assign wl = {din, din} << amt;
  assign wr = {din, din} >> amt;
  assign dout = left ? (rotate ? wl[2*N-1:N] : din << amt) : (rotate ? wr[N-1:0] : din >> amt);
endmodule
