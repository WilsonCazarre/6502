`timescale 1ns / 1ps

module alu_test ();
  reg                             carry_in;
  reg                       [7:0] input_a;
  reg                       [7:0] input_b;
  control_signals::alu_op_t       operation;
  wire                            flag_overflow;
  wire                            flag_zero;
  wire                            flag_neg;
  wire                            flag_carry;
  wire                      [7:0] alu_out;

  alu alu (
      .carry_in(carry_in),
      .input_a(input_a),
      .input_b(input_b),
      .operation(operation),
      .overflow_out(flag_overflow),
      .zero_out(flag_zero),
      .negative_out(flag_neg),
      .carry_out(flag_carry),
      .alu_out(alu_out)
  );


  initial begin
    operation = control_signals::ALU_ADD;
    carry_in  = 1'b1;
    input_a   = 8'h5;
    input_b   = 8'h5;
    #5;

    operation = control_signals::ALU_SUB;
    carry_in  = 1'b0;
    input_a   = 8'h4;
    input_b   = 8'h5;
    #5;

    input_a = 8'h3;
    input_b = 8'h8;
    #5;

    operation = control_signals::ALU_AND;
    input_a   = 8'b0011_0011;
    input_b   = 8'hFF;
    #5;

    operation = control_signals::ALU_SHIFT_LEFT;
    input_a   = 8'b1100_0011;
    input_b   = 8'b1;
    #5;

    $stop;
  end
endmodule
