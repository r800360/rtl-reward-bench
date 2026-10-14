// Strong test: all 256 byte values at the nominal rate; 60 random bytes with the transmitter 3 % slow and 3 % fast;
// a bad stop bit (frame_err, no byte, data unchanged); a short glitch on the idle line (nothing received); valid lasts
// one cycle and data holds between bytes.
`timescale 1ns/1ps
`include "tb_util.svh"
module tb_strong;
  `TB_COUNTERS
  logic clk = 0, rst_n = 0, rx = 1;
  wire  valid, frame_err;
  wire  [7:0] data;
  logic [7:0] got [$], sent [$];
  logic [7:0] held;
  int ferrs = 0;
  serial_rx #(.CLKS_PER_BIT(16)) dut (.clk, .rst_n, .rx, .valid, .data, .frame_err);
  always #10 clk = ~clk;
  always @(posedge clk) begin
    if (valid) begin got.push_back(data); held = data; end
    else if (rst_n && got.size() > 0) `CHECK_EQ(data, held, "data holds between bytes")
    if (frame_err) ferrs++;
  end
  always @(posedge clk) if (valid) @(posedge clk) `CHECK_EQ(valid, 1'b0, "valid lasts one cycle")
  // behavioral transmitter: bit time scaled by (1 + err_permille / 1000)
  task automatic send(input logic [7:0] b, input int err_permille, input logic stop = 1'b1);
    real tbit;
    tbit = 16 * 20.0 * (1.0 + err_permille / 1000.0);
    rx = 0; #(tbit);
    for (int k = 0; k < 8; k++) begin rx = b[k]; #(tbit); end
    rx = stop; #(tbit);
    rx = 1; #(tbit);
  endtask
  task automatic expect_all(input string what);
    `CHECK_EQ(got.size(), sent.size(), {what, ": bytes received"})
    for (int i = 0; i < sent.size() && i < got.size(); i++) `CHECK_EQ(got[i], sent[i], $sformatf("%s byte %0d", what, i))
    got.delete(); sent.delete();
  endtask
  initial begin
    repeat (4) @(posedge clk);
    @(negedge clk) rst_n = 1;
    #1000;
    for (int b = 0; b < 256; b++) begin sent.push_back(8'(b)); send(8'(b), 0); end
    #1000 expect_all("nominal rate");
    for (int i = 0; i < 60; i++) begin logic [7:0] b; b = 8'($urandom); sent.push_back(b); send(b, 30); end
    #1000 expect_all("3 % slow");
    for (int i = 0; i < 60; i++) begin logic [7:0] b; b = 8'($urandom); sent.push_back(b); send(b, -30); end
    #1000 expect_all("3 % fast");
    send(8'h3c, 0, 1'b0);                               // stop bit low
    #2000;
    `CHECK_EQ(got.size(), 0, "framing error: no byte")
    `CHECK_EQ(ferrs, 1, "framing error reported")
    rx = 0; #100; rx = 1; #2000;                        // glitch of 100 ns (less than half a bit)
    `CHECK_EQ(got.size(), 0, "glitch: no byte")
    `TB_FINISH
  end
endmodule
