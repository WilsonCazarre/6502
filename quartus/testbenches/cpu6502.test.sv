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

  logic [7:0] ram_out;
  logic ram_cs;
  assign ram_cs = address_out < 16'h800;
  async_ram ram (
      .address (address_out[11:0]),
      .data_in (data_out_cpu),
      .data_out(ram_out),
      .wrt_en  (READ_write),
      .out_en  (~READ_write),
      .chip_en (ram_cs && clk)
  );

  logic [7:0] rom_out;
  logic rom_cs;
  assign rom_cs = address_out >= 16'h8000;
  rom #(
      .init_file("rom.hex"),
      .depth(10)
  ) prg_rom (
      .address (address_out[14:0]),
      .data_out(rom_out),
      .clk     (~clk)
  );

  logic [7:0] port_a_in, port_a_out, port_b_in, port_b_out;
  logic [7:0] interface_adapter_out;
  logic interface_adapter_cs;
  assign interface_adapter_cs = address_out >= 16'h800 && address_out < 16'h810;
  interface_adapter interface_adapter (
      .port_a_in      (port_a_in),
      .port_a_out     (port_a_out),
      .port_b_in      (port_b_in),
      .port_b_out     (port_b_out),
      .data_in        (data_out_cpu),
      .data_out       (interface_adapter_out),
      .register_select(address_out[3:0]),
      .chip_en        (interface_adapter_cs),
      .clk            (clk),
      .reset          (reset)
  );

  always_comb begin
    data_in_cpu = 8'bz;
    if (interface_adapter_cs) begin
      data_in_cpu = interface_adapter_out;
    end else if (rom_cs) begin
      data_in_cpu = rom_out;
    end else if (ram_cs) begin
      data_in_cpu = ram_out;
    end
  end
  initial begin
    reset = 1;

    repeat (1) @(posedge clk);
    reset = 0;
    repeat (50) @(posedge clk);
    $stop;
  end

endmodule
