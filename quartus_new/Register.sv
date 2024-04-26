module Register (
  input wire[7:0] data_in,
  output wire[7:0] data_out,
  
  input wire clk,
  input wire load,
  input wire reset
);

reg[7:0] current_value;

always @(posedge clk or posedge reset) begin
  if (reset == 1) begin
    current_value <= 8'b0;
  end
  else if (load == 1) begin
    current_value <= data_in;
  end
end

assign data_out = current_value;

endmodule