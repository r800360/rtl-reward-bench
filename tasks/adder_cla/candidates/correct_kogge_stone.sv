// label: correct
// note: a Kogge-Stone parallel-prefix adder: log2(N) levels of (generate, propagate) combination
module adder_cla #(parameter int N = 16) (
  input  logic [N-1:0] a, b,
  input  logic         cin,
  output logic [N:0]   sum
);
  localparam int L = $clog2(N);
  logic [N-1:0] gl [0:L] /*verilator split_var*/;
  logic [N-1:0] pl [0:L] /*verilator split_var*/;
  assign gl[0] = a & b;
  assign pl[0] = a ^ b;
  genvar k, i;
  generate
    for (k = 0; k < L; k = k + 1) begin : g_level
      for (i = 0; i < N; i = i + 1) begin : g_bit
        if (i >= (1 << k)) begin : g_comb
          assign gl[k+1][i] = gl[k][i] | (pl[k][i] & gl[k][i - (1 << k)]);
          assign pl[k+1][i] = pl[k][i] & pl[k][i - (1 << k)];
        end else begin : g_pass
          assign gl[k+1][i] = gl[k][i];
          assign pl[k+1][i] = pl[k][i];
        end
      end
    end
  endgenerate
  // carry into bit i+1 = G[i:0] | P[i:0] & cin
  logic [N:0] c;
  assign c[0] = cin;
  assign c[N:1] = gl[L] | (pl[L] & {N{cin}});
  assign sum = {c[N], pl[0] ^ c[N-1:0]};
endmodule
