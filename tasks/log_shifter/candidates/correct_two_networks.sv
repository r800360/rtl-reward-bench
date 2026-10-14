// label: correct
// note: separate left and right log shifters, every selection still a mux2 instance
module log_shifter #(parameter int N = 4) (
  input  logic                 rotate,
  input  logic                 left,
  input  logic [$clog2(N)-1:0] amt,
  input  logic [N-1:0]         din,
  output logic [N-1:0]         dout
);
  localparam int S = $clog2(N);
  logic [N-1:0] l [0:S] /*verilator split_var*/;
  logic [N-1:0] r [0:S] /*verilator split_var*/;
  assign l[0] = din;
  assign r[0] = din;
  genvar i, s;
  generate
    for (s = 0; s < S; s = s + 1) begin : g_stage
      for (i = 0; i < N; i = i + 1) begin : g_bit
        logic lin, rin;
        if (i >= (1 << s)) begin : g_l
          assign lin = l[s][i - (1 << s)];
        end else begin : g_lf
          mux2 f (.a0(1'b0), .a1(l[s][N - (1 << s) + i]), .s(rotate), .y(lin));
        end
        if (i + (1 << s) < N) begin : g_r
          assign rin = r[s][i + (1 << s)];
        end else begin : g_rf
          mux2 f (.a0(1'b0), .a1(r[s][i + (1 << s) - N]), .s(rotate), .y(rin));
        end
        mux2 ml (.a0(l[s][i]), .a1(lin), .s(amt[s]), .y(l[s+1][i]));
        mux2 mr (.a0(r[s][i]), .a1(rin), .s(amt[s]), .y(r[s+1][i]));
      end
    end
    for (i = 0; i < N; i = i + 1) begin : g_out
      mux2 m (.a0(r[S][i]), .a1(l[S][i]), .s(left), .y(dout[i]));
    end
  endgenerate
endmodule
