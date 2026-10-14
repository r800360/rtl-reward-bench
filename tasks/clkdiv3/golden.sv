// A mod-3 counter on the rising edge, q_pos high for count 0, q_neg = q_pos delayed half a period on the falling
// edge, clk_out = q_pos | q_neg. Only one OR input changes at each edge, so the output cannot glitch.
module clkdiv3 (
  input  logic clk,
  input  logic rst,
  output logic clk_out
);
  logic [1:0] count;
  logic       q_pos, q_neg;
  always_ff @(posedge clk)
    if (rst) begin
      count <= '0;
      q_pos <= 1'b0;
    end else begin
      count <= (count == 2'd2) ? 2'd0 : count + 2'd1;
      q_pos <= (count == 2'd2);          // high while count is 0
    end
  always_ff @(negedge clk)
    if (rst) q_neg <= 1'b0;
    else     q_neg <= q_pos;
  assign clk_out = q_pos | q_neg;
endmodule
