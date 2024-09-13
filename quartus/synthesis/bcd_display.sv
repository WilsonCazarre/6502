/*
  Binary into BCD conversion using the Double Dabble algorithm
*/
module bcd_display (
    input  [7:0] value,
    output [6:0] hex_ones,
    output [6:0] hex_tens,
    output [6:0] hex_hundreds
);
  logic [11:0] bcd;

  logic [3:0] ones, tens, hundreds;
  assign ones = bcd[11:8];
  assign tens = bcd[7:4];
  assign hundreds = bcd[3:0];
  reg [3:0] i;

  //Always block - implement the Double Dabble algorithm
  always @(value) begin
    bcd = 0;  //initialize bcd to zero.
    for (
        i = 0; i < 8; i = i + 1
    )  //run for 8 iterations
        begin
      bcd = {bcd[10:0], value[7-i]};  //concatenation

      // if a hex digit of 'bcd' is more than 4, add 3 to it.  
      if (i < 7 && bcd[3:0] > 4) bcd[3:0] = bcd[3:0] + 3;
      if (i < 7 && bcd[7:4] > 4) bcd[7:4] = bcd[7:4] + 3;
      if (i < 7 && bcd[11:8] > 4) bcd[11:8] = bcd[11:8] + 3;
    end
  end


  bcd_decoder ones_decoder (
      .value(ones),
      .bcd  (hex_ones)
  );

  bcd_decoder tens_decoder (
      .value(tens),
      .bcd  (hex_tens)
  );

  bcd_decoder hundreds_decoder (
      .value(hundreds),
      .bcd  (hex_hundreds)
  );


endmodule
