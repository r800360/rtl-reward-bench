// label: bug
// class: wrong bit order
// note: selects bit 2^N-1-sel for every sel but 0; the weak test checks bit 0 for sel = 0 and only one-hotness after
module onehot_decoder #(parameter int N = 2) (
  input  logic               en,
  input  logic [N-1:0]       sel,
  output logic [(1<<N)-1:0]  y
);
  always_comb begin
    y = '0;
    if (en) y[(sel == '0) ? 0 : (1 << N) - 1 - sel] = 1'b1;
  end
endmodule
