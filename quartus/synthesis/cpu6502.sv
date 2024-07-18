module cpu6502 (
    input logic reset,
    input logic clk_in,
    output logic READ_write,
    input logic [7:0] data_in,
    output logic [7:0] data_out,
    output logic [15:0] address_out
);


  typedef enum logic [31:0] {
    InstructionFetch,
    InstructionDecode,
    InstructionCycle2,
    InstructionCycle3,
    InstructionCycle4,
    InstructionCycle5,
    InstructionCycle6,

    InstructionStateEndMarker
  } instruction_state_t;

  // ---------------------------------------------------------
  // ------------------ CONTROL SIGNALS ----------------------
  // ---------------------------------------------------------
  logic ctrl_signals[control_signals::CtrlSignalEndMarker];
  instruction_state_t current_instr_state, next_instr_state;
  logic [7:0] current_instr;

  control_signals::alu_op_t alu_op;

  logic [7:0] data_in_latch;

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

  // ALU + registers
  logic [7:0] alu_input_a, alu_input_b;
  logic alu_overflow, alu_zero, alu_negative, alu_carry;
  register InputA (
      .data_in(data_bus),
      .data_out(alu_input_a),
      .clk(clk_in),
      .load(ctrl_signals[control_signals::CtrlLoadInputA]),
      .reset(reset)
  );
  register InputB (
      .data_in(data_bus),
      .data_out(alu_input_b),
      .clk(clk_in),
      .load(ctrl_signals[control_signals::CtrlLoadInputB]),
      .reset(reset)
  );

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
      .inc_enable(ctrl_signals[control_signals::CtrlPcIncEnable]),
      .load(ctrl_signals[control_signals::CtrlPcLoad]),
      .reset(reset),
      .PCL_out(address_low_bus_inputs[bus_sources::AddressLowSrcPcLow]),
      .PCH_out(address_high_bus_inputs[bus_sources::AddressHighSrcPcHigh])
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

  // --------------------------------------------------------
  // ------------------ CONTROL LOGIC -----------------------
  // --------------------------------------------------------

  always_ff @(posedge clk_in) begin
    data_in_latch <= data_in;
    if (reset) begin
      current_instr_state <= InstructionFetch;
    end else begin
      current_instr_state <= next_instr_state;
    end
  end

  always_comb begin
    ctrl_signals[control_signals::CtrlLoadAccumutator] = 0;
    ctrl_signals[control_signals::CtrlLoadX] = 0;
    ctrl_signals[control_signals::CtrlLoadY] = 0;
    ctrl_signals[control_signals::CtrlLoadInputA] = 0;
    ctrl_signals[control_signals::CtrlLoadInputB] = 0;
    ctrl_signals[control_signals::CtrlPcLoad] = 0;
    ctrl_signals[control_signals::CtrlLoadInstReg] = 0;
    ctrl_signals[control_signals::CtrlPcIncEnable] = 0;

    alu_op = control_signals::ALU_ADD;

    READ_write = 1;

    next_instr_state = current_instr_state;
    current_data_bus_input = bus_sources::DataBusSrcDataIn;
    current_address_low_bus_input = bus_sources::AddressLowSrcPcLow;
    current_address_high_bus_input = bus_sources::AddressHighSrcPcHigh;

    case (current_instr_state)
      InstructionFetch: begin
        next_instr_state = InstructionDecode;
        ctrl_signals[control_signals::CtrlLoadInstReg] = 1;
        ctrl_signals[control_signals::CtrlPcIncEnable] = 1;
      end
      InstructionDecode: begin
        ctrl_signals[control_signals::CtrlPcIncEnable] = 1;
        case (instruction_register)
          instruction_set::OpcNOP: begin
            next_instr_state = InstructionFetch;
          end
          instruction_set::OpcLDA_imm: begin
            next_instr_state = InstructionFetch;
            ctrl_signals[control_signals::CtrlLoadAccumutator] = 1;
          end
          instruction_set::OpcADC_imm: begin
            next_instr_state = InstructionCycle2;
            ctrl_signals[control_signals::CtrlLoadInputA] = 1;
          end
        endcase
      end
      InstructionCycle2: begin
        case (instruction_register)
          instruction_set::OpcADC_imm: begin
            next_instr_state = InstructionCycle3;
            current_data_bus_input = bus_sources::DataBusSrcRegAccumulator;
            ctrl_signals[control_signals::CtrlLoadInputB] = 1;
          end
        endcase
      end
      InstructionCycle3: begin
        case (instruction_register)
          instruction_set::OpcADC_imm: begin
            next_instr_state = InstructionCycle4;
            current_data_bus_input = bus_sources::DataBusSrcRegAccumulator;
            ctrl_signals[control_signals::CtrlLoadInputB] = 1;
          end
        endcase
      end
      InstructionCycle4: begin
        next_instr_state = InstructionFetch;
        current_data_bus_input = bus_sources::DataBusSrcRegAluResult;
        ctrl_signals[control_signals::CtrlLoadAccumutator] = 1;
      end
    endcase
  end


endmodule
