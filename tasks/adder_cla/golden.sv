// Two-level lookahead: every carry is a sum of products of generate/propagate terms and cin.
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
          assign term[0] = (&p[i:0]) & cin;
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
