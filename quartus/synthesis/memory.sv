module memory (
    input  logic [15:0] address,
    input  logic [ 7:0] data_in,
    output logic [ 7:0] data_out,

    input wrt_en,
    input clk,
    input reset
);
  logic [7:0] ram[2**8];

  initial begin
    $readmemh("mem.hex", ram);
  end

  assign data_out = ram[address];

  always_ff @(posedge clk) begin
    if (wrt_en) begin
      ram[address] <= data_in;
    end
  end
endmodule
