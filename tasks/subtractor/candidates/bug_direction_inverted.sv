// label: bug
// class: control polarity
// note: computes B - A when sub_ab = 1 and A - B when 0
module subtractor #(parameter int N = 4) (
  input  logic                sub_ab,
  input  logic signed [N-1:0] a, b,
  output logic signed [N-1:0] d,
  output logic                ovf_pos,
  output logic                ovf_neg
);
  logic signed [N-1:0] x, y;
  always_comb begin
    x = sub_ab ? b : a;
    y = sub_ab ? a : b;
    d = x - y;
    ovf_pos = ~x[N-1] &  y[N-1] &  d[N-1];
    ovf_neg =  x[N-1] & ~y[N-1] & ~d[N-1];
  end
endmodule
