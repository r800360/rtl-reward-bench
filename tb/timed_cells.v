// Timed models of Yosys's generic cells, for the "timed" grader. The synthesized netlist of a candidate is simulated
// with a transport delay of 1-5 ns on every gate and 1 ns clock-to-q on flip-flops. Each gate instance draws its
// delay once (a fixed delay keeps the events of one gate in order); +TRIAL=<k> shifts the random stream, so each
// trial is a different delay assignment. Zero-delay simulation cannot show hazards; here, logic in which several
// inputs change at the same clock edge produces short pulses (glitches) for some delay assignments. Plain flip-flops
// only: the grader legalizes resets and enables into gates first.
`timescale 1ns/1ps
`define TIMED_DELAY \
    integer d, t; \
    initial begin \
      if (!$value$plusargs("TRIAL=%d", t)) t = 0; \
      repeat (t) d = $urandom; \
      d = $urandom_range(5, 1); \
    end
`define TIMED_GATE(NAME, EXPR) \
  module NAME (input A, input B, output Y); \
    reg y; \
    `TIMED_DELAY \
    initial y <= #6 (EXPR); \
    always @(A or B) y <= #(d) (EXPR); \
    assign Y = y; \
  endmodule
`TIMED_GATE(\$_AND_ , A & B)
`TIMED_GATE(\$_NAND_ , ~(A & B))
`TIMED_GATE(\$_OR_ , A | B)
`TIMED_GATE(\$_NOR_ , ~(A | B))
`TIMED_GATE(\$_XOR_ , A ^ B)
`TIMED_GATE(\$_XNOR_ , ~(A ^ B))
`TIMED_GATE(\$_ANDNOT_ , A & ~B)
`TIMED_GATE(\$_ORNOT_ , A | ~B)

module \$_NOT_ (input A, output Y);
  reg y;
  `TIMED_DELAY
  initial y <= #6 ~A;
  always @(A) y <= #(d) ~A;
  assign Y = y;
endmodule

module \$_BUF_ (input A, output Y);
  reg y;
  `TIMED_DELAY
  initial y <= #6 A;
  always @(A) y <= #(d) A;
  assign Y = y;
endmodule

module \$_MUX_ (input A, input B, input S, output Y);
  reg y;
  `TIMED_DELAY
  initial y <= #6 (S ? B : A);
  always @(A or B or S) y <= #(d) (S ? B : A);
  assign Y = y;
endmodule

module \$_DFF_P_ (input C, input D, output reg Q);
  always @(posedge C) Q <= #1 D;
endmodule

module \$_DFF_N_ (input C, input D, output reg Q);
  always @(negedge C) Q <= #1 D;
endmodule
