module secded84 (
  input  logic [7:0] c,
  output logic [3:0] d,
  output logic       corrected,
  output logic       double_err
);
  logic [2:0] syn;
  logic       odd;
  always_comb begin
    syn = c[3:1] ^ {c[7] ^ c[6] ^ c[5], c[7] ^ c[6] ^ c[4], c[7] ^ c[5] ^ c[4]};
    odd = ^c;
    d = c[7:4];
    corrected = 1'b0;
    double_err = 1'b0;
    if (syn != 3'b000 && !odd) double_err = 1'b1;
    else if (syn != 3'b000 || odd) begin
      corrected = 1'b1;
      case (syn)
        3'b111: d[3] = ~c[7];
        3'b110: d[2] = ~c[6];
        3'b101: d[1] = ~c[5];
        3'b011: d[0] = ~c[4];
        default: ;
      endcase
    end
  end
endmodule
