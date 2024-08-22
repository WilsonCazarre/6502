module async_ram #(
    depth = 8
) (
    input  logic [11:0] address,
    input  logic [ 7:0] data_in,
    output logic [ 7:0] data_out,

    input wrt_en,
    input out_en,
    input chip_en
);

  logic [7:0] ram[2**depth];

  always @(wrt_en, address, data_in, chip_en, out_en) begin
    if (chip_en) begin
      if (wrt_en) begin
        ram[address] <= data_in;
      end
      if (out_en) begin
        data_out <= ram[address];
      end
    end
  end
endmodule
