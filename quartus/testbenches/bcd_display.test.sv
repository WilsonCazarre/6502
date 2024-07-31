`timescale 1ns / 1ps

module bcd_display_test ();
  logic clk = 1;
  always #10 clk = ~clk;

  // signals and modules declaration here

  // unit under test

  logic [7:0] value;
  logic [6:0] hex_ones, hex_tens, hex_hundreds;

  bcd_display bcd_display (
      .value       (value),
      .hex_ones    (hex_ones),
      .hex_tens    (hex_tens),
      .hex_hundreds(hex_hundreds)
  );


  initial begin
    value = 8'd0;
    repeat (1) @(posedge clk);
    value = 8'd1;
    repeat (1) @(posedge clk);
    value = 8'd4;
    repeat (1) @(posedge clk);
    value = 8'd17;
    repeat (1) @(posedge clk);
    value = 8'd239;
    repeat (1) @(posedge clk);
    $stop;
  end
endmodule
