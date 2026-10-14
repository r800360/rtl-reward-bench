// label: bug
// class: missing hold condition
// note: the history shifts on every edge, also while a generator is loaded; the weak test releases reset only after
// note: loading, so the extra shifts never touch real data
module conv_encoder_cfg #(parameter int N = 5) (
  input  logic         clk,
  input  logic         rst_n,
  input  logic [1:0]   load,
  input  logic [N-1:0] g,
  input  logic         din,
  output logic [1:0]   dout
);
  logic [N-1:0] h, g0, g1;
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n) h <= '0;
    else        h <= {din, h[N-1:1]};
  always_ff @(posedge clk) begin
    if (load[0]) g0 <= g;
    if (load[1]) g1 <= g;
  end
  assign dout = {^(g1 & h), ^(g0 & h)};
endmodule
