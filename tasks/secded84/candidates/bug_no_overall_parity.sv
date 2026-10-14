// label: bug
// class: missing detection
// note: ignores P0, so it decodes like the 7-bit SEC code: any nonzero syndrome is "corrected", and two errors are
// note: miscorrected silently; the weak test has no double errors, but lint reports the unused input bit
module secded84 (
  input  logic [7:0] c,
  output logic [3:0] d,
  output logic       corrected,
  output logic       double_err
);
  logic [2:0] syn;
  always_comb begin
    syn = c[3:1] ^ {c[7] ^ c[6] ^ c[5], c[7] ^ c[6] ^ c[4], c[7] ^ c[5] ^ c[4]};
    d = c[7:4];
    double_err = 1'b0;
    corrected = syn != 3'b000;
    case (syn)
      3'b111: d[3] = ~c[7];
      3'b110: d[2] = ~c[6];
      3'b101: d[1] = ~c[5];
      3'b011: d[0] = ~c[4];
      default: ;
    endcase
  end
endmodule
