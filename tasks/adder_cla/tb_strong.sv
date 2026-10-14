// Strong test: exhaustive for N <= 6, 50000 random vectors plus the all-propagate corner cases otherwise.
`timescale 1ns/1ps
`include "tb_util.svh"
module tb_strong;
  parameter int N = 16;
  `TB_COUNTERS
  logic [N-1:0] a, b;
  logic cin;
  wire  [N:0] sum;
  adder_cla #(.N(N)) dut (.a, .b, .cin, .sum);
  task automatic t(logic [N-1:0] x, logic [N-1:0] y, logic c);
    a = x; b = y; cin = c;
    #1 `CHECK_EQ(sum, (N+1)'(x) + (N+1)'(y) + (N+1)'(c), $sformatf("%0h + %0h + %0d", x, y, c))
  endtask
  initial begin
    if (N <= 6) begin
      for (int x = 0; x < (1 << N); x++)
        for (int y = 0; y < (1 << N); y++)
          for (int c = 0; c < 2; c++) t(N'(x), N'(y), c[0]);
    end else begin
      t('1, '0, 1'b1); t('0, '1, 1'b1); t('1, '1, 1'b1); t('1, '0, 1'b0);
      for (int i = 0; i < 50000; i++) t(N'({$urandom, $urandom}), N'({$urandom, $urandom}), 1'($urandom));
    end
    `TB_FINISH
  end
endmodule
