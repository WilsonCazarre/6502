`timescale 1ns / 1ps

module template_test ();
  logic clk = 1;
  always #10 clk = ~clk;

  // signals and modules declaration here

  // unit under test
  uut_module uut()

  initial begin
    // write the simulation stimulus here


    // use this snippet to wait for 1 (or more) clk cycles
    repeat (1) @(posedge clk);

    $stop;
  end
endmodule
