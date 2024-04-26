module CLK(
  input wire clk_in,
  input wire halt,
  output reg clk1,
  output reg clk2
);


always @(posedge clk_in) begin
  if (halt == 1) begin
    clk1 <= 0;
    clk2 <= 0;
  end else begin
    clk1 <= clk_in;
    clk2 <= ~clk_in;
  end
end


endmodule