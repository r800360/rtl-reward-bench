// The one primitive the log_shifter task may instantiate.
module mux2 (input logic a0, a1, s, output logic y);
  assign y = s ? a1 : a0;
endmodule
