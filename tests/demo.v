`include "utf8decoder.v"

module Demo;
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
  reg[7:0] string[0:14057];
  reg[13:0] current_char;
  reg[13:0] final_char;
  integer input_file;
  integer output_file;
  integer read_result;

  initial begin
    clock = 0;
    reset = 0;
    allow = 0;
    finish = 0;
    byte = 0;
    state = STATE_INITIAL;
    current_char = 0;
    final_char = 14057;
    input_file = $fopen("tests/data/utf8demo.txt", "rb");
    read_result = $fread(string, input_file);
    $fclose(input_file);
    output_file = $fopen("build/iverilog/test_demo_out.txt", "w");
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
          if (current_char <= final_char + 3) begin
            $fwrite(output_file, "%h,", reg_code_point);
          end else begin
            $fwrite(output_file, "%h", reg_code_point);
          end
        end
        if (current_char <= final_char) begin
          byte <= string[current_char];
          current_char <= current_char + 1;
          allow <= 1;
        end else if (current_char <= final_char + 3) begin
          // HACK: Wait final output
          current_char <= current_char + 1;
        end else begin
          if (reg_status == STATUS_READY) begin
            $fclose(output_file);
            $finish;
          end
        end
      end else begin
        $fwrite(output_file, "!ERROR!");
      end
    end
  end
endmodule
