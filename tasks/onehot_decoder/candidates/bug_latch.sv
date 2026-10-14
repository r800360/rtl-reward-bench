// label: bug
// class: inferred latch
// note: no assignment when en = 0, so y keeps its old value instead of going to zero
module onehot_decoder #(parameter int N = 2) (
  input  logic               en,
  input  logic [N-1:0]       sel,
  output logic [(1<<N)-1:0]  y
);
  always @* begin
    if (en) begin
      y = '0;
      y[sel] = 1'b1;
    end
  end
endmodule
