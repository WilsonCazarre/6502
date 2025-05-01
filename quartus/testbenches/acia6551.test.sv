`timescale 1ns / 1ps

module acia6551_test ();
  logic clk = 1;
  always #2 clk = ~clk;

  // signals and modules declaration here
  logic rxd, txd, reset, read_writeb, chip_en, irqb, xtli, xtlo;
  logic [1:0] register_select;
  logic [7:0] data_in, data_out;

  acia6551 u_acia6551 (
      .rxd            (rxd),
      .txd            (txd),
      .clk            (clk),
      .reset          (reset),
      .read_writeb    (read_writeb),
      .chip_en        (chip_en),
      .register_select({register_select[1:0]}),
      .data_in        (data_in),
      .data_out       (data_out),
      .irqb           (irqb),
      .xtli           (clk),
      .xtlo           (xtlo)
  );


  initial begin
    // write the simulation stimulus here
    chip_en = 1;
    rxd = 0;
    reset = 1;
    read_writeb = 1;
    register_select = 0;
    repeat (5) @(posedge clk);
    reset = 0;
    register_select = 2'h0;
    data_in = 8'b0000_1110;
    read_writeb = 0;
    repeat (1) @(posedge clk);
    read_writeb = 1;
    // use this snippet to wait for 1 (or more) clk cycles
    repeat (500) @(posedge clk);

    $stop;
  end
endmodule
