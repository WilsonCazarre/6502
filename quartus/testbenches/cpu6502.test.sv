module cpu6502_test ();
  logic clk;
  initial clk = 1;
  always #10 clk = ~clk;

  logic reset;
  logic READ_write;
  logic [7:0] data_in_cpu, data_out_cpu;
  logic [15:0] address_out;

  cpu6502 cpu6502 (
      .reset      (reset),
      .clk_in     (clk),
      .READ_write (READ_write),
      .data_in    (data_in_cpu),
      .data_out   (data_out_cpu),
      .address_out(address_out)
  );

  memory ram (
      .address (address_out),
      .data_in (data_out_cpu),
      .data_out(data_in_cpu),
      .wrt_en  (READ_write),
      .clk     (clk),
      .reset   (reset)
  );


  initial begin
    reset = 1;

    repeat (1) @(posedge clk);
    reset = 0;
    repeat (20) @(posedge clk);
    $stop;
  end

endmodule
