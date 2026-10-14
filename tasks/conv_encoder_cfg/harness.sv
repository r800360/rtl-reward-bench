// Sequential equivalence with the golden design (N = 5). Step 0: reset low and load = 11, so both designs load
// both generators with the same value on the first edge (generators have no reset). Then any inputs.
module harness (input logic clk, rst_n, input logic [1:0] load, input logic [4:0] g, input logic din);
  wire [1:0] og, od;
  gold_conv_encoder_cfg #(.N(5)) cg (.clk, .rst_n, .load, .g, .din, .dout(og));
  conv_encoder_cfg #(.N(5)) cd (.clk, .rst_n, .load, .g, .din, .dout(od));
  logic past = 1'b0;
  always_ff @(posedge clk) past <= 1'b1;
  initial assume (!rst_n && load == 2'b11);
  always_comb if (past) assert (og == od);
endmodule
