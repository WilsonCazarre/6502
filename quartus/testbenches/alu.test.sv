`timescale 1ns / 1ps

module alu_test ();
  reg                             carry_in;
  reg                       [7:0] input_a;
  reg                       [7:0] input_b;
  control_signals::alu_op_t       operation;
  reg                             flag_overflow;
  reg                             flag_zero;
  reg                             flag_neg;
  reg                             flag_carry;
  reg                       [7:0] alu_out;
  reg                             invert_b;

  logic                           clk;
  initial clk = 1;
  always #10 clk = ~clk;

  alu alu (
      .carry_in    (carry_in),
      .input_a     (input_a),
      .input_b     (input_b),
      .operation   (operation),
      .overflow_out(flag_overflow),
      .zero_out    (flag_zero),
      .negative_out(flag_neg),
      .carry_out   (flag_carry),
      .alu_out     (alu_out),
      .invert_b    (invert_b)
  );



  initial begin
    invert_b  = 0;
    operation = control_signals::ALU_ADD;
    carry_in  = 1'b1;
    input_a   = 8'h6;
    input_b   = 8'h5;
    repeat (1) @(posedge clk);

    operation = control_signals::ALU_SHIFT_LEFT;
    input_a   = 8'b1100_0011;
    input_b   = 8'b1;
    repeat (1) @(posedge clk);

    $stop;
  end
endmodule
