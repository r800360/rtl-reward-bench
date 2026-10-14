// label: correct
// note: synchronizer in its own process, a down-counting bit timer and a remaining-bits counter
module serial_rx #(parameter int CLKS_PER_BIT = 16) (
  input  logic       clk,
  input  logic       rst_n,
  input  logic       rx,
  output logic       valid,
  output logic [7:0] data,
  output logic       frame_err
);
  localparam int TW = $clog2(CLKS_PER_BIT);
  localparam int HALF_I = CLKS_PER_BIT / 2 - 2;
  localparam int FULL_I = CLKS_PER_BIT - 1;
  localparam logic [TW-1:0] HALF = HALF_I[TW-1:0];
  localparam logic [TW-1:0] FULL = FULL_I[TW-1:0];
  logic rx_meta, rx_sync;
  always_ff @(posedge clk)
    if (!rst_n) {rx_sync, rx_meta} <= 2'b11;
    else        {rx_sync, rx_meta} <= {rx_meta, rx};

  typedef enum logic [2:0] {WAIT_HIGH, IDLE, START, DATA, STOP} st_t;
  st_t           st;
  logic [TW-1:0] timer;
  logic [3:0]    left;
  logic [7:0]    sh;
  always_ff @(posedge clk) begin
    valid <= 1'b0;
    frame_err <= 1'b0;
    if (!rst_n) begin
      st <= WAIT_HIGH; timer <= '0; left <= '0; sh <= '0; data <= '0;
    end else begin
      if (timer != '0) timer <= timer - 1'b1;
      case (st)
        WAIT_HIGH: if (rx_sync) st <= IDLE;
        IDLE:      if (!rx_sync) begin st <= START; timer <= HALF; end
        START:
          if (timer == '0) begin
            if (rx_sync) st <= IDLE;
            else begin st <= DATA; timer <= FULL; left <= 4'd8; end
          end
        DATA:
          if (timer == '0) begin
            sh <= {rx_sync, sh[7:1]};
            timer <= FULL;
            left <= left - 1'b1;
            if (left == 4'd1) st <= STOP;
          end
        STOP:
          if (timer == '0) begin
            if (rx_sync) begin data <= sh; valid <= 1'b1; st <= IDLE; end
            else begin frame_err <= 1'b1; st <= WAIT_HIGH; end
          end
        default: st <= WAIT_HIGH;
      endcase
    end
  end
endmodule
