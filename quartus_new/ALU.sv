/*
ALU.v
*/

module ALU (
  input  wire      carry_in,
  input  wire[7:0] input_a,
  input  wire[7:0] input_b,
  input  wire[2:0] operation,
  
  output wire[7:0] alu_out,
  output wire      flag_overflow,
  output wire      flag_zero,
  output wire      flag_neg,
  output wire      flag_carry
);

reg[8:0] result;

localparam [2:0] 
  OP_ADD        = 3'b000,
  OP_SUB        = 3'b001,
  OP_AND        = 3'b010,
  OP_OR         = 3'b011,
  OP_XOR        = 3'b100,
  OP_SHIFT_LEFT = 3'b101;


assign alu_out = result[7:0];

assign flag_carry = result[8];
assign flag_neg   = result[7];
assign flag_zero  = ~|alu_out;
assign flag_overflow = (~input_a[7] & ~input_b[7] & result[7]) | 
                       (input_a[7] & input_b[7] & ~result[7]) ;

always@* begin
  case (operation)
    OP_ADD: begin
      result = input_a + input_b + carry_in;
    end
    OP_SUB: begin
      result = input_a - input_b - carry_in;
    end
    OP_AND: begin
      result = input_a & input_b;
    end
    OP_OR: begin
      result = input_a | input_b;
    end
    OP_XOR: begin
      result = input_a ^ input_b;
    end
    OP_SHIFT_LEFT: begin
      result = (input_a << 1) + carry_in;
    end
    default: begin
      result = 8'b0;
    end
      
  endcase
end
  
endmodule