// label: bug
// class: missing control input
// note: decodes sel whatever en is; the weak test never drives en low
module onehot_decoder #(parameter int N = 2) (
  input  logic               en,
  input  logic [N-1:0]       sel,
  output logic [(1<<N)-1:0]  y
);
  always_comb begin
    y = '0;
    y[sel] = 1'b1;
  end
endmodule
