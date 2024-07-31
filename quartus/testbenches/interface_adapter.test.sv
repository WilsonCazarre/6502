`timescale 1ns / 1ps

module interface_adapter_test ();
  typedef enum logic [3:0] {
    ORB_IRB,
    ORA_IRA,
    DDRB,
    DDRA,
    CtrlRegisterEndMarker
  } ctrl_register;

  logic clk = 1;
  always #10 clk = ~clk;

  // signals and modules declaration here
  logic [7:0] port_a_in, port_b_in, port_a_out, port_b_out;
  logic [7:0] data_in, data_out;
  logic reset;
  logic [3:0] register_select;

  logic chip_en1, chip_en2, readb_write;

  // unit under test
  interface_adapter interface_adapter (
      .port_a_in      (port_a_in),
      .port_a_out     (port_a_out),
      .port_b_in      (port_b_in),
      .port_b_out     (port_b_out),
      .data_in        (data_in),
      .data_out       (data_out),
      .register_select(register_select),
      .chip_en1       (chip_en1),
      .chip_en2b      (chip_en2b),
      .clk            (clk),
      .reset          (reset),
      .readb_write    (readb_write)
  );


  initial begin
    reset = 1;
    repeat (1) @(posedge clk);
    reset = 0;
    data_in = 8'hff;
    chip_en1 = 1;
    register_select = DDRA;
    repeat (1) @(posedge clk);

    register_select = ORA_IRA;
    data_in = 8'h21;
    repeat (1) @(posedge clk);
    data_in = 8'h22;
    repeat (1) @(posedge clk);
    register_select = DDRB;
    data_in = 8'h00;
    repeat (1) @(posedge clk);
    port_b_in = 8'hee;
    repeat (10) @(posedge clk);
    $stop;
  end
endmodule
