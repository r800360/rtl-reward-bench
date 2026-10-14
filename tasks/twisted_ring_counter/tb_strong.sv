// Strong test: the exact state sequence after clear (two periods), clear asserted between edges (immediate, held,
// wins over load), load only at the clock edge, and every loadable value followed for 2N clocks.
`timescale 1ns/1ps
`include "tb_util.svh"
module tb_strong;
  parameter int N = 4;
  `TB_COUNTERS
  logic clk = 0, clear_n = 0, load_n = 1;
  logic [N-1:0] d = 0, model = 0;
  wire  [N-1:0] q;
  twisted_ring_counter #(.N(N)) dut (.clk, .clear_n, .load_n, .d, .q);
  always #5 clk = ~clk;
  function automatic logic [N-1:0] nxt(logic [N-1:0] x);
    return {~x[0], x[N-1:1]};
  endfunction
  task automatic step();
    @(posedge clk) #1;
    model = load_n ? nxt(model) : d;
    `CHECK_EQ(q, model, "state after a clock edge")
  endtask
  initial begin
    #12 `CHECK_EQ(q, '0, "clear at time 0")
    @(negedge clk) clear_n = 1;
    model = '0;
    repeat (4 * N + 1) step();          // ends one state past 0, so the clear below has something to clear
    // clear between edges: immediate, and it beats load
    @(negedge clk) begin clear_n = 0; load_n = 0; d = '1; end
    #1 `CHECK_EQ(q, '0, "clear acts before the next edge")
    @(posedge clk) #1 `CHECK_EQ(q, '0, "clear wins over load")
    @(negedge clk) begin clear_n = 1; load_n = 1; end
    model = '0;
    step();
    // load: not before the edge, then counting from the loaded value
    for (int v = 0; v < (1 << N) && v < 256; v++) begin
      @(negedge clk) begin load_n = 0; d = N'(v); end
      #2 `CHECK_EQ(q, model, "load has no effect before the clock edge")
      step();
      @(negedge clk) load_n = 1;
      repeat (2 * N) step();
    end
    `TB_FINISH
  end
endmodule
