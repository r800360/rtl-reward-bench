// Properties for any line waveform (CLKS_PER_BIT = 4 keeps traces short): valid lasts one cycle, data changes only
// with valid, and valid and frame_err are never high together. They say nothing about which byte is received, so
// this formal grader is a protocol check, not a correctness proof.
module harness (input logic clk, rst_n, rx);
  wire       valid, ferr;
  wire [7:0] data;
  logic      past = 1'b0;
  serial_rx #(.CLKS_PER_BIT(4)) u (.clk, .rst_n, .rx, .valid, .data, .frame_err(ferr));
  initial assume (!rst_n);
  always_ff @(posedge clk) past <= 1'b1;
  always_ff @(posedge clk) if (past) begin
    if ($past(valid)) assert (!valid);
    if ($past(rst_n) && rst_n && !valid) assert (data == $past(data));
  end
  always_comb if (past) assert (!(valid && ferr));
endmodule
