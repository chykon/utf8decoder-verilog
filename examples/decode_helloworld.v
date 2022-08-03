`include "utf8decoder.v"

module Main;
  localparam STATE_INITIAL = 0;
  localparam STATE_RESET = 1;
  localparam STATE_WORK = 2;

  localparam STATUS_INITIAL = 0;
  localparam STATUS_READY = 2;
  localparam STATUS_ERROR = 3;

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

  reg[20:0] reg_code_point;
  reg[1:0] reg_status;
  reg[1:0] state;
  reg[7:0] string[0:17];
  reg[4:0] current_char;
  reg[4:0] final_char;

  initial begin
    clock = 0;
    reset = 0;
    allow = 0;
    finish = 0;
    byte = 0;
    state = STATE_INITIAL;
    string[0] = 'h48;
    string[1] = 'h65;
    string[2] = 'h6C;
    string[3] = 'h6C;
    string[4] = 'h6F;
    string[5] = 'h2C;
    string[6] = 'h20;
    string[7] = 'hD0;
    string[8] = 'h9C;
    string[9] = 'hD0;
    string[10] = 'hB8;
    string[11] = 'hD1;
    string[12] = 'h80;
    string[13] = 'h20;
    string[14] = 'hF0;
    string[15] = 'h9F;
    string[16] = 'h91;
    string[17] = 'h8B;
    current_char = 0;
    final_char = 17;
    $display("Unicode code points by UTF8Decoder-Verilog:");
    forever begin
      #1 clock = ~clock;
    end
  end

  always @(posedge clock) begin
    reg_code_point <= code_point;
    reg_status <= status;
    if (state == STATE_INITIAL) begin
      reset <= 1;
      state <= STATE_RESET;
    end else if (state == STATE_RESET) begin
      if (reg_status == STATUS_INITIAL) begin
        reset <= 0;
        state <= STATE_WORK;
      end
    end else if (state == STATE_WORK) begin
      allow <= 0;
      if (reg_status != STATUS_ERROR) begin
        if (reg_status == STATUS_READY) begin
          if (current_char <= final_char) begin
            $write("%h,", reg_code_point);
          end else begin
            $write("%h", reg_code_point);
          end
        end
        if (current_char <= final_char) begin
          byte <= string[current_char];
          current_char <= current_char + 1;
          allow <= 1;
        end else begin
          if (reg_status == STATUS_READY) begin
            $write("\n\n");
            $finish;
          end
        end
      end else begin
        $display("ERROR");
      end
    end
  end
endmodule
