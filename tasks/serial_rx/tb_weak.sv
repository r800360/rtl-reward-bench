// Weak test in the style of a lab bench: four bytes (a5, a8, ab, ae) at the nominal rate, each checked when valid
// rises. (All four have bit 7 = 1.)
`timescale 1ns/1ps
`include "tb_util.svh"
module tb_weak;
  `TB_COUNTERS
  logic clk = 0, rst_n = 0, rx = 1;
  wire  valid, frame_err;
  wire  [7:0] data;
  logic [7:0] got [$];
  serial_rx #(.CLKS_PER_BIT(16)) dut (.clk, .rst_n, .rx, .valid, .data, .frame_err);
  always #10 clk = ~clk;
  always @(posedge clk) if (valid) got.push_back(data);
  // behavioral transmitter: bit time scaled by (1 + err_permille / 1000)
  task automatic send(input logic [7:0] b, input int err_permille, input logic stop = 1'b1);
    real tbit;
    tbit = 16 * 20.0 * (1.0 + err_permille / 1000.0);
    rx = 0; #(tbit);
    for (int k = 0; k < 8; k++) begin rx = b[k]; #(tbit); end
    rx = stop; #(tbit);
    rx = 1; #(tbit);
  endtask
  initial begin
    repeat (4) @(posedge clk);
    @(negedge clk) rst_n = 1;
    #1000;
    send(8'ha5, 0); send(8'ha8, 0); send(8'hab, 0); send(8'hae, 0);
    #2000;
    `CHECK_EQ(got.size(), 4, "bytes received")
    if (got.size() == 4) begin
      `CHECK_EQ(got[0], 8'ha5, "byte 0")
      `CHECK_EQ(got[1], 8'ha8, "byte 1")
      `CHECK_EQ(got[2], 8'hab, "byte 2")
      `CHECK_EQ(got[3], 8'hae, "byte 3")
    end
    `TB_FINISH
  end
endmodule
