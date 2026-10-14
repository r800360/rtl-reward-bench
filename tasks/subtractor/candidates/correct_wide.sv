// label: correct
// note: computes the difference one bit wider and compares with the range
module subtractor #(parameter int N = 4) (
  input  logic                sub_ab,
  input  logic signed [N-1:0] a, b,
  output logic signed [N-1:0] d,
  output logic                ovf_pos,
  output logic                ovf_neg
);
  logic signed [N:0] w;
  assign w = sub_ab ? ($signed({a[N-1], a}) - $signed({b[N-1], b})) : ($signed({b[N-1], b}) - $signed({a[N-1], a}));
  assign d = w[N-1:0];
  assign ovf_pos = !w[N] && w[N-1];
  assign ovf_neg = w[N] && !w[N-1];
endmodule
