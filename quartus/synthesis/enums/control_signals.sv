package control_signals;

  typedef enum logic [3:0] {
    ALU_ADD,
    ALU_SUB,
    ALU_AND,
    ALU_OR,
    ALU_XOR,
    ALU_SHIFT_LEFT
  } alu_op_t;

  typedef enum logic [31:0] {
    CtrlLoadAccumutator = 0,
    CtrlLoadX = 1,
    CtrlLoadY = 2,
    CtrlLoadInputA = 3,
    CtrlLoadInputB = 4,
    CtrlLoadInstReg = 5,
    CtrlIncEnablePc = 6,
    CtrlLoadPc = 7,
    CtrlLoadStatusReg = 8,
    CtrlRead0Write1 = 9,
    CtrlLoadAddrLow = 10,
    CtrlLoadAddrHigh = 11,
    CtrlUpdateFlagCarry = 12,
    CtrlUpdateFlagOverflow = 13,
    CtrlUpdateFlagNegative = 14,
    CtrlUpdateFlagZero = 15,
    CtrlSetFlagCarry = 16,
    CtrlSetFlagOverflow = 17,
    CtrlClearFlagCarry = 18,
    CtrlClearFlagOverflow = 19,
    CtrlIncAddressHighReg = 20,
    CtrlDecAddressHighReg = 21,
    CtrlAluCarryIn = 22,
    CtrlResetInputA = 23,
    CtrlLoadStackPointer = 24,
    CtrlIncStackPointer = 25,
    CtrlDecStackPointer = 26,
    CtrlAluInvertB = 27,

    CtrlSignalEndMarker
  } ctrl_signals_t;

  typedef enum logic [31:0] {
    StatusFlagNegative,
    StatusFlagOverflow,
    StatusFlagCarry,
    StatusFlagZero,

    StatusFlagEndMarker
  } status_flags_t;

endpackage
