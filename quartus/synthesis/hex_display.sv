module hex_display (
    input  [7:0] value,
    output [6:0] hex_ones,
    output [6:0] hex_sixteens
);
  logic [3:0] ones, sixteens;
  assign ones = value[3:0];
  assign sixteens = value[7:4];

  bcd_decoder ones_decoder (
      .value(ones),
      .bcd  (hex_ones)
  );

  bcd_decoder sixteens_decoder (
      .value(sixteens),
      .bcd  (hex_sixteens)
  );


endmodule
