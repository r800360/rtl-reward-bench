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
  logic [N-1:0] seed_q;
  logic         running;
  always_ff @(posedge clk)
    if (!rst_n) begin
      q <= '0; seed_q <= '0; running <= 1'b0;
    end else if (load) begin
      q <= seed; seed_q <= seed; running <= 1'b0;
    end else begin
      q <= {q[N-2:0], ^(q & TAPS)};
      running <= 1'b1;
    end
  assign done = running && seed_q != '0 && q == seed_q;
endmodule
