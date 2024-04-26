`timescale 1ns/1ps

module ALU_test ();

reg      carry_in;
reg[7:0] input_a;
reg[7:0] input_b;
reg[2:0] operation;
wire      flag_overflow;
wire      flag_zero;
wire      flag_neg;
wire      flag_carry;
wire[7:0] alu_out;

ALU alu(
	.carry_in(carry_in),
	.input_a(input_a),
	.input_b(input_b),
	.operation(operation),
	.flag_overflow(flag_overflow),
	.flag_zero(flag_zero),
	.flag_neg(flag_neg),
	.flag_carry(flag_carry),
	.alu_out(alu_out)
);

parameter [2:0] 
  OP_ADD        = 3'b000,
  OP_SUB        = 3'b001,
  OP_AND        = 3'b010,
  OP_OR         = 3'b011,
  OP_XOR        = 3'b100,
  OP_SHIFT_LEFT = 3'b101;

initial begin
	operation=OP_ADD;
	input_a=8'd2;
	input_b=8'd2;
	carry_in=1'b0;
	#5;
	input_a=8'd255;
	input_b=8'd1;
	#5;
	operation=OP_SUB;
	input_a=8'h2;
	input_b=8'h2;
	#5;
	operation=OP_AND;
	input_a=8'hff;
	input_b=8'hfe;
	#5;
	operation=OP_SHIFT_LEFT;
	input_a=8'h0f;
	#5;
	operation=OP_ADD;
	input_a=8'h40;
	input_b=8'h40;
	#5;
end
endmodule