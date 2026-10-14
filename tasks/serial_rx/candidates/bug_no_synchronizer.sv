// label: bug
// class: clock-domain crossing (invisible to simulation)
// note: uses rx directly in the state machine with no synchronizer: metastability in hardware. No simulation or
// note: formal grader can see it; only the structural synchronizer rule of the synth grader does
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
  localparam logic [CW-1:0] HALF1 = HALF + CW'(2);  // no synchronizer delay to compensate for
  typedef enum logic [2:0] {WAIT_IDLE, IDLE, START, BITS, STOP} state_t;
  state_t        state;
  logic [CW-1:0] count;
  logic [2:0]    index;
  logic [7:0]    shift;
  always_ff @(posedge clk)
    if (!rst_n) begin
      state <= WAIT_IDLE; count <= '0; index <= '0; shift <= '0;
      data <= '0; valid <= 1'b0; frame_err <= 1'b0;
    end else begin
      valid <= 1'b0;
      frame_err <= 1'b0;
      case (state)
        WAIT_IDLE: if (rx) state <= IDLE;
        IDLE:      if (!rx) begin state <= START; count <= '0; end
        START:
          if (count == HALF1) begin count <= '0; index <= '0; state <= rx ? IDLE : BITS; end
          else count <= count + 1'b1;
        BITS:
          if (count == FULL) begin
            count <= '0;
            shift <= {rx, shift[7:1]};
            index <= index + 1'b1;
            if (index == 3'd7) state <= STOP;
          end else count <= count + 1'b1;
        STOP:
          if (count == FULL) begin
            count <= '0;
            if (rx) begin data <= shift; valid <= 1'b1; state <= IDLE; end
            else begin frame_err <= 1'b1; state <= WAIT_IDLE; end
          end else count <= count + 1'b1;
        default: state <= WAIT_IDLE;
      endcase
    end
endmodule
