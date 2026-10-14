// label: bug
// class: no timing margin
// note: samples each bit right after its start (no half-bit offset); at the exact nominal rate it works, so the weak
// note: test passes, but a transmitter a few percent fast or slow is misread
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
  typedef enum logic [2:0] {WAIT_IDLE, IDLE, BITS, STOP} state_t;
  state_t        state;
  logic [1:0]    sync;
  logic [CW-1:0] count;
  logic [2:0]    index;
  logic [7:0]    shift;
  always_ff @(posedge clk)
    if (!rst_n) begin
      sync <= 2'b11; state <= WAIT_IDLE; count <= '0; index <= '0; shift <= '0;
      data <= '0; valid <= 1'b0; frame_err <= 1'b0;
    end else begin
      sync <= {sync[0], rx};
      valid <= 1'b0;
      frame_err <= 1'b0;
      case (state)
        WAIT_IDLE: if (sync[1]) state <= IDLE;
        IDLE:      if (!sync[1]) begin state <= BITS; count <= '0; index <= '0; end
        BITS:
          if (count == FULL) begin
            count <= '0;
            shift <= {sync[1], shift[7:1]};
            index <= index + 1'b1;
            if (index == 3'd7) state <= STOP;
          end else count <= count + 1'b1;
        STOP:
          if (count == FULL) begin
            count <= '0;
            if (sync[1]) begin data <= shift; valid <= 1'b1; state <= IDLE; end
            else begin frame_err <= 1'b1; state <= WAIT_IDLE; end
          end else count <= count + 1'b1;
        default: state <= WAIT_IDLE;
      endcase
    end
endmodule
