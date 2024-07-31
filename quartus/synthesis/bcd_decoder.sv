module bcd_decoder (
    input [3:0] value,
    output logic [6:0] bcd
);
  always_comb begin
    case (value)
      8'h0: bcd = 7'b0000001;
      8'h1: bcd = 7'b1001111;
      8'h2: bcd = 7'b0010010;
      8'h3: bcd = 7'b0000110;
      8'h4: bcd = 7'b1001100;
      8'h5: bcd = 7'b0100100;
      8'h6: bcd = 7'b0100000;
      8'h7: bcd = 7'b0001111;
      8'h8: bcd = 7'b0000000;
      8'h9: bcd = 7'b0000100;
      8'ha: bcd = 7'b0001000;
      8'hb: bcd = 7'b1100000;
      8'hc: bcd = 7'b0110001;
      8'hd: bcd = 7'b1000010;
      8'he: bcd = 7'b0110000;
      8'hf: bcd = 7'b0111000;
      default: bcd = 7'bxxxxxxx;
    endcase
  end
endmodule


