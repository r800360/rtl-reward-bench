// label: bug
// class: missing product term
// note: the lookahead drops the all-propagate cin term for the top carry, so a carry from cin never reaches sum[N];
// note: wrong only when every bit propagates and cin = 1, which 20 random vectors almost never hit
module adder_cla #(parameter int N = 16) (
  input  logic [N-1:0] a, b,
  input  logic         cin,
  output logic [N:0]   sum
);
  logic [N-1:0] g, p;
  logic [N:0]   c;
  assign g = a & b;
  assign p = a | b;
  assign c[0] = cin;
  genvar i, j;
  generate
    for (i = 0; i < N; i = i + 1) begin : g_carry
      logic [i+1:0] term;
      for (j = 0; j <= i + 1; j = j + 1) begin : g_term
        if (j == 0) begin : g_cin
          if (i == N - 1) begin : g_drop
            assign term[0] = 1'b0;
          end else begin : g_keep
            assign term[0] = (&p[i:0]) & cin;
          end
        end else if (j == i + 1) begin : g_last
          assign term[j] = g[i];
        end else begin : g_mid
          assign term[j] = (&p[i:j]) & g[j-1];
        end
      end
      assign c[i+1] = |term;
    end
  endgenerate
  assign sum = {c[N], a ^ b ^ c[N-1:0]};
endmodule
