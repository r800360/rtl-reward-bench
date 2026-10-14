// Reverse the word for right moves, shift left in log2(N) mux stages (fill muxes choose 0 or the wrapped bit), reverse
// back. 2N + N log2(N) + N - 1 mux2 instances.
module log_shifter #(parameter int N = 4) (
  input  logic                 rotate,
  input  logic                 left,
  input  logic [$clog2(N)-1:0] amt,
  input  logic [N-1:0]         din,
  output logic [N-1:0]         dout
);
  localparam int S = $clog2(N);
  logic [N-1:0] stage [0:S] /*verilator split_var*/;
  genvar i, s;
  generate
    for (i = 0; i < N; i = i + 1) begin : g_in
      mux2 m (.a0(din[N-1-i]), .a1(din[i]), .s(left), .y(stage[0][i]));
    end
    for (s = 0; s < S; s = s + 1) begin : g_stage
      for (i = 0; i < N; i = i + 1) begin : g_bit
        logic from_below;
        if (i >= (1 << s)) begin : g_in_range
          assign from_below = stage[s][i - (1 << s)];
        end else begin : g_fill
          mux2 f (.a0(1'b0), .a1(stage[s][N - (1 << s) + i]), .s(rotate), .y(from_below));
        end
        mux2 m (.a0(stage[s][i]), .a1(from_below), .s(amt[s]), .y(stage[s+1][i]));
      end
    end
    for (i = 0; i < N; i = i + 1) begin : g_out
      mux2 m (.a0(stage[S][N-1-i]), .a1(stage[S][i]), .s(left), .y(dout[i]));
    end
  endgenerate
endmodule
