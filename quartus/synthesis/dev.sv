module dev (

    //////////// CLOCK //////////
    input         CLOCK_50,
    // input CLOCK2_50,
    // input CLOCK3_50,
    // //////////// SEG7 //////////
    // output [ 0:6] HEX0,
    // output [ 0:6] HEX1,
    // output [ 0:6] HEX2,
    // output [ 6:0] HEX3,
    output [ 0:6] HEX4,
    output [ 0:6] HEX5,
    output [ 0:6] HEX6,
    output [ 0:6] HEX7,
    /////////// PUSH BUTTON ////
    input  [17:0] SW,
    /////////// LEDS //////////
    output [17:0] LEDR,
    output [ 8:0] LEDG,
    //////////// Flash //////////
    // output [22:0] FL_ADDR,
    // output        FL_CE_N,
    // inout  [ 7:0] FL_DQ,
    // output        FL_OE_N,
    // output        FL_RST_N,
    // input         FL_RY,
    // output        FL_WE_N,
    // output        FL_WP_N,
    //////////// LCD //////////
    output        LCD_BLON,
    output [ 7:0] LCD_DATA,
    output        LCD_EN,
    output        LCD_ON,
    output        LCD_RS,
    output        LCD_RW
);

  logic reset, read_write;
  logic [7:0] cpu_data_in, cpu_data_out;
  logic [15:0] address_out;

  assign reset   = SW[0];
  assign LEDG[0] = reset;
  assign LEDG[1] = clk;

  hex_display hex_display_a (
      .value       (port_a),
      .hex_ones    (HEX6),
      .hex_sixteens(HEX7),
  );

  hex_display hex_display_b (
      .value       (port_b),
      .hex_ones    (HEX4),
      .hex_sixteens(HEX5),
  );


  clock clock (
      .clk_in (CLOCK_50),
      .clk_out(clk),
  );

  cpu6502 cpu6502 (
      .reset      (reset),
      .clk_in     (clk),
      .READ_write (read_write),
      .data_in    (cpu_data_in),
      .data_out   (cpu_data_out),
      .address_out(address_out)
  );

  memory #(
      .init_file("synthesis/ram_init.mif"),
      .depth(9)
  ) ram (
      .address    (address_out),
      .data_in    (cpu_data_out),
      .data_out   (cpu_data_in),
      .wrt_en     (read_write),
      .clk        (clk),
      .chip_select(1'b1),
  );


  //   logic [7:0] port_a_in, port_b_in;
  //   logic [7:0] port_a_out, port_b_out;

  //   interface_adapter interface_adapter (
  //       .port_a_in      (port_a_in),
  //       .port_a_out     (port_a_out),
  //       .port_b_in      (port_b_in),
  //       .port_b_out     (port_b_out),
  //       .data_in        (cpu_data_out),
  //       .data_out       (cpu_data_in),
  //       .register_select(address_out[0:3]),
  //       .chip_en1       (chip_en1),
  //       .clk            (clk),
  //       .reset          (reset),
  //       .readb_write    (readb_write)
  //   );

  logic [7:0] port_a;
  logic [7:0] port_b;
  always_ff @(posedge clk) begin : blockName
    if (read_write) begin
      if (address_out == 16'hffff) begin
        port_a <= cpu_data_out;
      end else if (address_out == 16'hfffe) begin
        port_b <= cpu_data_out;
      end
    end
  end

  assign LEDR = SW[1] ? {address_out, 2'b0} : {port_a, 2'b0, port_b};

  assign LCD_EN = port_a[7];
  assign LCD_RW = port_a[6];
  assign LCD_RS = port_a[5];
  assign LCD_ON = 1'b1;
  assign LCD_BLON = 1'b0;
  assign LCD_DATA = port_b;


endmodule
