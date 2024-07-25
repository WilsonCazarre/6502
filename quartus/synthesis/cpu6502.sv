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
  assign address_low_bus = address_low_bus_inputs[current_address_low_bus_input];
  assign address_high_bus = address_high_bus_inputs[current_address_high_bus_input];
  assign address_out = {
    address_high_bus_inputs[current_address_high_bus_input],
    address_low_bus_inputs[current_address_low_bus_input]
  };
  assign data_bus_inputs[bus_sources::DataBusSrcDataIn] = data_in;
  assign data_bus_inputs[bus_sources::DataBusSrcDataInLatch] = data_in_latch;
  assign data_bus_inputs[bus_sources::DataBusSrcFF] = 8'hff;

  // ---------------------------------------------------------------
  // ------------------ Datapath Components ------------------------
  // ---------------------------------------------------------------

  // GPR registers
  register RegAccumulator (
      .data_in(data_bus),
      .data_out(data_bus_inputs[bus_sources::DataBusSrcRegAccumulator]),
      .clk(clk_in),
      .load(ctrl_signals[control_signals::CtrlLoadAccumutator]),
      .reset(reset)
  );
  register RegX (
      .data_in(data_bus),
      .data_out(data_bus_inputs[bus_sources::DataBusSrcRegX]),
      .clk(clk_in),
      .load(ctrl_signals[control_signals::CtrlLoadX]),
      .reset(reset)
  );
  register RegY (
      .data_in(data_bus),
      .data_out(data_bus_inputs[bus_sources::DataBusSrcRegY]),
      .clk(clk_in),
      .load(ctrl_signals[control_signals::CtrlLoadY]),
      .reset(reset)
  );

  register AddressLowReg (
      .data_in(data_bus),
      .data_out(address_low_bus_inputs[bus_sources::AddressLowSrcAddrLowReg]),
      .clk(clk_in),
      .load(ctrl_signals[control_signals::CtrlLoadAddrLow]),
      .reset(reset)
  );
  register AddressHighReg (
      .data_in(data_bus),
      .data_out(address_high_bus_inputs[bus_sources::AddressHighSrcAddrHighReg]),
      .clk(clk_in),
      .load(ctrl_signals[control_signals::CtrlLoadAddrHigh]),
      .reset(reset)
  );

  // ALU + registers
  logic [7:0] alu_input_a, alu_input_b;
  logic alu_overflow, alu_zero, alu_negative, alu_carry;
  register InputB (
      .data_in(data_bus),
      .data_out(alu_input_b),
      .clk(clk_in),
      .load(ctrl_signals[control_signals::CtrlLoadInputB]),
      .reset(reset)
  );

  assign alu_input_a = data_bus_inputs[bus_sources::DataBusSrcRegAccumulator];
  alu alu (
      .carry_in(1'b0),
      .input_a(alu_input_a),
      .input_b(alu_input_b),
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
  logic status_flags[8];
  logic flag_carry, flag_zero, flag_negative, flag_overflow;
  assign status_flags[control_signals::StatusFlagCarry] = flag_carry;
  assign status_flags[control_signals::StatusFlagOverflow] = flag_zero;
  assign status_flags[control_signals::StatusFlagNegative] = flag_negative;
  assign status_flags[control_signals::StatusFlagZero] = flag_overflow;
  status_register status_register (
      .load         (ctrl_signals[control_signals::CtrlLoadStatusReg]),
      .clk          (clk_in),
      .reset        (reset),
      .carry_in     (alu_carry),
      .zero_in      (alu_zero),
      .negative_in  (alu_negative),
      .overflow_in  (alu_overflow),
      .flag_carry   (flag_carry),
      .flag_zero    (flag_zero),
      .flag_negative(flag_negative),
      .flag_overflow(flag_overflow)
  );

  // Instruction Register
  instruction_set::opcode_t instruction_register;
  register InstructionRegister (
      .data_in(data_bus),
      // Expliciting telling to pass every bit to cast the enum reg into a reg
      .data_out(instruction_register[7:0]),
      .clk(clk_in),
      .load(ctrl_signals[control_signals::CtrlLoadInstReg]),
      .reset(reset)
  );

  control_unit control_unit (
      .status_flags                  (status_flags),
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
