// label: bug
// class: reset scope too wide
// note: rst_n also clears the generators, so a reset in mid-stream loses the code; the weak test programs them
// note: after the only reset
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
    if (!rst_n) begin
      h <= '0; g0 <= '0; g1 <= '0;
    end else begin
      if (load == 2'b00) h <= {din, h[N-1:1]};
      if (load[0]) g0 <= g;
      if (load[1]) g1 <= g;
    end
  assign dout = {^(g1 & h), ^(g0 & h)};
endmodule
