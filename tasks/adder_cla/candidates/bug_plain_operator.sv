// label: bug
// class: fails the speed requirement
// note: `a + b + cin`; correct, and Yosys maps + to its own lookahead adder, but with 16 levels: over the limit
module adder_cla #(parameter int N = 16) (
  input  logic [N-1:0] a, b,
  input  logic         cin,
  output logic [N:0]   sum
);
  assign sum = (N+1)'(a) + (N+1)'(b) + (N+1)'(cin);
endmodule
