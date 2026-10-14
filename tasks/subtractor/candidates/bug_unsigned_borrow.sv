// label: bug
// class: unsigned overflow rule for signed numbers
// note: reports overflow from the borrow out of the top bit, which is the unsigned rule; caught even by the weak test
// note: (3 - 5 borrows but does not overflow)
module subtractor #(parameter int N = 4) (
  input  logic                sub_ab,
  input  logic signed [N-1:0] a, b,
  output logic signed [N-1:0] d,
  output logic                ovf_pos,
  output logic                ovf_neg
);
  logic [N:0] w;
  assign w = sub_ab ? ({1'b0, a} - {1'b0, b}) : ({1'b0, b} - {1'b0, a});
  assign d = w[N-1:0];
  assign ovf_pos = 1'b0;
  assign ovf_neg = w[N];
endmodule
