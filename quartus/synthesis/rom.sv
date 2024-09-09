module rom #(
    parameter init_file = "synthesis/rom_init.mif",
    depth = 15
) (
    input clk,
    input logic [14:0] address,
    output logic [7:0] data_out
);
  // (* ram_init_file = init_file *) logic [7:0] ram[2**depth];

  logic [7:0] rom[2**depth];
  initial begin
    $readmemh(init_file, rom);
  end
  // assign data_out = rom[address];
  always_ff @(posedge clk) begin
    data_out <= rom[address];
  end
endmodule
