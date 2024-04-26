module cpu6502 (
  input wire reset, 
  input wire clk_in,
  input wire[7:0] data_bus_in,
  output wire[7:0] data_bus_out
);

  Register acc (
      .data_in(data_bus_in),
      .data_out(),
      .clk(),
      .load(),
      .reset(reset)
  );

  Register index_x (
      .data_in(data_bus_in),
      .data_out(),
      .clk(),
      .load(),
      .reset(reset)
  );

  Register index_y (
      .data_in(data_bus_in),
      .data_out(),
      .clk(),
      .load(),
      .reset(reset)
  );



endmodule