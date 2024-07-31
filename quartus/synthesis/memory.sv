module memory #(
    parameter init_file = "synthesis/memory_init.mif",
    depth = 8
) (
    input  logic [15:0] address,
    input  logic [ 7:0] data_in,
    output logic [ 7:0] data_out,

    input chip_select,
    input wrt_en,
    input clk
);
  (* ram_init_file = init_file *) logic [7:0] ram[2**depth];

  // initial begin
  //   $readmemh(init_file, ram);
  // end

  assign data_out = ram[address];

  always_ff @(posedge clk) begin
    if (wrt_en) begin
      ram[address] <= data_in;
    end
  end
endmodule
