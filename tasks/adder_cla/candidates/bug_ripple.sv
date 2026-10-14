// label: bug
// class: fails the speed requirement
// note: correct sums, but C[i+1] = G[i] | P[i] & C[i] chains every carry through the previous one; only the
// note: logic-depth check sees it (a mistake seen in a graded submission)
module adder_cla #(parameter int N = 16) (
  input  logic [N-1:0] a, b,
  input  logic         cin,
  output logic [N:0]   sum
);
  logic [N:0] c;
  assign c[0] = cin;
  genvar i;
  generate
    for (i = 0; i < N; i = i + 1) begin : g_c
      assign c[i+1] = (a[i] & b[i]) | ((a[i] | b[i]) & c[i]);
    end
  endgenerate
  assign sum = {c[N], a ^ b ^ c[N-1:0]};
endmodule
