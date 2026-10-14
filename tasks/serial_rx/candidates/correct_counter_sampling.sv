// label: correct
// note: one bit counter for the whole frame and a single sample-point comparison
module serial_rx #(parameter int CLKS_PER_BIT = 16) (
  input  logic       clk,
  input  logic       rst_n,
  input  logic       rx,
  output logic       valid,
  output logic [7:0] data,
  output logic       frame_err
);
  localparam int CW = $clog2(CLKS_PER_BIT);
  localparam int HALF_I = CLKS_PER_BIT / 2 - 2;
  localparam int FULL_I = CLKS_PER_BIT - 1;
  localparam logic [CW-1:0] HALF = HALF_I[CW-1:0];
  localparam logic [CW-1:0] FULL = FULL_I[CW-1:0];
  logic [1:0]    sync;
  logic [CW-1:0] count;
  logic [3:0]    bitn;     // 0 = start, 1..8 data, 9 stop
  logic          busy, idle_seen;
  logic [7:0]    shift;
  always_ff @(posedge clk)
    if (!rst_n) begin
      sync <= 2'b11; busy <= 1'b0; idle_seen <= 1'b0; count <= '0; bitn <= '0; shift <= '0;
      data <= '0; valid <= 1'b0; frame_err <= 1'b0;
    end else begin
      sync <= {sync[0], rx};
      valid <= 1'b0;
      frame_err <= 1'b0;
      if (!busy) begin
        if (sync[1]) idle_seen <= 1'b1;
        else if (idle_seen) begin busy <= 1'b1; count <= '0; bitn <= '0; end
      end else if ((bitn == 0 && count == HALF) || (bitn != 0 && count == FULL)) begin
        count <= '0;
        if (bitn == 0) begin
          if (sync[1]) busy <= 1'b0; else bitn <= 4'd1;            // glitch: back to idle
        end else if (bitn <= 8) begin
          shift <= {sync[1], shift[7:1]};
          bitn  <= bitn + 1'b1;
        end else begin
          busy <= 1'b0;
          if (sync[1]) begin data <= shift; valid <= 1'b1; end
          else begin frame_err <= 1'b1; idle_seen <= 1'b0; end
        end
      end else count <= count + 1'b1;
    end
endmodule
