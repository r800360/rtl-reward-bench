module onehot_decoder #(parameter int N = 2) (
  input  logic               en,
  input  logic [N-1:0]       sel,
  output logic [(1<<N)-1:0]  y
);
  always_comb begin
    y = '0;
    if (en) y[sel] = 1'b1;
  end
endmodule
