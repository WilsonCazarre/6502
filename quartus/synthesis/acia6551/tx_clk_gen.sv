module tx_clk_gen (
    input logic [3:0] baud_rate_select,
    input logic reset,
    input logic xtli,
    output logic tx_clk
);
  logic [15:0] counter, divider;

  logic [15:0] baud_rate_dividers[baud_rates::Br19200+1];

  assign baud_rate_dividers[baud_rates::Br115200] = 1;
  assign baud_rate_dividers[baud_rates::Br50] = 1;
  assign baud_rate_dividers[baud_rates::Br75] = 1;
  assign baud_rate_dividers[baud_rates::Br109_92] = 1;
  assign baud_rate_dividers[baud_rates::Br134_51] = 1;
  assign baud_rate_dividers[baud_rates::Br150] = 1;
  assign baud_rate_dividers[baud_rates::Br300] = 1;
  assign baud_rate_dividers[baud_rates::Br600] = 1;
  assign baud_rate_dividers[baud_rates::Br1200] = 1;
  assign baud_rate_dividers[baud_rates::Br1800] = 1;
  assign baud_rate_dividers[baud_rates::Br2400] = 1;
  assign baud_rate_dividers[baud_rates::Br3600] = 1;
  assign baud_rate_dividers[baud_rates::Br4800] = 1;
  assign baud_rate_dividers[baud_rates::Br7200] = 1;
  // assign baud_rate_dividers[baud_rates::Br9600] = 5208;
  assign baud_rate_dividers[baud_rates::Br9600] = 10;
  assign baud_rate_dividers[baud_rates::Br19200] = 1;

  assign divider = baud_rate_dividers[baud_rate_select];

  always_ff @(posedge xtli) begin
    if (reset) begin
      counter <= 0;
      tx_clk  <= 0;
    end else begin
      if (counter >= divider) begin
        tx_clk  <= ~tx_clk;
        counter <= 0;
      end else begin
        counter <= counter + 1;
      end
    end

  end
endmodule
