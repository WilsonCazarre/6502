`timescale 1ns / 1ps

module processador_test ();
  logic clk = 1;
  always #10 clk = ~clk;

  // signals and modules declaration here

  // unit under test
  uut_module uut()

  alu u_alu(
    .carry_in     (carry_in     ),
    .input_a      (input_a      ),
    .input_b      (input_b      ),
    .invert_b     (invert_b     ),
    .operation    (operation    ),
    .alu_out      (alu_out      ),
    .overflow_out (overflow_out ),
    .zero_out     (zero_out     ),
    .negative_out (negative_out ),
    .carry_out    (carry_out    )
  );
  

  initial begin
    // write the simulation stimulus here


    // use this snippet to wait for 1 (or more) clk cycles
    repeat (1) @(posedge clk);

    $stop;
  end
endmodule
