// label: correct
// note: done from a shift counter instead of a comparison with the captured seed
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
  localparam int CW = N + 1;
  localparam logic [CW-1:0] PERIOD = (1 << N) - 1;
  logic [CW-1:0] n;
  logic          nonzero;
  always_ff @(posedge clk)
    if (!rst_n) begin
      q <= '0; n <= '0; nonzero <= 1'b0;
    end else if (load) begin
      q <= seed; n <= '0; nonzero <= seed != '0;
    end else begin
      q <= {q[N-2:0], ^(q & TAPS)};
      n <= (n == PERIOD) ? CW'(1) : n + 1'b1;
    end
  assign done = nonzero && n == PERIOD;
endmodule
