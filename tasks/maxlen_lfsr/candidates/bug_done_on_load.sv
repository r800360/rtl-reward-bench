// label: bug
// class: output not qualified
// note: done = (q == seed): high while loading, right after the load, and following the live seed input; the weak
// note: test only asks that done appears with q equal to the seed (a mistake seen in a graded submission)
module maxlen_lfsr #(parameter int N = 4) (
  input  logic         clk,
  input  logic         rst_n,
  input  logic         load,
  input  logic [N-1:0] seed,
  output logic [N-1:0] q,
  output logic         done
);
  localparam logic [7:0] TAPS8 = (N == 2) ? 8'b0000_0011 : (N == 3) ? 8'b0000_0110 : (N == 4) ? 8'b0000_1100 :
                                 (N == 5) ? 8'b0001_0100 : (N == 6) ? 8'b0011_0000 : (N == 7) ? 8'b0110_0000 :
                                 8'b1011_1000;
  localparam logic [N-1:0] TAPS = TAPS8[N-1:0];
  always_ff @(posedge clk)
    if (!rst_n)    q <= '0;
    else if (load) q <= seed;
    else           q <= {q[N-2:0], ^(q & TAPS)};
  assign done = (q == seed);
endmodule
