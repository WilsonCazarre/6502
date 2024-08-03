module cpu6502 (
    input logic reset,
    input logic clk_in,
    output logic READ_write,
    input logic [7:0] data_in,
    output logic [7:0] data_out,
    output logic [15:0] address_out
);

  // ---------------------------------------------------------
  // ------------------ CONTROL SIGNALS ----------------------
  // ---------------------------------------------------------
  logic ctrl_signals[control_signals::CtrlSignalEndMarker];

  control_signals::alu_op_t alu_op;

  logic [7:0] data_in_latch;

  assign READ_write = ctrl_signals[control_signals::CtrlRead0Write1];

  // ---------------------------------------------------------------
  // ------------------ Data and Address Buses ---------------------
  // ---------------------------------------------------------------

  bus_sources::data_bus_source_t current_data_bus_input;
  bus_sources::address_low_bus_source_t current_address_low_bus_input;
  bus_sources::address_high_bus_source_t current_address_high_bus_input;

  logic [7:0] data_bus, address_low_bus, address_high_bus;
  logic [7:0] data_bus_inputs[bus_sources::DataBusSrcEndMarker];
  logic [7:0] address_low_bus_inputs[bus_sources::AddressLowSrcEndMarker];
  logic [7:0] address_high_bus_inputs[bus_sources::AddressHighSrcEndMarker];

  assign data_bus = data_bus_inputs[current_data_bus_input];
  assign data_out = data_bus;

  assign data_bus_inputs[bus_sources::DataBusSrcDataIn] = data_in;
  assign data_bus_inputs[bus_sources::DataBusSrcDataInLatch] = data_in_latch;
  assign data_bus_inputs[bus_sources::DataBusSrcFF] = 8'hff;
  assign data_bus_inputs[bus_sources::DataBusSrcZero] = 8'h00;

  assign address_low_bus = address_low_bus_inputs[current_address_low_bus_input];
  assign address_high_bus = address_high_bus_inputs[current_address_high_bus_input];
  assign address_out = {
    address_high_bus_inputs[current_address_high_bus_input],
    address_low_bus_inputs[current_address_low_bus_input]
  };
  assign address_high_bus_inputs[bus_sources::AddressHighSrcStackPointer] = 8'h01;
  assign address_low_bus_inputs[bus_sources::AddressLowSrcZero] = 8'h00;

  assign data_bus_inputs[bus_sources::DataBusSrcAddrLowBus] = address_low_bus;
  assign data_bus_inputs[bus_sources::DataBusSrcAddrHighBus] = address_high_bus;

  assign address_low_bus_inputs[bus_sources::AddressLowSrcDataBus] = data_bus;
  assign address_high_bus_inputs[bus_sources::AddressHighSrcDataBus] = data_bus;

  // ---------------------------------------------------------------
  // ------------------ Datapath Components ------------------------
  // ---------------------------------------------------------------

  // GPR registers
  register RegAccumulator (
      .data_in(data_bus),
      .data_out(data_bus_inputs[bus_sources::DataBusSrcRegAccumulator]),
      .clk(clk_in),
      .load(ctrl_signals[control_signals::CtrlLoadAccumutator]),
      .reset(reset),
      .inc(1'b0),
      .dec(1'b0)
  );
  register RegX (
      .data_in(data_bus),
      .data_out(data_bus_inputs[bus_sources::DataBusSrcRegX]),
      .clk(clk_in),
      .load(ctrl_signals[control_signals::CtrlLoadX]),
      .reset(reset),
      .inc(1'b0),
      .dec(1'b0)
  );
  register RegY (
      .data_in(data_bus),
      .data_out(data_bus_inputs[bus_sources::DataBusSrcRegY]),
      .clk(clk_in),
      .load(ctrl_signals[control_signals::CtrlLoadY]),
      .reset(reset),
      .inc(1'b0),
      .dec(1'b0)
  );

  register AddressLowReg (
      .data_in(data_bus),
      .data_out(address_low_bus_inputs[bus_sources::AddressLowSrcAddrLowReg]),
      .clk(clk_in),
      .load(ctrl_signals[control_signals::CtrlLoadAddrLow]),
      .reset(reset),
      .inc(1'b0),
      .dec(1'b0)
  );
  register AddressHighReg (
      .data_in(data_bus),
      .data_out(address_high_bus_inputs[bus_sources::AddressHighSrcAddrHighReg]),
      .clk(clk_in),
      .load(ctrl_signals[control_signals::CtrlLoadAddrHigh]),
      .inc(ctrl_signals[control_signals::CtrlIncAddressHighReg]),
      .dec(ctrl_signals[control_signals::CtrlDecAddressHighReg]),
      .reset(reset)
  );

  stack_pointer StackPointer (
      .data_in(data_bus),
      .data_out(address_low_bus_inputs[bus_sources::AddressLowSrcStackPointer]),
      .clk(clk_in),
      .load(ctrl_signals[control_signals::CtrlLoadStackPointer]),
      .dec(ctrl_signals[control_signals::CtrlDecStackPointer]),
      .inc(ctrl_signals[control_signals::CtrlIncStackPointer]),
      .reset(reset)
  );

  // ALU + registers
  logic [7:0] alu_input_a, alu_input_b;
  logic alu_overflow, alu_zero, alu_negative, alu_carry;
  register InputA (
      .data_in(data_bus),
      .data_out(alu_input_a),
      .clk(clk_in),
      .load(ctrl_signals[control_signals::CtrlLoadInputA]),
      .reset(reset | ctrl_signals[control_signals::CtrlResetInputA]),
      .inc(1'b0),
      .dec(1'b0)
  );
  register InputB (
      .data_in(data_bus),
      .data_out(alu_input_b),
      .clk(clk_in),
      .load(ctrl_signals[control_signals::CtrlLoadInputB]),
      .reset(reset),
      .inc(1'b0),
      .dec(1'b0)
  );

  logic status_flags[8];
  logic flag_carry, flag_zero, flag_negative, flag_overflow;

  alu alu (
      .carry_in(ctrl_signals[control_signals::CtrlAluCarryIn]),
      .input_a(alu_input_a),
      .input_b(alu_input_b),
      .invert_b(ctrl_signals[control_signals::CtrlAluInvertB]),
      .operation(alu_op),
      .alu_out(data_bus_inputs[bus_sources::DataBusSrcRegAluResult]),
      .overflow_out(alu_overflow),
      .zero_out(alu_zero),
      .negative_out(alu_negative),
      .carry_out(alu_carry)
  );

  // Program Counter
  logic [15:0] program_counter;
  assign program_counter = {
    address_high_bus_inputs[bus_sources::AddressHighSrcPcHigh],
    address_low_bus_inputs[bus_sources::AddressLowSrcPcLow]
  };
  program_counter ProgramCounter (
      .PCL_in(address_low_bus),
      .PCH_in(address_high_bus),
      .clk(clk_in),
      .inc_enable(ctrl_signals[control_signals::CtrlIncEnablePc]),
      .load(ctrl_signals[control_signals::CtrlLoadPc]),
      .reset(reset),
      .PCL_out(address_low_bus_inputs[bus_sources::AddressLowSrcPcLow]),
      .PCH_out(address_high_bus_inputs[bus_sources::AddressHighSrcPcHigh])
  );

  // Status Register

  assign status_flags[control_signals::StatusFlagCarry] = flag_carry;
  assign status_flags[control_signals::StatusFlagZero] = flag_zero;
  assign status_flags[control_signals::StatusFlagNegative] = flag_negative;
  assign status_flags[control_signals::StatusFlagOverflow] = flag_overflow;
  status_register status_register (
      .data_in        (data_bus),
      .update_zero    (ctrl_signals[control_signals::CtrlUpdateFlagZero]),
      .update_negative(ctrl_signals[control_signals::CtrlUpdateFlagNegative]),
      .update_carry   (ctrl_signals[control_signals::CtrlUpdateFlagCarry]),
      .update_overflow(ctrl_signals[control_signals::CtrlUpdateFlagOverflow]),
      .set_carry      (ctrl_signals[control_signals::CtrlSetFlagCarry]),
      .set_overflow   (ctrl_signals[control_signals::CtrlSetFlagOverflow]),
      .clear_carry    (ctrl_signals[control_signals::CtrlClearFlagCarry]),
      .clear_overflow (ctrl_signals[control_signals::CtrlClearFlagOverflow]),
      .clk            (clk_in),
      .reset          (reset),
      .carry_in       (alu_carry),
      .overflow_in    (alu_overflow),
      .flag_carry     (flag_carry),
      .flag_zero      (flag_zero),
      .flag_negative  (flag_negative),
      .flag_overflow  (flag_overflow)
  );

  // Instruction Register
  instruction_set::opcode_t instruction_register;
  register InstructionRegister (
      .data_in(data_bus),
      // Expliciting telling to pass every bit to cast the enum reg into a reg
      .data_out(instruction_register[7:0]),
      .clk(clk_in),
      .load(ctrl_signals[control_signals::CtrlLoadInstReg]),
      .reset(reset),
      .inc(1'b0),
      .dec(1'b0)
  );

  control_unit control_unit (
      .status_flags                  (status_flags),
      .alu_carry                     (alu_carry),
      .data_in_latch                 (data_in_latch),
      .current_opcode                (instruction_register),
      .ctrl_signals                  (ctrl_signals),
      .alu_op                        (alu_op),
      .current_data_bus_input        (current_data_bus_input),
      .current_address_low_bus_input (current_address_low_bus_input),
      .current_address_high_bus_input(current_address_high_bus_input),
      .clk                           (clk_in),
      .reset                         (reset)
  );


  // --------------------------------------------------------
  // ------------------ CONTROL LOGIC -----------------------
  // --------------------------------------------------------

  always_ff @(posedge clk_in) begin
    data_in_latch <= data_in;
  end
endmodule
