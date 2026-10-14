// Strong test: for every nonzero seed, reset gives 0, load gives the seed with done low, then 2^N + 1 shifts against
// a reference LFSR: all 2^N - 1 states visited, done high on exactly the cycle the seed returns.
`timescale 1ns/1ps
`include "tb_util.svh"
module tb_strong;
  parameter int N = 4;
  `TB_COUNTERS
  logic clk = 0, rst_n = 0, load = 0;
  logic [N-1:0] seed = '0, model;
  wire  [N-1:0] q;
  wire          done;
  maxlen_lfsr #(.N(N)) dut (.clk, .rst_n, .load, .seed, .q, .done);
  always #5 clk = ~clk;
  localparam logic [7:0] T8 = (N == 2) ? 8'h03 : (N == 3) ? 8'h06 : (N == 4) ? 8'h0C : (N == 5) ? 8'h14 :
                              (N == 6) ? 8'h30 : (N == 7) ? 8'h60 : 8'hB8;
  localparam logic [N-1:0] T = T8[N-1:0];
  initial begin
    for (int sd = 1; sd < (1 << N); sd++) begin
      @(negedge clk) rst_n = 0;
      @(posedge clk) #1 `CHECK_EQ(q, '0, "reset gives 0")
      `CHECK_EQ(done, 1'b0, "no done after reset")
      @(negedge clk) begin rst_n = 1; load = 1; seed = N'(sd); end
      @(posedge clk) #1 `CHECK_EQ(q, N'(sd), "load")
      `CHECK_EQ(done, 1'b0, "no done while loading")
      @(negedge clk) load = 0;
      model = N'(sd);
      for (int k = 1; k <= (1 << N) + 1; k++) begin
        @(posedge clk) #1;
        model = {model[N-2:0], ^(model & T)};
        `CHECK_EQ(q, model, $sformatf("seed %0h step %0d", sd, k))
        `CHECK_EQ(done, (k == (1 << N) - 1) ? 1'b1 : 1'b0, $sformatf("done at step %0d of seed %0h", k, sd))
      end
    end
    `TB_FINISH
  end
endmodule
