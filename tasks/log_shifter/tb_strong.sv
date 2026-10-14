// Strong test: every operation, direction, amount and input word for N <= 8; 20000 random vectors otherwise.
`timescale 1ns/1ps
`include "tb_util.svh"
module tb_strong;
  parameter int N = 4;
  localparam int S = $clog2(N);
  `TB_COUNTERS
  logic rotate, left;
  logic [S-1:0] amt;
  logic [N-1:0] din;
  wire  [N-1:0] dout;
  log_shifter #(.N(N)) dut (.rotate, .left, .amt, .din, .dout);
  function automatic logic [N-1:0] model(logic r, logic l, int k, logic [N-1:0] x);
    logic [2*N-1:0] w;
    if (l) begin
      w = {x, x} << k;
      return r ? w[2*N-1:N] : x << k;
    end
    w = {x, x} >> k;
    return r ? w[N-1:0] : x >> k;
  endfunction
  task automatic t(logic r, logic l, int k, logic [N-1:0] x);
    rotate = r; left = l; amt = S'(k); din = x;
    #1 `CHECK_EQ(dout, model(r, l, k, x), $sformatf("rotate %0d left %0d amt %0d din %0h", r, l, k, x))
  endtask
  initial begin
    if (N <= 8) begin
      for (int r = 0; r < 2; r++)
        for (int l = 0; l < 2; l++)
          for (int k = 0; k < N; k++)
            for (int x = 0; x < (1 << N); x++) t(r[0], l[0], k, N'(x));
    end else
      for (int i = 0; i < 20000; i++) t($urandom % 2, $urandom % 2, $urandom % N, N'({$urandom, $urandom}));
    `TB_FINISH
  end
endmodule
