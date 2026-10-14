// label: bug
// class: glitch-prone clock (passes every zero-delay test)
// note: two mod-3 counters, one per clock edge, and clk_out decoded from both with comparisons. The waveform is
// note: right in zero-delay simulation and in formal, but several counter bits change at the same edge, so the decode
// note: can glitch in hardware; only the timed gate-level grader sees it (a mistake seen in a graded submission)
module clkdiv3 (
  input  logic clk,
  input  logic rst,
  output logic clk_out
);
  logic [1:0] p, n;
  always_ff @(posedge clk)
    if (rst) p <= '0;
    else     p <= (p == 2'd2) ? 2'd0 : p + 2'd1;
  always_ff @(negedge clk)
    if (rst) n <= '0;
    else     n <= (n == 2'd2) ? 2'd0 : n + 2'd1;
  assign clk_out = (3'(p) + 3'(n) > 3'd1) && (3'(p) + 3'(n) < 3'd5) && p >= 2'd1 && n >= 2'd1;
endmodule
