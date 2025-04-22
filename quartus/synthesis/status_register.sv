module status_register (
    input logic [7:0] data_in,

    input wire update_carry,
    input wire update_zero,
    input wire update_negative,
    input wire update_overflow,

    input wire set_carry,
    input wire clear_carry,
    input wire set_overflow,
    input wire clear_overflow,
    input wire set_interrupt_disable,
    input wire clear_interrupt_disable,

    input wire clk,
    input wire reset,

    input wire carry_in,
    input wire overflow_in,

    output logic flag_carry,
    output logic flag_zero,
    output logic flag_negative,
    output logic flag_overflow,
    output logic flag_interrupt_disable
);

  always_ff @(posedge clk) begin
    if (reset) begin
      flag_carry <= 0;
      flag_zero <= 0;
      flag_negative <= 0;
      flag_overflow <= 0;
      flag_interrupt_disable <= 0;
    end else begin
      if (set_carry) begin
        flag_carry <= 1;
      end else if (clear_carry) begin
        flag_carry <= 0;
      end else if (update_carry) begin
        flag_carry <= carry_in;
      end else begin
        flag_carry <= flag_carry;
      end

      if (set_overflow) begin
        flag_overflow <= 1;
      end else if (clear_overflow) begin
        flag_overflow <= 0;
      end else if (update_overflow) begin
        flag_overflow <= overflow_in;
      end else begin
        flag_overflow <= flag_overflow;
      end


      if (set_interrupt_disable) begin
        flag_interrupt_disable <= 1;
      end else if (clear_interrupt_disable) begin
        flag_interrupt_disable <= 0;
      end else begin
        flag_interrupt_disable <= flag_interrupt_disable;
      end
      flag_zero <= update_zero ? ~|data_in : flag_zero;
      flag_negative <= update_negative ? data_in[7] : flag_negative;


    end
  end

endmodule
