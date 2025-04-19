module alu (
    input wire                            carry_in,
    input wire                      [7:0] input_a,
    input wire                      [7:0] input_b,
    input wire                            invert_b,
    input control_signals::alu_op_t       operation,

    output wire [7:0] alu_out,
    output wire       overflow_out,
    output wire       zero_out,
    output wire       negative_out,
    output wire       carry_out
);

  logic [8:0] result;
  logic [7:0] effective_b;
  assign effective_b = invert_b ? ~input_b : input_b;

  assign alu_out = result[7:0];

  assign carry_out = result[8];
  assign negative_out = result[7];
  assign zero_out = ~|alu_out;
  assign overflow_out = (~input_a[7] & ~input_b[7] & result[7]) |
                       (input_a[7] & input_b[7] & ~result[7]) ;

  always_comb begin
    case (operation)
      control_signals::ALU_ADD: begin
        result = input_a + effective_b + carry_in;
      end
      control_signals::ALU_AND: begin
        result = input_a & input_b;
      end
      control_signals::ALU_OR: begin
        result = input_a | input_b;
      end
      control_signals::ALU_XOR: begin
        result = input_a ^ input_b;
      end
      control_signals::ALU_SHIFT_LEFT: begin
        result = (input_a << 1) + carry_in;
      end
      default: begin
        result = 8'bx;
      end
    endcase
  end

endmodule
