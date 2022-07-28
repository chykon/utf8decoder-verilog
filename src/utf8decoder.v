module UTF8Decoder
(
  input clock,
  input reset,
  input allow,
  input finish,
  input [7:0] byte,
  output reg[20:0] code_point,
  output reg[1:0] status
);
  localparam STATUS_INITIAL = 0;
  localparam STATUS_INPROCESS = 1;
  localparam STATUS_READY = 2;
  localparam STATUS_ERROR = 3;

  reg reg_reset;
  reg reg_allow;
  reg reg_finish;
  reg[7:0] reg_byte;

  reg[1:0] bytes_seen;
  reg[1:0] bytes_needed;
  reg[7:0] lower_boundary;
  reg[7:0] upper_boundary;

  always @(posedge clock) begin
    reg_reset <= reset;
    reg_allow <= allow;
    reg_byte <= byte;
    reg_finish <= finish;
    if (reg_reset) begin
      code_point <= 0;
      status <= STATUS_INITIAL;
      bytes_seen <= 0;
      bytes_needed <= 0;
      lower_boundary <= 'h80;
      upper_boundary <= 'hBF;
    end else if (reg_allow) begin
      if (reg_finish && (bytes_needed != 0)) begin
        bytes_needed <= 0;
        status <= STATUS_ERROR;
      end else if (reg_finish) begin
        status <= STATUS_READY;
      end else if (bytes_needed == 0) begin
        if ((reg_byte >= 'h00) && (reg_byte <= 'h7F)) begin
          code_point <= reg_byte;
          status <= STATUS_READY;
        end else if ((reg_byte >= 'hC2) && (reg_byte <= 'hDF)) begin
          bytes_needed <= 1;
          code_point <= reg_byte & 'h1F;
          status <= STATUS_INPROCESS;
        end else if ((reg_byte >= 'hE0) && (reg_byte <= 'hEF)) begin
          if (reg_byte == 'hE0) begin
            lower_boundary <= 'hA0;
          end else if (reg_byte == 'hED) begin
            upper_boundary <= 'h9F;
          end
          bytes_needed <= 2;
          code_point <= reg_byte & 'hF;
          status <= STATUS_INPROCESS;
        end else if ((reg_byte >= 'hF0) && (reg_byte <= 'hF4)) begin
          if (reg_byte == 'hF0) begin
            lower_boundary <= 'h90;
          end else if (reg_byte == 'hF4) begin
            upper_boundary <= 'h8F;
          end
          bytes_needed <= 3;
          code_point <= reg_byte & 'h7;
          status <= STATUS_INPROCESS;
        end else begin
          status <= STATUS_ERROR;
        end
      end else if (bytes_needed != 0) begin
        if ((reg_byte < lower_boundary) || (reg_byte > upper_boundary)) begin
          code_point <= 0;
          bytes_needed <= 0;
          bytes_seen <= 0;
          lower_boundary <= 'h80;
          upper_boundary <= 'hBF;
          status <= STATUS_ERROR;
        end
        lower_boundary <= 'h80;
        upper_boundary <= 'hBF;
        code_point <= (code_point << 6) | (reg_byte & 'h3F);
        bytes_seen <= bytes_seen + 1;
        if (bytes_seen == bytes_needed) begin
          bytes_needed <= 0;
          bytes_seen <= 0;
          status <= STATUS_READY;
        end
      end
    end
  end
endmodule
