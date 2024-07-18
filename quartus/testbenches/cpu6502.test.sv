module cpu6502_test ();
  logic clk;
  initial clk = 1;
  always #10 clk = ~clk;

  logic reset;
  logic READ_write;
  logic [7:0] data_in, data_out;
  logic [15:0] address_out;

  cpu6502 cpu6502 (
      .reset      (reset),
      .clk_in     (clk),
      .READ_write (READ_write),
      .data_in    (data_in),
      .data_out   (data_out),
      .address_out(address_out)
  );

  initial begin
    reset   = 1;
    data_in = instruction_set::OpcNOP;
    repeat (1) @(posedge clk);
    reset = 0;
    repeat (1) @(posedge clk);
    data_in = instruction_set::OpcLDA_imm;
    repeat (2) @(posedge clk);
    data_in = 8'h20;
    repeat (1) @(posedge clk);
    data_in = instruction_set::OpcADC_imm;
    repeat (1) @(posedge clk);
    data_in = 8'h5;
    repeat (10) @(posedge clk);

    $stop;
  end

endmodule
