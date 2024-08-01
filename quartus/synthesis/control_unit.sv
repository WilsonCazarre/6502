module control_unit (
    input logic status_flags[8],
    input logic [7:0] data_in_latch,
    input instruction_set::opcode_t current_opcode,
    input clk,
    input reset,
    input alu_carry,

    output logic ctrl_signals[control_signals::CtrlSignalEndMarker],
    output control_signals::alu_op_t alu_op,
    output bus_sources::data_bus_source_t current_data_bus_input,
    output bus_sources::address_low_bus_source_t current_address_low_bus_input,
    output bus_sources::address_high_bus_source_t current_address_high_bus_input
);
  typedef enum logic [31:0] {
    InstructionFetch,
    InstructionDecode,
    InstructionMem1,
    InstructionMem2,
    InstructionMem3,
    InstructionMem4,
    InstructionExec1,
    InstructionExec2,
    InstructionExec3,
    InstructionExec4,
    InstructionExec5,
    InstructionInvalid,
    InstructionStateEndMarker
  } instruction_state_t;

  instruction_state_t current_instr_state, next_instr_state;
  instruction_set::address_mode_t current_addr_mode, next_addr_mode;
  logic negative_data_in;

  always_ff @(posedge clk) begin
    if (reset) begin
      current_instr_state <= InstructionFetch;
    end else begin
      negative_data_in <= data_in_latch[7];
      current_instr_state <= next_instr_state;
      current_addr_mode <= next_addr_mode;
    end
  end

  always_comb begin
    ctrl_signals = '{default: '0};

    current_data_bus_input = bus_sources::DataBusSrcDataIn;
    current_address_low_bus_input = bus_sources::AddressLowSrcPcLow;
    current_address_high_bus_input = bus_sources::AddressHighSrcPcHigh;

    next_instr_state = InstructionInvalid;
    next_addr_mode = instruction_set::AddrModeImpl;
    alu_op = control_signals::ALU_ADD;

    case (current_instr_state)
      InstructionFetch: begin
        next_instr_state = InstructionDecode;
        ctrl_signals[control_signals::CtrlLoadInstReg] = 1;
        ctrl_signals[control_signals::CtrlIncEnablePc] = 1;
      end
      InstructionDecode: begin
        case (current_opcode)
          instruction_set::OpcADC_imm:  imm_addr_mode();
          instruction_set::OpcADC_abs:  abs_addr_mode();
          instruction_set::OpcADC_absx: absx_addr_mode();

          instruction_set::OpcAND_imm:  imm_addr_mode();
          instruction_set::OpcAND_abs:  abs_addr_mode();
          instruction_set::OpcAND_absx: absx_addr_mode();

          instruction_set::OpcBCC_abs: imm_addr_mode();
          instruction_set::OpcBCS_abs: imm_addr_mode();
          instruction_set::OpcBEQ_abs: imm_addr_mode();
          instruction_set::OpcBMI_abs: imm_addr_mode();
          instruction_set::OpcBNE_abs: imm_addr_mode();
          instruction_set::OpcBPL_abs: imm_addr_mode();
          instruction_set::OpcBVC_abs: imm_addr_mode();
          instruction_set::OpcBVS_abs: imm_addr_mode();

          instruction_set::OpcCLC_impl: impl_addr_mode();

          instruction_set::OpcCMP_imm:  imm_addr_mode();
          instruction_set::OpcCMP_abs:  abs_addr_mode();
          instruction_set::OpcCMP_absx: absx_addr_mode();

          instruction_set::OpcCPX_imm: imm_addr_mode();
          instruction_set::OpcCPX_abs: abs_addr_mode();

          instruction_set::OpcCPY_imm: imm_addr_mode();
          instruction_set::OpcCPY_abs: abs_addr_mode();

          instruction_set::OpcEOR_imm:  imm_addr_mode();
          instruction_set::OpcEOR_abs:  abs_addr_mode();
          instruction_set::OpcEOR_absx: absx_addr_mode();

          instruction_set::OpcINX_impl: impl_addr_mode();

          instruction_set::OpcJMP_abs: abs_addr_mode();

          instruction_set::OpcLDA_imm:  imm_addr_mode();
          instruction_set::OpcLDA_abs:  abs_addr_mode();
          instruction_set::OpcLDA_absx: absx_addr_mode();

          instruction_set::OpcLDX_imm: imm_addr_mode();
          instruction_set::OpcLDX_abs: abs_addr_mode();

          instruction_set::OpcLDY_imm:  imm_addr_mode();
          instruction_set::OpcLDY_abs:  abs_addr_mode();
          instruction_set::OpcLDY_absx: absx_addr_mode();

          instruction_set::OpcNOP_impl: next_instr_state = InstructionFetch;

          instruction_set::OpcORA_imm:  imm_addr_mode();
          instruction_set::OpcORA_abs:  abs_addr_mode();
          instruction_set::OpcORA_absx: absx_addr_mode();

          instruction_set::OpcPHA_impl: impl_addr_mode();

          instruction_set::OpcPLA_impl: impl_addr_mode();

          instruction_set::OpcSBC_imm:  imm_addr_mode();
          instruction_set::OpcSBC_abs:  abs_addr_mode();
          instruction_set::OpcSBC_absx: absx_addr_mode();

          instruction_set::OpcSEC_impl: impl_addr_mode();

          instruction_set::OpcSTA_abs:  abs_addr_mode();
          instruction_set::OpcSTA_absx: absx_addr_mode();

          instruction_set::OpcSTX_abs: abs_addr_mode();

          instruction_set::OpcSTY_abs: abs_addr_mode();

          default: next_addr_mode = instruction_set::AddrModeImpl;
        endcase
      end
      default: begin
        case (current_addr_mode)
          instruction_set::AddrModeImm: imm_addr_mode();
          instruction_set::AddrModeAbs: abs_addr_mode();
          instruction_set::AddrModeAbsX: absx_addr_mode();
          instruction_set::AddrModeImpl: impl_addr_mode();
          default: invalid_state();
        endcase
      end
    endcase
  end

  // -----------------------------------------------------
  // ---------- Address Modes System Tasks ---------------
  // -----------------------------------------------------
  task abs_addr_mode();
    next_addr_mode = instruction_set::AddrModeAbs;
    case (current_instr_state)
      InstructionDecode: begin
        next_instr_state = InstructionMem1;
        ctrl_signals[control_signals::CtrlIncEnablePc] = 1;
        ctrl_signals[control_signals::CtrlLoadAddrLow] = 1;
      end
      InstructionMem1: begin
        next_instr_state = InstructionExec1;
        ctrl_signals[control_signals::CtrlIncEnablePc] = 1;
        ctrl_signals[control_signals::CtrlLoadAddrHigh] = 1;
      end
      default: begin
        current_address_low_bus_input  = bus_sources::AddressLowSrcAddrLowReg;
        current_address_high_bus_input = bus_sources::AddressHighSrcAddrHighReg;
        opcode_exec();
      end
    endcase

  endtask

  task imm_addr_mode();
    next_addr_mode = instruction_set::AddrModeImm;
    case (current_instr_state)
      InstructionDecode: begin
        next_instr_state = InstructionExec1;
      end
      InstructionExec1: begin
        ctrl_signals[control_signals::CtrlIncEnablePc] = 1;
        opcode_exec();
      end
      default: opcode_exec();
    endcase
  endtask

  task impl_addr_mode();
    next_addr_mode = instruction_set::AddrModeImpl;
    case (current_instr_state)
      InstructionDecode: begin
        next_instr_state = InstructionExec1;
      end
      default: opcode_exec();
    endcase
  endtask

  task absx_addr_mode();
    next_addr_mode = instruction_set::AddrModeAbsX;
    case (current_instr_state)
      InstructionDecode: begin
        next_instr_state = InstructionMem1;
        current_data_bus_input = bus_sources::DataBusSrcRegX;
        ctrl_signals[control_signals::CtrlLoadInputA] = 1;
        ctrl_signals[control_signals::CtrlClearFlagCarry] = 1;
      end
      InstructionMem1: begin
        next_instr_state = InstructionMem2;

        current_data_bus_input = bus_sources::DataBusSrcDataIn;

        ctrl_signals[control_signals::CtrlLoadInputB] = 1;
        ctrl_signals[control_signals::CtrlIncEnablePc] = 1;

        alu_op = control_signals::ALU_ADD;
      end
      InstructionMem2: begin
        next_instr_state = InstructionMem3;

        current_data_bus_input = bus_sources::DataBusSrcRegAluResult;

        ctrl_signals[control_signals::CtrlUpdateFlagCarry] = 1;

        ctrl_signals[control_signals::CtrlLoadAddrLow] = 1;
      end
      InstructionMem3: begin
        if (status_flags[control_signals::StatusFlagCarry]) begin
          next_instr_state = InstructionMem4;
        end else begin
          next_instr_state = InstructionExec1;
        end
        current_data_bus_input = bus_sources::DataBusSrcDataIn;
        ctrl_signals[control_signals::CtrlIncEnablePc] = 1;
        ctrl_signals[control_signals::CtrlLoadAddrHigh] = 1;
      end
      InstructionMem4: begin
        next_instr_state = InstructionExec1;
        ctrl_signals[control_signals::CtrlIncAddressHighReg] = 1;
      end
      default: begin
        current_address_low_bus_input  = bus_sources::AddressLowSrcAddrLowReg;
        current_address_high_bus_input = bus_sources::AddressHighSrcAddrHighReg;
        opcode_exec();
      end
    endcase
  endtask

  task invalid_state();
    $display("Invalid state");
    next_instr_state = InstructionInvalid;
    next_addr_mode   = instruction_set::AddrModeImpl;
  endtask

  // --------------------------------------------------------
  // ---------- Opcode execution system tasks ---------------
  // --------------------------------------------------------
  task opcode_exec();
    case (current_opcode)
      instruction_set::OpcADC_imm:  exec_arithmetic_op(control_signals::ALU_ADD);
      instruction_set::OpcADC_abs:  exec_arithmetic_op(control_signals::ALU_ADD);
      instruction_set::OpcADC_absx: exec_arithmetic_op(control_signals::ALU_ADD);

      instruction_set::OpcAND_imm:  exec_logic_op(control_signals::ALU_AND);
      instruction_set::OpcAND_abs:  exec_logic_op(control_signals::ALU_AND);
      instruction_set::OpcAND_absx: exec_logic_op(control_signals::ALU_AND);

      instruction_set::OpcBCC_abs: exec_branch();
      instruction_set::OpcBCS_abs: exec_branch();
      instruction_set::OpcBEQ_abs: exec_branch();
      instruction_set::OpcBMI_abs: exec_branch();
      instruction_set::OpcBNE_abs: exec_branch();
      instruction_set::OpcBPL_abs: exec_branch();
      instruction_set::OpcBVC_abs: exec_branch();
      instruction_set::OpcBVS_abs: exec_branch();

      instruction_set::OpcCLC_impl: exec_clc();

      instruction_set::OpcCMP_imm:  exec_cmp(bus_sources::DataBusSrcRegAccumulator);
      instruction_set::OpcCMP_abs:  exec_cmp(bus_sources::DataBusSrcRegAccumulator);
      instruction_set::OpcCMP_absx: exec_cmp(bus_sources::DataBusSrcRegAccumulator);

      instruction_set::OpcCPX_imm: exec_cmp(bus_sources::DataBusSrcRegX);
      instruction_set::OpcCPX_abs: exec_cmp(bus_sources::DataBusSrcRegX);

      instruction_set::OpcCPY_imm: exec_cmp(bus_sources::DataBusSrcRegY);
      instruction_set::OpcCPY_abs: exec_cmp(bus_sources::DataBusSrcRegY);

      instruction_set::OpcEOR_imm:  exec_logic_op(control_signals::ALU_XOR);
      instruction_set::OpcEOR_abs:  exec_logic_op(control_signals::ALU_XOR);
      instruction_set::OpcEOR_absx: exec_logic_op(control_signals::ALU_XOR);

      instruction_set::OpcINX_impl: exec_inx();

      instruction_set::OpcJMP_abs: exec_jmp();

      instruction_set::OpcLDA_imm:  exec_lda();
      instruction_set::OpcLDA_abs:  exec_lda();
      instruction_set::OpcLDA_absx: exec_lda();

      instruction_set::OpcLDX_imm: exec_ldx();
      instruction_set::OpcLDX_abs: exec_ldx();

      instruction_set::OpcLDY_imm:  exec_ldy();
      instruction_set::OpcLDY_abs:  exec_ldy();
      instruction_set::OpcLDY_absx: exec_ldy();

      instruction_set::OpcORA_imm:  exec_logic_op(control_signals::ALU_OR);
      instruction_set::OpcORA_abs:  exec_logic_op(control_signals::ALU_OR);
      instruction_set::OpcORA_absx: exec_logic_op(control_signals::ALU_OR);

      instruction_set::OpcPHA_impl: exec_pha(bus_sources::DataBusSrcRegAccumulator);
      instruction_set::OpcPHX_impl: exec_pha(bus_sources::DataBusSrcRegX);
      instruction_set::OpcPHY_impl: exec_pha(bus_sources::DataBusSrcRegY);

      instruction_set::OpcPLA_impl: exec_pla(control_signals::CtrlLoadAccumutator);
      instruction_set::OpcPLA_impl: exec_pla(control_signals::CtrlLoadX);
      instruction_set::OpcPLA_impl: exec_pla(control_signals::CtrlLoadY);

      instruction_set::OpcSBC_imm:  exec_arithmetic_op(control_signals::ALU_ADD, 1);
      instruction_set::OpcSBC_abs:  exec_arithmetic_op(control_signals::ALU_ADD, 1);
      instruction_set::OpcSBC_absx: exec_arithmetic_op(control_signals::ALU_ADD, 1);

      instruction_set::OpcSEC_impl: exec_sec();

      instruction_set::OpcSTA_abs:  exec_sta();
      instruction_set::OpcSTA_absx: exec_sta();

      instruction_set::OpcSTX_abs: exec_stx();

      instruction_set::OpcSTY_abs: exec_sty();

      default: invalid_state();
    endcase
  endtask

  task exec_arithmetic_op(control_signals::alu_op_t alu_op_arg, logic invert_b = 0);
    alu_op = alu_op_arg;
    case (current_instr_state)
      InstructionExec1: begin
        next_instr_state = InstructionExec2;
        current_data_bus_input = bus_sources::DataBusSrcDataIn;
        ctrl_signals[control_signals::CtrlLoadInputB] = 1;
      end
      InstructionExec2: begin
        next_instr_state = InstructionExec3;
        current_data_bus_input = bus_sources::DataBusSrcRegAccumulator;
        ctrl_signals[control_signals::CtrlLoadInputA] = 1;
      end
      InstructionExec3: begin
        next_instr_state = InstructionFetch;
        ctrl_signals[control_signals::CtrlAluCarryIn] = status_flags[control_signals::StatusFlagCarry];
        if (invert_b) begin
          ctrl_signals[control_signals::CtrlAluInvertB] = 1;
        end
        current_data_bus_input = bus_sources::DataBusSrcRegAluResult;
        ctrl_signals[control_signals::CtrlLoadAccumutator] = 1;
        ctrl_signals[control_signals::CtrlUpdateFlagNegative] = 1;
        ctrl_signals[control_signals::CtrlUpdateFlagZero] = 1;
        ctrl_signals[control_signals::CtrlUpdateFlagCarry] = 1;
        ctrl_signals[control_signals::CtrlUpdateFlagOverflow] = 1;
      end
      default: invalid_state();
    endcase
  endtask

  task exec_logic_op(control_signals::alu_op_t alu_op_arg);
    alu_op = alu_op_arg;
    case (current_instr_state)
      InstructionExec1: begin
        next_instr_state = InstructionExec2;
        current_data_bus_input = bus_sources::DataBusSrcDataIn;
        ctrl_signals[control_signals::CtrlLoadInputB] = 1;
      end
      InstructionExec2: begin
        next_instr_state = InstructionExec3;
        current_data_bus_input = bus_sources::DataBusSrcRegAccumulator;
        ctrl_signals[control_signals::CtrlLoadInputA] = 1;
      end
      InstructionExec3: begin
        next_instr_state = InstructionFetch;
        current_data_bus_input = bus_sources::DataBusSrcRegAluResult;
        ctrl_signals[control_signals::CtrlLoadAccumutator] = 1;
        ctrl_signals[control_signals::CtrlUpdateFlagNegative] = 1;
        ctrl_signals[control_signals::CtrlUpdateFlagZero] = 1;
      end
      default: invalid_state();
    endcase
  endtask

  task exec_branch();
    case (current_instr_state)
      InstructionExec1: begin
        next_instr_state = InstructionExec2;
        ctrl_signals[control_signals::CtrlIncEnablePc] = 0;
        current_data_bus_input = bus_sources::DataBusSrcDataIn;
        ctrl_signals[control_signals::CtrlLoadInputA] = 1;
        ctrl_signals[control_signals::CtrlIncEnablePc] = 1;
      end
      InstructionExec2: begin
        next_instr_state = InstructionExec3;
        current_address_low_bus_input = bus_sources::AddressLowSrcPcLow;
        current_data_bus_input = bus_sources::DataBusSrcAddrLowBus;
        ctrl_signals[control_signals::CtrlLoadInputB] = 1;
        ctrl_signals[control_signals::CtrlIncEnablePc] = 0;
      end
      InstructionExec3: begin
        next_instr_state = InstructionExec4;
        current_data_bus_input = bus_sources::DataBusSrcRegAluResult;
        ctrl_signals[control_signals::CtrlAluCarryIn] = 0;
        ctrl_signals[control_signals::CtrlLoadAddrLow] = 1;
        ctrl_signals[control_signals::CtrlIncEnablePc] = 0;
      end
      InstructionExec4: begin
        if (negative_data_in == 0 && !alu_carry || negative_data_in == 1 && alu_carry) begin
          next_instr_state = InstructionFetch;
          ctrl_signals[control_signals::CtrlIncEnablePc] = 0;
          current_address_high_bus_input = bus_sources::AddressHighSrcPcHigh;
          current_address_low_bus_input = bus_sources::AddressLowSrcAddrLowReg;
          ctrl_signals[control_signals::CtrlLoadPc] = status_flags[current_opcode[7:6]] ~^ current_opcode[5];
        end else if (negative_data_in) begin
          next_instr_state = InstructionExec5;
          ctrl_signals[control_signals::CtrlIncAddressHighReg] = 1;
          ctrl_signals[control_signals::CtrlIncEnablePc] = 0;
        end else begin
          next_instr_state = InstructionExec5;
          ctrl_signals[control_signals::CtrlDecAddressHighReg] = 1;
          ctrl_signals[control_signals::CtrlIncEnablePc] = 0;
        end
      end
      InstructionExec5: begin
        next_instr_state = InstructionFetch;
        ctrl_signals[control_signals::CtrlIncEnablePc] = 0;
        current_address_high_bus_input = bus_sources::AddressHighSrcPcHigh;
        current_address_low_bus_input = bus_sources::AddressLowSrcAddrLowReg;
        ctrl_signals[control_signals::CtrlLoadPc] = status_flags[current_opcode[7:6]] ~^ current_opcode[5];
      end
      default: invalid_state();
    endcase
  endtask

  task exec_clc();
    case (current_instr_state)
      InstructionExec1: begin
        next_instr_state = InstructionFetch;
        ctrl_signals[control_signals::CtrlClearFlagCarry] = 1;
      end
      default: invalid_state();
    endcase
  endtask

  task exec_cmp(bus_sources::data_bus_source_t cmp_src);
    alu_op = control_signals::ALU_SUB;
    case (current_instr_state)
      InstructionExec1: begin
        next_instr_state = InstructionExec2;
        current_data_bus_input = bus_sources::DataBusSrcDataIn;
        ctrl_signals[control_signals::CtrlLoadInputB] = 1;
      end
      InstructionExec2: begin
        current_data_bus_input = cmp_src;
        ctrl_signals[control_signals::CtrlLoadInputA] = 1;
      end
      InstructionExec3: begin
        next_instr_state = InstructionFetch;
        current_data_bus_input = bus_sources::DataBusSrcRegAluResult;
        ctrl_signals[control_signals::CtrlUpdateFlagNegative] = 1;
        ctrl_signals[control_signals::CtrlUpdateFlagZero] = 1;
        ctrl_signals[control_signals::CtrlUpdateFlagCarry] = 1;
      end
      default: invalid_state();
    endcase
  endtask

  task exec_inx();
    case (current_instr_state)
      InstructionExec1: begin
        next_instr_state = InstructionExec2;
        current_data_bus_input = bus_sources::DataBusSrcRegX;
        ctrl_signals[control_signals::CtrlLoadInputB] = 1;
        ctrl_signals[control_signals::CtrlResetInputA] = 1;
      end
      InstructionExec2: begin
        next_instr_state = InstructionFetch;
        current_data_bus_input = bus_sources::DataBusSrcRegAluResult;
        ctrl_signals[control_signals::CtrlAluCarryIn] = 1;
        ctrl_signals[control_signals::CtrlLoadX] = 1;
        ctrl_signals[control_signals::CtrlUpdateFlagNegative] = 1;
        ctrl_signals[control_signals::CtrlUpdateFlagZero] = 1;
      end
      default: invalid_state();
    endcase

  endtask

  task exec_jmp();
    case (current_instr_state)
      InstructionExec1: begin
        next_instr_state = InstructionFetch;
        ctrl_signals[control_signals::CtrlIncEnablePc] = 0;
        ctrl_signals[control_signals::CtrlLoadPc] = 1;
      end
      default: invalid_state();
    endcase
  endtask

  task exec_lda();
    case (current_instr_state)
      InstructionExec1: begin
        next_instr_state = InstructionFetch;
        current_data_bus_input = bus_sources::DataBusSrcDataIn;
        ctrl_signals[control_signals::CtrlLoadAccumutator] = 1;
        ctrl_signals[control_signals::CtrlUpdateFlagNegative] = 1;
        ctrl_signals[control_signals::CtrlUpdateFlagZero] = 1;
      end
      default: invalid_state();
    endcase
  endtask

  task exec_ldx();
    case (current_instr_state)
      InstructionExec1: begin
        next_instr_state = InstructionFetch;
        current_data_bus_input = bus_sources::DataBusSrcDataIn;
        ctrl_signals[control_signals::CtrlLoadX] = 1;
        ctrl_signals[control_signals::CtrlUpdateFlagNegative] = 1;
        ctrl_signals[control_signals::CtrlUpdateFlagZero] = 1;
      end
      default: invalid_state();
    endcase
  endtask

  task exec_ldy();
    case (current_instr_state)
      InstructionExec1: begin
        next_instr_state = InstructionFetch;
        current_data_bus_input = bus_sources::DataBusSrcDataIn;
        ctrl_signals[control_signals::CtrlLoadY] = 1;
        ctrl_signals[control_signals::CtrlUpdateFlagNegative] = 1;
        ctrl_signals[control_signals::CtrlUpdateFlagZero] = 1;
      end
      default: invalid_state();
    endcase
  endtask

  task exec_pha(bus_sources::data_bus_source_t push_src);
    case (current_instr_state)
      InstructionExec1: begin
        next_instr_state = InstructionFetch;
        current_data_bus_input = push_src;
        current_address_low_bus_input = bus_sources::AddressLowSrcStackPointer;
        current_address_high_bus_input = bus_sources::AddressHighSrcStackPointer;
        ctrl_signals[control_signals::CtrlRead0Write1] = 1;
        ctrl_signals[control_signals::CtrlDecStackPointer] = 1;
      end
      default: invalid_state();
    endcase
  endtask

  task exec_pla(control_signals::ctrl_signals_t pull_src);
    case (current_instr_state)
      InstructionExec1: begin
        next_instr_state = InstructionExec2;
        ctrl_signals[control_signals::CtrlRead0Write1] = 1;
        ctrl_signals[control_signals::CtrlIncStackPointer] = 1;
      end
      InstructionExec2: begin
        next_instr_state = InstructionFetch;
        current_data_bus_input = bus_sources::DataBusSrcDataIn;
        current_address_low_bus_input = bus_sources::AddressLowSrcStackPointer;
        current_address_high_bus_input = bus_sources::AddressHighSrcStackPointer;
        ctrl_signals[control_signals::CtrlDecStackPointer] = 1;
        ctrl_signals[pull_src] = 1;
      end
      default: invalid_state();
    endcase
  endtask

  task exec_sec();
    case (current_instr_state)
      InstructionExec1: begin
        next_instr_state = InstructionFetch;
        ctrl_signals[control_signals::CtrlSetFlagCarry] = 1;
      end
      default: invalid_state();
    endcase
  endtask

  task exec_sta();
    case (current_instr_state)
      InstructionExec1: begin
        next_instr_state = InstructionFetch;
        current_data_bus_input = bus_sources::DataBusSrcRegAccumulator;
        ctrl_signals[control_signals::CtrlRead0Write1] = 1;
      end
      default: invalid_state();
    endcase
  endtask

  task exec_stx();
    case (current_instr_state)
      InstructionExec1: begin
        next_instr_state = InstructionFetch;
        current_data_bus_input = bus_sources::DataBusSrcRegX;
        ctrl_signals[control_signals::CtrlRead0Write1] = 1;
      end
      default: invalid_state();
    endcase
  endtask

  task exec_sty();
    case (current_instr_state)
      InstructionExec1: begin
        next_instr_state = InstructionFetch;
        current_data_bus_input = bus_sources::DataBusSrcRegY;
        ctrl_signals[control_signals::CtrlRead0Write1] = 1;
      end
      default: invalid_state();
    endcase
  endtask

endmodule
