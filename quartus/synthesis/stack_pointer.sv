module stack_pointer (
    input  logic [7:0] data_in,
    output logic [7:0] data_out,

    input logic clk,
    input logic reset,
    input logic inc,
    input logic dec,
    input logic load
);

  always_ff @(posedge clk) begin
    if (reset) begin
      data_out <= 8'hff;
    end else if (load) begin
      data_out <= data_in;
    end else if (inc) begin
      data_out <= data_out + 1;
    end else if (dec) begin
      data_out <= data_out - 1;
    end else begin
      data_out <= data_out;
    end
  end

endmodule
