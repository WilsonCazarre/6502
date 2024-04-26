`timescale 1ns/1ps

module CLK_test();

  reg clk_in;
  reg halt;
  wire clk1;
  wire clk2;

  initial begin 
    forever begin
    clk_in = 0;
    #10 clk_in = ~clk_in;
  end end

  initial begin
    halt = 0;
    #50;

  end


endmodule