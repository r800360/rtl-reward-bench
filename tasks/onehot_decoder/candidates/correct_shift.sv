// label: correct
// note: a shift instead of an indexed write
module onehot_decoder #(parameter int N = 2) (
  input  logic               en,
  input  logic [N-1:0]       sel,
  output logic [(1<<N)-1:0]  y
);
  assign y = {{((1 << N) - 1){1'b0}}, en} << sel;
endmodule
