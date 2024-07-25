module status_register (
    input wire load,
    input wire clk,
    input wire reset,

    input wire carry_in,
    input wire zero_in,
    input wire negative_in,
    input wire overflow_in,

    output logic flag_carry,
    output logic flag_zero,
    output logic flag_negative,
    output logic flag_overflow
);


  always_ff @(posedge clk) begin
    if (reset) begin
      flag_carry <= 0;
      flag_zero <= 0;
      flag_negative <= 0;
      flag_overflow <= 0;
    end else if (load) begin
      flag_carry <= carry_in;
      flag_zero <= zero_in;
      flag_negative <= negative_in;
      flag_carry <= carry_in;
    end else begin
      flag_carry <= flag_carry;
      flag_zero <= flag_zero;
      flag_negative <= flag_negative;
      flag_carry <= flag_carry;
    end
  end

endmodule
