typedef enum logic [1:0] {
  DataRegister,
  StatusRegister,
  CommandRegister,
  CtrlRegister
} register_t;

typedef enum logic [7:0] {
  SBR0,
  SBR1,
  SBR2,
  SBR3,
  RSC,
  WL0,
  WL1,
  SBN
} ctrl_register_t;

typedef enum logic [7:0] {
  PE,
  FE,
  OVRN,
  RDRF,
  TDRE,
  DCDB,
  DSRB,
  IRQ

} status_register_t;

typedef enum logic [7:0] {
  DTR,
  IRD,
  TIC0,
  TIC1,
  REM,
  PME,
  PMC0,
  PMC1
} cmd_register_t;

module acia6551 (
    input  logic rxd,
    output logic txd,
    input  logic clk,
    input  logic reset,
    input  logic read_writeb,
    input  logic chip_en,

    input register_t register_select,

    input  logic [7:0] data_in,
    output logic [7:0] data_out,

    output logic irqb,

    // Crystal Pins for transmit clock
    input  logic xtli,
    output logic xtlo
);

  logic [7:0] registers[CtrlRegister+1];

  logic [8:0] tx_data_register, tx_shift_register;

  baud_rates::baud_rate_t baud_rate_select;
  assign baud_rate_select = baud_rates::Br9600;

  tx_clk_gen u_tx_clk_gen (
      .baud_rate_select(baud_rate_select),
      .reset           (reset),
      .xtli            (xtli),
      .tx_clk          (xtlo)
  );

  always_ff @(posedge clk) begin
    if (reset || (~read_writeb && register_select == StatusRegister)) begin
      registers <= '{default: '0};
      tx_data_register <= 8'b1;
    end else if (~chip_en) begin
      data_out <= 8'hz;
    end
    if (read_writeb) begin
      data_out <= registers[register_select];
    end else begin
      if (register_select == DataRegister && ~registers[StatusRegister][TDRE]) begin
        tx_data_register <= {data_in, 1'b1};
        registers[StatusRegister][TDRE] = 1;
      end else begin
        registers[register_select] <= data_in;
      end
    end
  end

  always_ff @(posedge xtlo) begin
    tx_data_register <= (tx_data_register << 1) + 1;
  end

  assign txd = tx_data_register[8];

endmodule
