module register_test ();
  logic clk;
  initial clk = 1;
  always #10 clk = ~clk;

  logic [7:0] data_in, data_out;
  logic load, reset;

  register register (
      .data_in (data_in),
      .data_out(data_out),
      .clk     (clk),
      .load    (load),
      .reset   (reset)
  );

  initial begin
    reset = 1;
    load = 0;
    data_in = 8'hea;
    repeat (1) @(posedge clk);
    reset = 0;
    load  = 1;
    repeat (1) @(posedge clk);
    load = 0;
    repeat (2) @(posedge clk);

    $stop;
  end

endmodule
