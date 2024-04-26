`timescale 1ns/1ps

module ProgramCounter_test(
);

  reg[7:0] PCL_in;
  reg[7:0] PCH_in;
  reg clk;
  reg inc_enable;
  reg load;
  reg reset;

  wire[7:0] PCL_out;
  wire[7:0] PCH_out;

  ProgramCounter pc (
    .PCL_in(PCL_in),
    .PCH_in(PCH_in),
    .clk(clk),
    .inc_enable(inc_enable),
    .load(load),
    .reset(reset),
    .PCL_out(PCL_out),
    .PCH_out(PCH_out)
);

  initial clk = 0;

  always #10 clk=~clk;

  initial begin
    inc_enable=1'b1;
    load=1'b0;
    reset=1;
    PCL_in=8'h3f;
    PCH_in=8'hfe;
    #10;
    reset=0;
    
    #500;
    inc_enable=0;
    load=1;
    #10;
    inc_enable=1;
    load=0;

  end
endmodule