module dev (

    //////////// CLOCK //////////
    input         CLOCK_50,
    // input CLOCK2_50,
    // input CLOCK3_50,
    // //////////// SEG7 //////////
    output [ 0:6] HEX0,
    output [ 0:6] HEX1,
    output [ 0:6] HEX2,
    output [ 6:0] HEX3,
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
    // output        LCD_BLON,
    // output [ 7:0] LCD_DATA,
    // output        LCD_EN,
    // output        LCD_ON,
    // output        LCD_RS,
    // output        LCD_RW,

    //////////// SRAM //////////
    output [19:0] SRAM_ADDR,
    output        SRAM_CE_N,
    inout  [15:0] SRAM_DQ,
    output        SRAM_LB_N,
    output        SRAM_OE_N,
    output        SRAM_UB_N,
    output        SRAM_WE_N
);
  logic clk;
  logic reset, read_write;
  logic [7:0] data_in_cpu, data_out_cpu;
  logic [15:0] address_out;

  assign reset   = SW[0];
  assign LEDG[0] = reset;
  assign LEDG[1] = clk;

  hex_display hex_display_a (
      .value       (port_a_out),
      .hex_ones    (HEX4),
      .hex_sixteens(HEX5),
  );

  hex_display hex_display_b (
      .value       (port_b_out),
      .hex_ones    (HEX6),
      .hex_sixteens(HEX7),
  );

  bcd_display bcd_display (
      .value       (port_a_out),
      .hex_ones    (HEX2),
      .hex_tens    (HEX1),
      .hex_hundreds(HEX0)
  );

  logic clk_div;

  clock u_clock (
      .clk_in (CLOCK_50),
      .clk_out(clk_div)
  );

  assign clk = SW[2] ? CLOCK_50 : clk_div;

  cpu6502 cpu6502 (
      .reset      (reset),
      .clk_in     (clk),
      .READ_write (read_write),
      .data_in    (data_in_cpu),
      .data_out   (data_out_cpu),
      .address_out(address_out)
  );

  logic [7:0] ram_out;
  logic ram_cs;
  assign ram_cs = address_out < 16'h800;

  // async_ram ram (
  //     .address (address_out[11:0]),
  //     .data_in (data_out_cpu),
  //     .data_out(ram_out),
  //     .wrt_en  (read_write),
  //     .out_en  (~read_write),
  //     .chip_en (ram_cs && clk)
  // );

  assign ram_out = read_write ? 8'bz : SRAM_DQ[7:0];
  assign SRAM_DQ = read_write ? {8'b0, data_out_cpu} : 16'bz;
  assign SRAM_ADDR = {8'b0, address_out[11:0]};
  assign SRAM_CE_N = ~ram_cs;
  assign SRAM_LB_N = 0;
  assign SRAM_UB_N = 0;
  assign SRAM_WE_N = ~read_write;
  assign SRAM_OE_N = read_write;

  logic [7:0] rom_out;
  logic rom_cs;
  assign rom_cs = address_out >= 16'h8000;
  rom #(
      .init_file("simulation/rom.hex"),
      .depth(15)
  ) prg_rom (
      .address (address_out[14:0]),
      .data_out(rom_out),
      .clk     (~clk)
  );

  logic [7:0] port_a_in, port_a_out, port_b_in, port_b_out;
  logic [7:0] interface_adapter_out;
  logic interface_adapter_cs;
  assign port_b_in = SW[17:9];
  assign interface_adapter_cs = address_out >= 16'h800 && address_out < 16'h810;
  interface_adapter interface_adapter (
      .port_a_in      (port_a_in),
      .port_a_out     (port_a_out),
      .port_b_in      (port_b_in),
      .port_b_out     (port_b_out),
      .data_in        (data_out_cpu),
      .data_out       (interface_adapter_out),
      .register_select(address_out[3:0]),
      .chip_en        (interface_adapter_cs),
      .clk            (clk),
      .reset          (reset)
  );

  always_comb begin
    data_in_cpu = 8'bz;
    if (interface_adapter_cs) begin
      data_in_cpu = interface_adapter_out;
    end else if (rom_cs) begin
      data_in_cpu = rom_out;
    end else if (ram_cs) begin
      data_in_cpu = ram_out;
    end
  end

  assign LEDR = ~SW[1] ? {address_out, 2'b0} : {port_a_out, 2'b0, port_b_out};

  assign HEX3 = 7'hff;
  // assign LCD_EN = port_a_out[7];
  // assign LCD_RW = port_a_out[6];
  // assign LCD_RS = port_a_out[5];
  // assign LCD_ON = 1'b1;
  // assign LCD_BLON = SW[2];
  // assign LCD_DATA = port_b;


endmodule
