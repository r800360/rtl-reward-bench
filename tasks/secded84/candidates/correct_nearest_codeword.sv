// label: correct
// note: brute force: the code word at distance <= 1 among all 16, else a double error
// note: lint rejects it for a style warning (a 1-bit value added to an int), a false fail on correct code
module secded84 (
  input  logic [7:0] c,
  output logic [3:0] d,
  output logic       corrected,
  output logic       double_err
);
  function automatic logic [7:0] enc(logic [3:0] x);
    logic p4, p2, p1;
    p4 = x[3] ^ x[2] ^ x[1];
    p2 = x[3] ^ x[2] ^ x[0];
    p1 = x[3] ^ x[1] ^ x[0];
    enc = {x, p4, p2, p1, ^{x, p4, p2, p1}};
  endfunction
  always_comb begin
    logic [7:0] e;
    int hd;
    d = c[7:4];
    corrected = 1'b0;
    double_err = 1'b1;
    for (int x = 0; x < 16; x++) begin
      e = enc(4'(x)) ^ c;
      hd = 0;
      for (int i = 0; i < 8; i++) hd = hd + e[i];
      if (hd == 0) begin d = 4'(x); double_err = 1'b0; end
      if (hd == 1) begin d = 4'(x); double_err = 1'b0; corrected = 1'b1; end
    end
  end
endmodule
