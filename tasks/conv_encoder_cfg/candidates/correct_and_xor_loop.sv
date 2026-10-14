// label: correct
// note: the convolution written as an explicit AND/XOR loop
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
    if (!rst_n)            h <= '0;
    else if (!(|load))     h <= {din, h[N-1:1]};
  always_ff @(posedge clk) if (load[0]) g0 <= g;
  always_ff @(posedge clk) if (load[1]) g1 <= g;
  always_comb begin
    dout = 2'b00;
    for (int i = 0; i < N; i++) begin
      dout[0] = dout[0] ^ (g0[i] & h[i]);
      dout[1] = dout[1] ^ (g1[i] & h[i]);
    end
  end
endmodule
