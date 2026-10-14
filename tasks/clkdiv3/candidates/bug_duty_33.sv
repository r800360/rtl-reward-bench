// label: bug
// class: wrong duty cycle
// note: high for one clock period out of three; the period is right, so the weak edge count passes
module clkdiv3 (
  input  logic clk,
  input  logic rst,
  output logic clk_out
);
  logic [1:0] count;
  always_ff @(posedge clk)
    if (rst) begin
      count   <= '0;
      clk_out <= 1'b0;
    end else begin
      count   <= (count == 2'd2) ? 2'd0 : count + 2'd1;
      clk_out <= (count == 2'd2);
    end
endmodule
