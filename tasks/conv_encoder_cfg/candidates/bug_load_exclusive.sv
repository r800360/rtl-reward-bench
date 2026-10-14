// label: bug
// class: control bits not independent
// note: an if / else-if chain on load, so load = 11 loads only generator 0; the weak test loads one at a time
// note: (a mistake seen in a graded submission)
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
    if (!rst_n)              h <= '0;
    else if (load == 2'b00)  h <= {din, h[N-1:1]};
  always_ff @(posedge clk)
    if (load == 2'b01 || load == 2'b11) g0 <= g;
    else if (load == 2'b10)              g1 <= g;
  assign dout = {^(g1 & h), ^(g0 & h)};
endmodule
