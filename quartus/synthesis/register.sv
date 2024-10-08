module register (
    input  logic [7:0] data_in,
    output logic [7:0] data_out,

    input logic clk,
    input logic load,
    input logic reset,
    input logic inc,
    input logic dec
);
  reg [7:0] current_value;

  always @(posedge clk) begin
    if (reset) begin
      current_value <= 8'b0;
    end else if (load) begin
      current_value <= data_in;
    end else if (inc) begin
      current_value <= current_value + 1;
    end else if (dec) begin
      current_value <= current_value - 1;
    end else begin
      current_value <= current_value;
    end
  end

  assign data_out = current_value;

endmodule
