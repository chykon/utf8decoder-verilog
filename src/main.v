`include "utf8decoder.v"

module main;
  reg clock;
  reg reset;
  reg allow;
  reg finish;
  reg[7:0] byte;
  wire[20:0] code_point;
  wire[1:0] status;

  UTF8Decoder decoder(
    .clock(clock),
    .reset(reset),
    .allow(allow),
    .finish(finish),
    .byte(byte),
    .code_point(code_point),
    .status(status)
  );

  initial begin
    clock = 0;
    reset = 0;
    allow = 0;
    finish = 0;
    byte = 0;
    forever begin
      #1 clock = ~clock;
    end
  end

  always @(posedge clock) begin
    // ...
  end
endmodule
