// label: correct
// note: a 3-bit one-hot ring instead of a counter; q_pos is a ring bit, so clk_out is still an OR of two flip-flops
module clkdiv3 (
  input  logic clk,
  input  logic rst,
  output logic clk_out
);
  logic [2:0] ring;
  logic       q_neg;
  always_ff @(posedge clk)
    if (rst) ring <= 3'b000;
    else     ring <= (ring == 3'b000) ? 3'b001 : {ring[1:0], ring[2]};
  always_ff @(negedge clk)
    if (rst) q_neg <= 1'b0;
    else     q_neg <= ring[0];
  assign clk_out = ring[0] | q_neg;
endmodule
