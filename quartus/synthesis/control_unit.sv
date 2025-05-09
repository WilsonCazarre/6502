module control_unit (
    input logic status_flags[8],
    input logic [7:0] data_in_latch,
    input instruction_set::opcode_t current_opcode,
    input logic clk,
    input logic reset,
    input logic alu_carry,
    input logic nmib,
    input logic irqb,

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
    InstructionMem5,
    InstructionMem6,
    InstructionMem7,
    InstructionMem8,
    InstructionMem9,

    InstructionExec1,
    InstructionExec2,
    InstructionExec3,
    InstructionExec4,
    InstructionExec5,
    InstructionExec6,

    InstructionBrk1,
    InstructionBrk2,
    InstructionBrk3,
    InstructionBrk4,
    InstructionBrk5,
    InstructionBrk6,
    InstructionBrk7,

    InstructionInvalid,
    InstructionStateEndMarker
  } instruction_state_t;

  typedef enum logic [3:0] {
    InterruptNone,
    InterruptNMI,
    InterruptBRK,
    InterruptIRQ,
    InterruptRESET,
    InterruptStateEndMarker
  } interrupt_state_t;
  logic interrupt_pending;
  instruction_state_t current_instr_state, next_instr_state;
  interrupt_state_t current_interrupt;
  instruction_set::address_mode_t current_addr_mode, next_addr_mode;
  logic negative_data_in;

  always_ff @(posedge clk or negedge nmib or negedge irqb) begin
    if (~nmib || ~irqb) begin
      current_instr_state <= InstructionFetch;
      current_interrupt   <= InterruptNMI;
      interrupt_pending   <= 1;
    end else if (reset) begin
      current_instr_state <= InstructionFetch;
      current_interrupt   <= InterruptRESET;
      interrupt_pending   <= 1;
    end else if (interrupt_pending && current_instr_state == InstructionFetch) begin
      current_instr_state <= InstructionBrk1;
      current_addr_mode   <= instruction_set::AddrModeImpl;
      interrupt_pending   <= 0;
    end else begin
      negative_data_in <= data_in_latch[7];
      current_instr_state <= next_instr_state;
      current_addr_mode <= next_addr_mode;
      current_interrupt <= current_instr_state == InstructionBrk7 ? InterruptNone : current_interrupt;
      interrupt_pending <= interrupt_pending;
    end
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

  task acc_addr_mode();
    next_addr_mode = instruction_set::AddrModeAcc;
    case (current_instr_state)
      InstructionDecode: begin
        next_instr_state = InstructionExec1;
      end
      default: opcode_exec();
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

  task absx_addr_mode(bus_sources::data_bus_source_t idx_reg);
    next_addr_mode = instruction_set::AddrModeAbsX;
    case (current_instr_state)
      InstructionDecode: begin
        next_instr_state = InstructionMem1;
        current_data_bus_input = idx_reg;
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

  task ind_addr_mode();
    next_addr_mode = instruction_set::AddrModeInd;
    case (current_instr_state)
      InstructionDecode: begin
        next_instr_state = InstructionMem1;
        ctrl_signals[control_signals::CtrlIncEnablePc] = 1;
        ctrl_signals[control_signals::CtrlLoadAddrLow] = 1;
      end
      InstructionMem1: begin
        next_instr_state = InstructionMem2;
        ctrl_signals[control_signals::CtrlIncEnablePc] = 1;
        ctrl_signals[control_signals::CtrlLoadAddrHigh] = 1;
      end
      InstructionMem2: begin
        next_instr_state = InstructionMem3;

        current_address_low_bus_input = bus_sources::AddressLowSrcAddrLowReg;
        current_address_high_bus_input = bus_sources::AddressHighSrcAddrHighReg;

        ctrl_signals[control_signals::CtrlLoadPc] = 1;
        ctrl_signals[control_signals::CtrlLoadAddrLow] = 1;
      end
      InstructionMem3: begin
        next_instr_state = InstructionMem4;

        ctrl_signals[control_signals::CtrlIncEnablePc] = 1;
      end
      InstructionMem4: begin
        next_instr_state = InstructionExec1;
        ctrl_signals[control_signals::CtrlIncEnablePc] = 0;
        ctrl_signals[control_signals::CtrlLoadAddrHigh] = 1;
      end
      default: begin
        current_address_low_bus_input  = bus_sources::AddressLowSrcAddrLowReg;
        current_address_high_bus_input = bus_sources::AddressHighSrcAddrHighReg;
        opcode_exec();
      end
    endcase
  endtask

  task indx_addr_mode();
    next_addr_mode = instruction_set::AddrModeIndX;
    case (current_instr_state)
      InstructionDecode: begin
        next_instr_state = InstructionMem1;

        current_data_bus_input = bus_sources::DataBusSrcRegX;

        ctrl_signals[control_signals::CtrlLoadInputA] = 1;
        ctrl_signals[control_signals::CtrlClearFlagCarry] = 1;
        ctrl_signals[control_signals::CtrlIncEnablePc] = 0;
      end
      InstructionMem1: begin
        next_instr_state = InstructionMem2;

        current_data_bus_input = bus_sources::DataBusSrcZero;

        ctrl_signals[control_signals::CtrlLoadInputB] = 1;
        ctrl_signals[control_signals::CtrlIncEnablePc] = 0;

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
          next_instr_state = InstructionMem5;
        end
        current_data_bus_input = bus_sources::DataBusSrcDataIn;
        ctrl_signals[control_signals::CtrlLoadAddrHigh] = 1;
      end
      InstructionMem4: begin
        next_instr_state = InstructionExec5;
        ctrl_signals[control_signals::CtrlIncAddressHighReg] = 1;
      end
      InstructionMem5: begin
        next_instr_state = InstructionMem6;

        current_address_low_bus_input = bus_sources::AddressLowSrcAddrLowReg;
        current_address_high_bus_input = bus_sources::AddressHighSrcAddrHighReg;

        ctrl_signals[control_signals::CtrlLoadAddrLow] = 1;
      end
      InstructionMem6: begin
        next_instr_state = InstructionMem7;

        ctrl_signals[control_signals::CtrlIncEnablePc] = 1;
      end
      InstructionMem7: begin
        next_instr_state = InstructionExec1;
        ctrl_signals[control_signals::CtrlIncEnablePc] = 0;
        ctrl_signals[control_signals::CtrlLoadAddrHigh] = 1;
      end
      default: begin
        current_address_low_bus_input  = bus_sources::AddressLowSrcAddrLowReg;
        current_address_high_bus_input = bus_sources::AddressHighSrcZero;
        opcode_exec();
      end
    endcase
  endtask

  task zpg_addr_mode();
    next_addr_mode = instruction_set::AddrModeZpg;
    case (current_instr_state)
      InstructionDecode: begin
        next_instr_state = InstructionExec1;
        ctrl_signals[control_signals::CtrlIncEnablePc] = 1;
        ctrl_signals[control_signals::CtrlLoadAddrLow] = 1;
      end
      default: begin
        current_address_low_bus_input  = bus_sources::AddressLowSrcAddrLowReg;
        current_address_high_bus_input = bus_sources::AddressHighSrcZero;
        opcode_exec();
      end
    endcase
  endtask

  task zpgx_addr_mode(bus_sources::data_bus_source_t idx_reg);
    next_addr_mode = instruction_set::AddrModeZpgX;
    case (current_instr_state)
      InstructionDecode: begin
        next_instr_state = InstructionMem1;
        current_data_bus_input = bus_sources::DataBusSrcDataIn;
        ctrl_signals[control_signals::CtrlLoadInputA] = 1;
        ctrl_signals[control_signals::CtrlClearFlagCarry] = 1;
      end
      InstructionMem1: begin
        next_instr_state = InstructionMem2;

        current_data_bus_input = idx_reg;

        ctrl_signals[control_signals::CtrlLoadInputB] = 1;
        ctrl_signals[control_signals::CtrlIncEnablePc] = 1;

        alu_op = control_signals::ALU_ADD;
      end
      InstructionMem2: begin
        next_instr_state = InstructionExec1;

        current_data_bus_input = bus_sources::DataBusSrcRegAluResult;

        ctrl_signals[control_signals::CtrlUpdateFlagCarry] = 1;

        ctrl_signals[control_signals::CtrlLoadAddrLow] = 1;
      end
      default: begin
        current_address_low_bus_input  = bus_sources::AddressLowSrcAddrLowReg;
        current_address_high_bus_input = bus_sources::AddressHighSrcZero;
        opcode_exec();
      end
    endcase
  endtask

  task invalid_state();
    $display("Invalid state");
    next_instr_state = InstructionInvalid;
    next_addr_mode   = instruction_set::AddrModeImpl;
  endtask

  always_comb begin
    ctrl_signals = '{default: '0};

    current_data_bus_input = bus_sources::DataBusSrcDataIn;
    current_address_low_bus_input = bus_sources::AddressLowSrcPcLow;
    current_address_high_bus_input = bus_sources::AddressHighSrcPcHigh;

    next_instr_state = InstructionInvalid;
    next_addr_mode = instruction_set::AddrModeImpl;
    alu_op = control_signals::ALU_ADD;

    case (current_instr_state)
      InstructionBrk1: begin
        next_instr_state = current_interrupt == InterruptRESET ? InstructionBrk4 : InstructionBrk2;
        current_data_bus_input = bus_sources::DataBusSrcPCHigh;
        current_address_low_bus_input = bus_sources::AddressLowSrcStackPointer;
        current_address_high_bus_input = bus_sources::AddressHighSrcStackPointer;
        ctrl_signals[control_signals::CtrlRead0Write1] = current_interrupt != InterruptRESET;
        ctrl_signals[control_signals::CtrlDecStackPointer] = current_interrupt != InterruptRESET;
        ctrl_signals[control_signals::CtrlSetInterruptDisable] = current_interrupt == InterruptIRQ;
      end
      InstructionBrk2: begin
        next_instr_state = InstructionBrk3;
        current_data_bus_input = bus_sources::DataBusSrcPCLow;
        current_address_low_bus_input = bus_sources::AddressLowSrcStackPointer;
        current_address_high_bus_input = bus_sources::AddressHighSrcStackPointer;
        ctrl_signals[control_signals::CtrlRead0Write1] = 1;
        ctrl_signals[control_signals::CtrlDecStackPointer] = 1;
      end
      InstructionBrk3: begin
        next_instr_state = InstructionBrk4;
        current_data_bus_input = bus_sources::DataBusSrcStatusRegister;
        current_address_low_bus_input = bus_sources::AddressLowSrcStackPointer;
        current_address_high_bus_input = bus_sources::AddressHighSrcStackPointer;
        ctrl_signals[control_signals::CtrlRead0Write1] = 1;
        ctrl_signals[control_signals::CtrlDecStackPointer] = 1;
      end
      InstructionBrk4: begin
        next_instr_state = InstructionBrk5;
        current_data_bus_input = bus_sources::DataBusSrcDataIn;
        current_address_high_bus_input = bus_sources::AddressHighSrcFF;
        case (current_interrupt)
          InterruptNMI: current_address_low_bus_input = bus_sources::AddressLowSrcFA;
          InterruptIRQ: current_address_low_bus_input = bus_sources::AddressLowSrcFE;
          InterruptRESET: current_address_low_bus_input = bus_sources::AddressLowSrcFC;
          default: current_address_low_bus_input = bus_sources::AddressLowSrcFC;
        endcase
      end
      InstructionBrk5: begin
        next_instr_state = InstructionBrk6;
        current_data_bus_input = bus_sources::DataBusSrcDataInLatch;
        current_address_low_bus_input = bus_sources::AddressLowSrcDataBus;
        current_address_high_bus_input = bus_sources::AddressHighSrcPcHigh;
        ctrl_signals[control_signals::CtrlLoadPc] = 1;
      end
      InstructionBrk6: begin
        next_instr_state = InstructionBrk7;
        current_data_bus_input = bus_sources::DataBusSrcDataIn;
        current_address_high_bus_input = bus_sources::AddressHighSrcFF;
        case (current_interrupt)
          InterruptNMI: current_address_low_bus_input = bus_sources::AddressLowSrcFB;
          InterruptIRQ: current_address_low_bus_input = bus_sources::AddressLowSrcFF;
          InterruptRESET: current_address_low_bus_input = bus_sources::AddressLowSrcFD;
          default: current_address_low_bus_input = bus_sources::AddressLowSrcFD;
        endcase
      end
      InstructionBrk7: begin
        next_instr_state = InstructionFetch;
        current_data_bus_input = bus_sources::DataBusSrcDataInLatch;
        current_address_low_bus_input = bus_sources::AddressLowSrcPcLow;
        current_address_high_bus_input = bus_sources::AddressHighSrcDataBus;
        ctrl_signals[control_signals::CtrlLoadPc] = 1;
      end
      InstructionFetch: begin
        current_data_bus_input = bus_sources::DataBusSrcDataIn;
        current_address_low_bus_input = bus_sources::AddressLowSrcPcLow;
        current_address_high_bus_input = bus_sources::AddressHighSrcPcHigh;

        next_instr_state = InstructionDecode;
        ctrl_signals[control_signals::CtrlLoadInstReg] = current_interrupt == InterruptNone;
        ctrl_signals[control_signals::CtrlIncEnablePc] = current_interrupt == InterruptNone;
      end
      InstructionDecode: begin
        case (current_opcode)
          instruction_set::OpcADC_imm:  imm_addr_mode();
          instruction_set::OpcADC_abs:  abs_addr_mode();
          instruction_set::OpcADC_absx: absx_addr_mode(bus_sources::DataBusSrcRegX);
          instruction_set::OpcADC_absy: absx_addr_mode(bus_sources::DataBusSrcRegY);
          instruction_set::OpcADC_indx: indx_addr_mode();
          instruction_set::OpcADC_zpg:  zpg_addr_mode();

          instruction_set::OpcAND_imm:  imm_addr_mode();
          instruction_set::OpcAND_abs:  abs_addr_mode();
          instruction_set::OpcAND_absx: absx_addr_mode(bus_sources::DataBusSrcRegX);
          instruction_set::OpcAND_absy: absx_addr_mode(bus_sources::DataBusSrcRegY);
          instruction_set::OpcAND_indx: indx_addr_mode();
          instruction_set::OpcAND_zpg:  zpg_addr_mode();

          instruction_set::OpcASL_abs:  abs_addr_mode();
          instruction_set::OpcASL_absx: absx_addr_mode(bus_sources::DataBusSrcRegX);
          instruction_set::OpcASL_acc:  acc_addr_mode();
          instruction_set::OpcASL_zpg:  zpg_addr_mode();
          instruction_set::OpcASL_zpgx: zpgx_addr_mode(bus_sources::DataBusSrcRegX);

          instruction_set::OpcBCC_abs: imm_addr_mode();
          instruction_set::OpcBCS_abs: imm_addr_mode();
          instruction_set::OpcBEQ_abs: imm_addr_mode();
          instruction_set::OpcBMI_abs: imm_addr_mode();
          instruction_set::OpcBNE_abs: imm_addr_mode();
          instruction_set::OpcBPL_abs: imm_addr_mode();
          instruction_set::OpcBVC_abs: imm_addr_mode();
          instruction_set::OpcBVS_abs: imm_addr_mode();

          instruction_set::OpcCLI_impl: impl_addr_mode();

          instruction_set::OpcCLC_impl: impl_addr_mode();

          instruction_set::OpcCMP_imm:  imm_addr_mode();
          instruction_set::OpcCMP_abs:  abs_addr_mode();
          instruction_set::OpcCMP_absx: absx_addr_mode(bus_sources::DataBusSrcRegX);
          instruction_set::OpcCMP_absy: absx_addr_mode(bus_sources::DataBusSrcRegY);
          instruction_set::OpcCMP_indx: indx_addr_mode();
          instruction_set::OpcCMP_zpg:  zpg_addr_mode();

          instruction_set::OpcCPX_imm: imm_addr_mode();
          instruction_set::OpcCPX_abs: abs_addr_mode();
          instruction_set::OpcCPX_zpg: zpg_addr_mode();

          instruction_set::OpcCPY_imm: imm_addr_mode();
          instruction_set::OpcCPY_abs: abs_addr_mode();
          instruction_set::OpcCPY_zpg: zpg_addr_mode();

          instruction_set::OpcEOR_imm:  imm_addr_mode();
          instruction_set::OpcEOR_abs:  abs_addr_mode();
          instruction_set::OpcEOR_absx: absx_addr_mode(bus_sources::DataBusSrcRegX);
          instruction_set::OpcEOR_absy: absx_addr_mode(bus_sources::DataBusSrcRegY);
          instruction_set::OpcEOR_indx: indx_addr_mode();
          instruction_set::OpcEOR_zpg:  zpg_addr_mode();

          instruction_set::OpcINX_impl: impl_addr_mode();
          instruction_set::OpcINY_impl: impl_addr_mode();

          instruction_set::OpcJMP_abs: abs_addr_mode();
          instruction_set::OpcJMP_ind: ind_addr_mode();

          instruction_set::OpcJSR_abs: abs_addr_mode();

          instruction_set::OpcLDA_imm:  imm_addr_mode();
          instruction_set::OpcLDA_abs:  abs_addr_mode();
          instruction_set::OpcLDA_absx: absx_addr_mode(bus_sources::DataBusSrcRegX);
          instruction_set::OpcLDA_absy: absx_addr_mode(bus_sources::DataBusSrcRegY);
          instruction_set::OpcLDA_indx: indx_addr_mode();
          instruction_set::OpcLDA_zpg:  zpg_addr_mode();
          instruction_set::OpcLDA_zpgx: zpgx_addr_mode(bus_sources::DataBusSrcRegX);

          instruction_set::OpcLDX_imm:  imm_addr_mode();
          instruction_set::OpcLDX_abs:  abs_addr_mode();
          instruction_set::OpcLDX_absy: absx_addr_mode(bus_sources::DataBusSrcRegY);
          instruction_set::OpcLDX_zpg:  zpg_addr_mode();

          instruction_set::OpcLDY_imm:  imm_addr_mode();
          instruction_set::OpcLDY_abs:  abs_addr_mode();
          instruction_set::OpcLDY_absx: absx_addr_mode(bus_sources::DataBusSrcRegX);
          instruction_set::OpcLDY_zpg:  zpg_addr_mode();

          instruction_set::OpcLSR_abs:  abs_addr_mode();
          instruction_set::OpcLSR_absx: absx_addr_mode(bus_sources::DataBusSrcRegX);
          instruction_set::OpcLSR_acc:  acc_addr_mode();
          instruction_set::OpcLSR_zpg:  zpg_addr_mode();
          instruction_set::OpcLSR_zpgx: zpgx_addr_mode(bus_sources::DataBusSrcRegX);

          instruction_set::OpcNOP_impl: next_instr_state = InstructionFetch;

          instruction_set::OpcORA_imm:  imm_addr_mode();
          instruction_set::OpcORA_abs:  abs_addr_mode();
          instruction_set::OpcORA_absx: absx_addr_mode(bus_sources::DataBusSrcRegX);
          instruction_set::OpcORA_absy: absx_addr_mode(bus_sources::DataBusSrcRegY);
          instruction_set::OpcORA_indx: indx_addr_mode();
          instruction_set::OpcORA_zpg:  zpg_addr_mode();

          instruction_set::OpcPHA_impl: impl_addr_mode();
          instruction_set::OpcPHX_impl: impl_addr_mode();
          instruction_set::OpcPHY_impl: impl_addr_mode();

          instruction_set::OpcPLA_impl: impl_addr_mode();
          instruction_set::OpcPLX_impl: impl_addr_mode();
          instruction_set::OpcPLY_impl: impl_addr_mode();

          instruction_set::OpcROL_abs:  abs_addr_mode();
          instruction_set::OpcROL_absx: absx_addr_mode(bus_sources::DataBusSrcRegX);
          instruction_set::OpcROL_acc:  acc_addr_mode();
          instruction_set::OpcROL_zpg:  zpg_addr_mode();
          instruction_set::OpcROL_zpgx: zpgx_addr_mode(bus_sources::DataBusSrcRegX);

          instruction_set::OpcROR_abs:  abs_addr_mode();
          instruction_set::OpcROR_absx: absx_addr_mode(bus_sources::DataBusSrcRegX);
          instruction_set::OpcROR_acc:  acc_addr_mode();
          instruction_set::OpcROR_zpg:  zpg_addr_mode();
          instruction_set::OpcROR_zpgx: zpgx_addr_mode(bus_sources::DataBusSrcRegX);

          instruction_set::OpcRTI_impl: impl_addr_mode();
          instruction_set::OpcRTS_impl: impl_addr_mode();

          instruction_set::OpcSBC_imm:  imm_addr_mode();
          instruction_set::OpcSBC_abs:  abs_addr_mode();
          instruction_set::OpcSBC_absx: absx_addr_mode(bus_sources::DataBusSrcRegX);
          instruction_set::OpcSBC_absy: absx_addr_mode(bus_sources::DataBusSrcRegY);
          instruction_set::OpcSBC_indx: indx_addr_mode();
          instruction_set::OpcSBC_zpg:  zpg_addr_mode();

          instruction_set::OpcSEI_impl: impl_addr_mode();

          instruction_set::OpcSEC_impl: impl_addr_mode();

          instruction_set::OpcSTA_abs:  abs_addr_mode();
          instruction_set::OpcSTA_absx: absx_addr_mode(bus_sources::DataBusSrcRegX);
          instruction_set::OpcSTA_absy: absx_addr_mode(bus_sources::DataBusSrcRegY);
          instruction_set::OpcSTA_indx: indx_addr_mode();
          instruction_set::OpcSTA_zpg:  zpg_addr_mode();
          instruction_set::OpcSTA_zpgx: zpgx_addr_mode(bus_sources::DataBusSrcRegX);

          instruction_set::OpcSTX_abs: abs_addr_mode();
          instruction_set::OpcSTX_zpg: zpg_addr_mode();

          instruction_set::OpcSTY_abs: abs_addr_mode();
          instruction_set::OpcSTY_zpg: zpg_addr_mode();

          instruction_set::OpcTAX_impl: impl_addr_mode();
          instruction_set::OpcTAY_impl: impl_addr_mode();
          instruction_set::OpcTSX_impl: impl_addr_mode();
          instruction_set::OpcTXA_impl: impl_addr_mode();
          instruction_set::OpcTXS_impl: impl_addr_mode();
          instruction_set::OpcTYA_impl: impl_addr_mode();

          default: next_addr_mode = instruction_set::AddrModeImpl;
        endcase
      end
      default: begin
        case (current_addr_mode)
          instruction_set::AddrModeImm: imm_addr_mode();
          instruction_set::AddrModeAbs: abs_addr_mode();
          instruction_set::AddrModeAbsX: absx_addr_mode(bus_sources::DataBusSrcRegX);
          instruction_set::AddrModeAbsY: absx_addr_mode(bus_sources::DataBusSrcRegY);
          instruction_set::AddrModeAcc: acc_addr_mode();
          instruction_set::AddrModeInd: ind_addr_mode();
          instruction_set::AddrModeIndX: indx_addr_mode();
          instruction_set::AddrModeImpl: impl_addr_mode();
          instruction_set::AddrModeZpg: zpg_addr_mode();
          instruction_set::AddrModeZpgX: zpgx_addr_mode(bus_sources::DataBusSrcRegX);
          default: invalid_state();
        endcase
      end
    endcase
  end

  // --------------------------------------------------------
  // ---------- Opcode execution system tasks ---------------
  // --------------------------------------------------------
  task opcode_exec();
    case (current_opcode)
      instruction_set::OpcADC_imm:  exec_arithmetic_op(control_signals::ALU_ADD);
      instruction_set::OpcADC_abs:  exec_arithmetic_op(control_signals::ALU_ADD);
      instruction_set::OpcADC_absx: exec_arithmetic_op(control_signals::ALU_ADD);
      instruction_set::OpcADC_absy: exec_arithmetic_op(control_signals::ALU_ADD);
      instruction_set::OpcADC_indx: exec_arithmetic_op(control_signals::ALU_ADD);
      instruction_set::OpcADC_zpg:  exec_arithmetic_op(control_signals::ALU_ADD);

      instruction_set::OpcAND_imm:  exec_logic_op(control_signals::ALU_AND);
      instruction_set::OpcAND_abs:  exec_logic_op(control_signals::ALU_AND);
      instruction_set::OpcAND_absx: exec_logic_op(control_signals::ALU_AND);
      instruction_set::OpcAND_absy: exec_logic_op(control_signals::ALU_AND);
      instruction_set::OpcAND_zpg:  exec_logic_op(control_signals::ALU_AND);

      instruction_set::OpcASL_abs:  exec_shift_op(control_signals::ALU_SHIFT_LEFT, 0);
      instruction_set::OpcASL_absx: exec_shift_op(control_signals::ALU_SHIFT_LEFT, 0);
      instruction_set::OpcASL_acc:  exec_shift_op(control_signals::ALU_SHIFT_LEFT, 0, 1);
      instruction_set::OpcASL_zpg:  exec_shift_op(control_signals::ALU_SHIFT_LEFT, 0);
      instruction_set::OpcASL_zpgx: exec_shift_op(control_signals::ALU_SHIFT_LEFT, 0);

      instruction_set::OpcBCC_abs: exec_branch();
      instruction_set::OpcBCS_abs: exec_branch();
      instruction_set::OpcBEQ_abs: exec_branch();
      instruction_set::OpcBMI_abs: exec_branch();
      instruction_set::OpcBNE_abs: exec_branch();
      instruction_set::OpcBPL_abs: exec_branch();
      instruction_set::OpcBVC_abs: exec_branch();
      instruction_set::OpcBVS_abs: exec_branch();

      instruction_set::OpcCLI_impl: exec_cli();
      instruction_set::OpcCLC_impl: exec_clc();

      instruction_set::OpcCMP_imm:  exec_cmp(bus_sources::DataBusSrcRegAccumulator);
      instruction_set::OpcCMP_abs:  exec_cmp(bus_sources::DataBusSrcRegAccumulator);
      instruction_set::OpcCMP_absx: exec_cmp(bus_sources::DataBusSrcRegAccumulator);
      instruction_set::OpcCMP_absy: exec_cmp(bus_sources::DataBusSrcRegAccumulator);
      instruction_set::OpcCMP_zpg:  exec_cmp(bus_sources::DataBusSrcRegAccumulator);

      instruction_set::OpcCPX_imm: exec_cmp(bus_sources::DataBusSrcRegX);
      instruction_set::OpcCPX_abs: exec_cmp(bus_sources::DataBusSrcRegX);
      instruction_set::OpcCPX_zpg: exec_cmp(bus_sources::DataBusSrcRegX);

      instruction_set::OpcCPY_imm: exec_cmp(bus_sources::DataBusSrcRegY);
      instruction_set::OpcCPY_abs: exec_cmp(bus_sources::DataBusSrcRegY);
      instruction_set::OpcCPY_zpg: exec_cmp(bus_sources::DataBusSrcRegY);

      instruction_set::OpcEOR_imm:  exec_logic_op(control_signals::ALU_XOR);
      instruction_set::OpcEOR_abs:  exec_logic_op(control_signals::ALU_XOR);
      instruction_set::OpcEOR_absx: exec_logic_op(control_signals::ALU_XOR);
      instruction_set::OpcEOR_absy: exec_logic_op(control_signals::ALU_XOR);
      instruction_set::OpcEOR_zpg:  exec_logic_op(control_signals::ALU_XOR);

      instruction_set::OpcINX_impl: exec_inx();

      instruction_set::OpcINY_impl: exec_iny();

      instruction_set::OpcJMP_abs: exec_jmp();
      instruction_set::OpcJMP_ind: exec_jmp();

      instruction_set::OpcJSR_abs: exec_jsr();

      instruction_set::OpcLDA_imm:  exec_lda();
      instruction_set::OpcLDA_abs:  exec_lda();
      instruction_set::OpcLDA_absx: exec_lda();
      instruction_set::OpcLDA_absy: exec_lda();
      instruction_set::OpcLDA_zpg:  exec_lda();
      instruction_set::OpcLDA_zpgx: exec_lda();

      instruction_set::OpcLDX_imm:  exec_ldx();
      instruction_set::OpcLDX_abs:  exec_ldx();
      instruction_set::OpcLDX_absy: exec_ldx();
      instruction_set::OpcLDX_zpg:  exec_ldx();

      instruction_set::OpcLDY_imm:  exec_ldy();
      instruction_set::OpcLDY_abs:  exec_ldy();
      instruction_set::OpcLDY_absx: exec_ldy();
      instruction_set::OpcLDY_zpg:  exec_ldy();

      instruction_set::OpcLSR_abs:  exec_shift_op(control_signals::ALU_SHIFT_RIGHT, 0);
      instruction_set::OpcLSR_absx: exec_shift_op(control_signals::ALU_SHIFT_RIGHT, 0);
      instruction_set::OpcLSR_acc:  exec_shift_op(control_signals::ALU_SHIFT_RIGHT, 0, 1);
      instruction_set::OpcLSR_zpg:  exec_shift_op(control_signals::ALU_SHIFT_RIGHT, 0);
      instruction_set::OpcLSR_zpgx: exec_shift_op(control_signals::ALU_SHIFT_RIGHT, 0);

      instruction_set::OpcORA_imm:  exec_logic_op(control_signals::ALU_OR);
      instruction_set::OpcORA_abs:  exec_logic_op(control_signals::ALU_OR);
      instruction_set::OpcORA_absx: exec_logic_op(control_signals::ALU_OR);
      instruction_set::OpcORA_absy: exec_logic_op(control_signals::ALU_OR);
      instruction_set::OpcORA_zpg:  exec_logic_op(control_signals::ALU_OR);

      instruction_set::OpcPHA_impl: exec_pha(bus_sources::DataBusSrcRegAccumulator);
      instruction_set::OpcPHX_impl: exec_pha(bus_sources::DataBusSrcRegX);
      instruction_set::OpcPHY_impl: exec_pha(bus_sources::DataBusSrcRegY);

      instruction_set::OpcPLA_impl: exec_pla(control_signals::CtrlLoadAccumulator);
      instruction_set::OpcPLA_impl: exec_pla(control_signals::CtrlLoadX);
      instruction_set::OpcPLA_impl: exec_pla(control_signals::CtrlLoadY);

      instruction_set::OpcROL_abs:  exec_shift_op(control_signals::ALU_SHIFT_LEFT, 1);
      instruction_set::OpcROL_absx: exec_shift_op(control_signals::ALU_SHIFT_LEFT, 1);
      instruction_set::OpcROL_acc:  exec_shift_op(control_signals::ALU_SHIFT_LEFT, 1, 1);
      instruction_set::OpcROL_zpg:  exec_shift_op(control_signals::ALU_SHIFT_LEFT, 1);
      instruction_set::OpcROL_zpgx: exec_shift_op(control_signals::ALU_SHIFT_LEFT, 1);

      instruction_set::OpcROR_abs:  exec_shift_op(control_signals::ALU_SHIFT_RIGHT, 1);
      instruction_set::OpcROR_absx: exec_shift_op(control_signals::ALU_SHIFT_RIGHT, 1);
      instruction_set::OpcROR_acc:  exec_shift_op(control_signals::ALU_SHIFT_RIGHT, 1, 1);
      instruction_set::OpcROR_zpg:  exec_shift_op(control_signals::ALU_SHIFT_RIGHT, 1);
      instruction_set::OpcROR_zpgx: exec_shift_op(control_signals::ALU_SHIFT_RIGHT, 1);

      instruction_set::OpcRTI_impl: exec_rti();
      instruction_set::OpcRTS_impl: exec_rts();

      instruction_set::OpcSBC_imm:  exec_arithmetic_op(control_signals::ALU_ADD, 1);
      instruction_set::OpcSBC_abs:  exec_arithmetic_op(control_signals::ALU_ADD, 1);
      instruction_set::OpcSBC_absx: exec_arithmetic_op(control_signals::ALU_ADD, 1);
      instruction_set::OpcSBC_absy: exec_arithmetic_op(control_signals::ALU_ADD, 1);
      instruction_set::OpcSBC_zpg:  exec_arithmetic_op(control_signals::ALU_ADD, 1);

      instruction_set::OpcSEI_impl: exec_sei();
      instruction_set::OpcSEC_impl: exec_sec();

      instruction_set::OpcSTA_abs:  exec_sta();
      instruction_set::OpcSTA_absx: exec_sta();
      instruction_set::OpcSTA_absy: exec_sta();
      instruction_set::OpcSTA_zpg:  exec_sta();
      instruction_set::OpcSTA_zpgx: exec_sta();

      instruction_set::OpcSTX_abs: exec_stx();
      instruction_set::OpcSTX_zpg: exec_stx();

      instruction_set::OpcSTY_abs: exec_sty();
      instruction_set::OpcSTY_zpg: exec_sty();

      instruction_set::OpcTAX_impl:
      exec_transfer(bus_sources::DataBusSrcRegAccumulator, control_signals::CtrlLoadX);

      instruction_set::OpcTAY_impl:
      exec_transfer(bus_sources::DataBusSrcRegAccumulator, control_signals::CtrlLoadY);

      instruction_set::OpcTSX_impl: exec_tsx();

      instruction_set::OpcTXA_impl:
      exec_transfer(bus_sources::DataBusSrcRegX, control_signals::CtrlLoadAccumulator);

      instruction_set::OpcTXS_impl: exec_txs();

      instruction_set::OpcTYA_impl:
      exec_transfer(bus_sources::DataBusSrcRegY, control_signals::CtrlLoadAccumulator);

      default: invalid_state();
    endcase
  endtask

  task exec_shift_op(control_signals::alu_op_t alu_op_arg, logic rotate_carry = 0,
                     logic load_from_acc = 0);
    alu_op = alu_op_arg;
    case (current_instr_state)
      InstructionExec1: begin
        next_instr_state = InstructionExec2;
        current_data_bus_input = 
          load_from_acc ? bus_sources::DataBusSrcRegAccumulator : bus_sources::DataBusSrcDataIn;
        ctrl_signals[control_signals::CtrlLoadInputA] = 1;
      end
      InstructionExec2: begin
        next_instr_state = InstructionFetch;
        current_data_bus_input = bus_sources::DataBusSrcRegAluResult;
        ctrl_signals[control_signals::CtrlAluCarryIn] = 
          rotate_carry ? status_flags[control_signals::StatusFlagCarry] : 0;
        ctrl_signals[control_signals::CtrlLoadAccumulator] = 1;
        ctrl_signals[control_signals::CtrlUpdateFlagNegative] = 1;
        ctrl_signals[control_signals::CtrlUpdateFlagZero] = 1;
        ctrl_signals[control_signals::CtrlUpdateFlagCarry] = 1;
      end
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
        ctrl_signals[control_signals::CtrlLoadAccumulator] = 1;
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
        ctrl_signals[control_signals::CtrlLoadAccumulator] = 1;
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

  task exec_cli();
    case (current_instr_state)
      InstructionExec1: begin
        next_instr_state = InstructionFetch;
        ctrl_signals[control_signals::CtrlClearInterruptDisable] = 1;
      end
      default: invalid_state();
    endcase
  endtask

  task exec_cmp(bus_sources::data_bus_source_t cmp_src);
    alu_op = control_signals::ALU_ADD;
    ctrl_signals[control_signals::CtrlAluInvertB] = 1;
    ctrl_signals[control_signals::CtrlAluCarryIn] = 0;
    case (current_instr_state)
      InstructionExec1: begin
        next_instr_state = InstructionExec2;
        current_data_bus_input = bus_sources::DataBusSrcDataIn;
        ctrl_signals[control_signals::CtrlLoadInputB] = 1;
      end
      InstructionExec2: begin
        next_instr_state = InstructionExec3;
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

  task exec_inc();
    case (current_instr_state)
      InstructionExec1: begin
        next_instr_state = InstructionExec2;
        current_data_bus_input = bus_sources::DataBusSrcRegAccumulator;
        ctrl_signals[control_signals::CtrlLoadInputB] = 1;
        ctrl_signals[control_signals::CtrlResetInputA] = 1;
      end
      InstructionExec2: begin
        next_instr_state = InstructionFetch;
        current_data_bus_input = bus_sources::DataBusSrcRegAluResult;
        ctrl_signals[control_signals::CtrlAluCarryIn] = 1;
        ctrl_signals[control_signals::CtrlLoadAccumulator] = 1;
        ctrl_signals[control_signals::CtrlUpdateFlagNegative] = 1;
        ctrl_signals[control_signals::CtrlUpdateFlagZero] = 1;
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

  task exec_iny();
    case (current_instr_state)
      InstructionExec1: begin
        next_instr_state = InstructionExec2;
        current_data_bus_input = bus_sources::DataBusSrcRegY;
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

  task exec_jsr();
    case (current_instr_state)
      InstructionExec1: begin
        next_instr_state = InstructionExec2;

        current_address_high_bus_input = bus_sources::AddressHighSrcStackPointer;
        current_address_low_bus_input = bus_sources::AddressLowSrcStackPointer;

        current_data_bus_input = bus_sources::DataBusSrcPCHigh;

        ctrl_signals[control_signals::CtrlRead0Write1] = 1;
        ctrl_signals[control_signals::CtrlDecStackPointer] = 1;
        ctrl_signals[control_signals::CtrlIncEnablePc] = 0;
      end
      InstructionExec2: begin
        next_instr_state = InstructionExec3;

        current_address_high_bus_input = bus_sources::AddressHighSrcStackPointer;
        current_address_low_bus_input = bus_sources::AddressLowSrcStackPointer;

        current_data_bus_input = bus_sources::DataBusSrcPCLow;

        ctrl_signals[control_signals::CtrlRead0Write1] = 1;
        ctrl_signals[control_signals::CtrlDecStackPointer] = 1;
        ctrl_signals[control_signals::CtrlIncEnablePc] = 0;
      end
      InstructionExec3: begin
        next_instr_state = InstructionFetch;

        ctrl_signals[control_signals::CtrlIncEnablePc] = 0;
        ctrl_signals[control_signals::CtrlLoadPc] = 1;
      end
    endcase
  endtask

  task exec_lda();
    case (current_instr_state)
      InstructionExec1: begin
        next_instr_state = InstructionFetch;
        current_data_bus_input = bus_sources::DataBusSrcDataIn;
        ctrl_signals[control_signals::CtrlLoadAccumulator] = 1;
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
        ctrl_signals[control_signals::CtrlIncStackPointer] = 1;
      end
      InstructionExec2: begin
        next_instr_state = InstructionFetch;
        current_data_bus_input = bus_sources::DataBusSrcDataIn;
        current_address_low_bus_input = bus_sources::AddressLowSrcStackPointer;
        current_address_high_bus_input = bus_sources::AddressHighSrcStackPointer;
        ctrl_signals[pull_src] = 1;
      end
      default: invalid_state();
    endcase
  endtask


  task exec_rti();
    case (current_instr_state)
      InstructionExec1: begin
        next_instr_state = InstructionExec2;
        ctrl_signals[control_signals::CtrlIncStackPointer] = 1;
      end
      InstructionExec2: begin
        next_instr_state = InstructionExec3;
        current_data_bus_input = bus_sources::DataBusSrcDataIn;
        current_address_low_bus_input = bus_sources::AddressLowSrcStackPointer;
        current_address_high_bus_input = bus_sources::AddressHighSrcStackPointer;
        ctrl_signals[control_signals::CtrlUpdateFlagZero] = 1;
        ctrl_signals[control_signals::CtrlUpdateFlagNegative] = 1;
        ctrl_signals[control_signals::CtrlUpdateFlagCarry] = 1;
        ctrl_signals[control_signals::CtrlUpdateFlagOverflow] = 1;
        ctrl_signals[control_signals::CtrlIncStackPointer] = 1;
        ctrl_signals[control_signals::CtrlClearInterruptDisable] = current_interrupt == InterruptIRQ;
      end
      InstructionExec3: begin
        next_instr_state = InstructionExec4;
        current_data_bus_input = bus_sources::DataBusSrcDataIn;
        current_address_low_bus_input = bus_sources::AddressLowSrcStackPointer;
        current_address_high_bus_input = bus_sources::AddressHighSrcStackPointer;
        ctrl_signals[control_signals::CtrlIncStackPointer] = 1;
      end
      InstructionExec4: begin
        next_instr_state = InstructionExec5;
        current_data_bus_input = bus_sources::DataBusSrcDataInLatch;
        current_address_low_bus_input = bus_sources::AddressLowSrcDataBus;
        current_address_high_bus_input = bus_sources::AddressHighSrcPcHigh;
        ctrl_signals[control_signals::CtrlLoadPc] = 1;
      end
      InstructionExec5: begin
        next_instr_state = InstructionExec6;
        current_data_bus_input = bus_sources::DataBusSrcDataIn;
        current_address_low_bus_input = bus_sources::AddressLowSrcStackPointer;
        current_address_high_bus_input = bus_sources::AddressHighSrcStackPointer;
      end
      InstructionExec6: begin
        next_instr_state = InstructionFetch;
        current_data_bus_input = bus_sources::DataBusSrcDataInLatch;
        current_address_low_bus_input = bus_sources::AddressLowSrcPcLow;
        current_address_high_bus_input = bus_sources::AddressHighSrcDataBus;
        ctrl_signals[control_signals::CtrlLoadPc] = 1;
      end
      default: invalid_state();
    endcase
  endtask

  task exec_rts();
    case (current_instr_state)
      InstructionExec1: begin
        next_instr_state = InstructionExec2;
        ctrl_signals[control_signals::CtrlIncStackPointer] = 1;
      end
      InstructionExec2: begin
        next_instr_state = InstructionExec3;

        current_data_bus_input = bus_sources::DataBusSrcDataIn;
        current_address_low_bus_input = bus_sources::AddressLowSrcStackPointer;
        current_address_high_bus_input = bus_sources::AddressHighSrcStackPointer;

        ctrl_signals[control_signals::CtrlIncStackPointer] = 1;
        ctrl_signals[control_signals::CtrlLoadAddrLow] = 1;
      end
      InstructionExec3: begin
        next_instr_state = InstructionExec4;

        current_data_bus_input = bus_sources::DataBusSrcDataIn;
        current_address_low_bus_input = bus_sources::AddressLowSrcStackPointer;
        current_address_high_bus_input = bus_sources::AddressHighSrcStackPointer;

        ctrl_signals[control_signals::CtrlLoadAddrHigh] = 1;
      end
      InstructionExec4: begin
        next_instr_state = InstructionFetch;

        current_address_low_bus_input = bus_sources::AddressLowSrcAddrLowReg;
        current_address_high_bus_input = bus_sources::AddressHighSrcAddrHighReg;

        ctrl_signals[control_signals::CtrlIncEnablePc] = 0;
        ctrl_signals[control_signals::CtrlLoadPc] = 1;
      end
      default: invalid_state();
    endcase
  endtask

  task exec_sei();
    case (current_instr_state)
      InstructionExec1: begin
        next_instr_state = InstructionFetch;
        ctrl_signals[control_signals::CtrlSetInterruptDisable] = 1;
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

  task exec_transfer(bus_sources::data_bus_source_t src,
                     control_signals::ctrl_signals_t load_target);
    case (current_instr_state)
      InstructionExec1: begin
        next_instr_state = InstructionFetch;
        current_data_bus_input = src;
        ctrl_signals[load_target] = 1;
      end
    endcase
  endtask

  task exec_txs();
    case (current_instr_state)
      InstructionExec1: begin
        next_instr_state = InstructionFetch;
        current_address_low_bus_input = bus_sources::AddressLowSrcStackPointer;
        current_data_bus_input = bus_sources::DataBusSrcAddrLowBus;
        ctrl_signals[control_signals::CtrlLoadX] = 1;
      end
    endcase
  endtask

  task exec_tsx();
    case (current_instr_state)
      InstructionExec1: begin
        next_instr_state = InstructionFetch;
        current_data_bus_input = bus_sources::DataBusSrcRegX;
        current_address_low_bus_input = bus_sources::AddressLowSrcDataBus;
        ctrl_signals[control_signals::CtrlLoadStackPointer] = 1;
      end
    endcase
  endtask

endmodule
