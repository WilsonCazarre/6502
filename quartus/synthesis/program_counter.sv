module program_counter (
    input wire [7:0] PCL_in,
    input wire [7:0] PCH_in,

    input wire clk,
    input wire inc_enable,
    input wire load,
    input wire reset,

    output wire [7:0] PCL_out,
    output wire [7:0] PCH_out

);

  reg [15:0] current_pc;

  assign PCL_out = current_pc[7:0];
  assign PCH_out = current_pc[15:8];

  always @(posedge clk) begin

    if (reset) begin
      current_pc <= 0;
    end else if (load) begin
      current_pc <= {PCH_in, PCL_in};
    end else begin
      if (inc_enable) begin
        current_pc <= current_pc + 1'b1;
      end else begin
        current_pc <= current_pc;
      end
    end
  end

endmodule
