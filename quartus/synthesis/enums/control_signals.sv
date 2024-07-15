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
    CtrlPcIncEnable = 6,
    CtrlPcLoad = 7,

    CtrlSignalEndMarker
  } ctrl_signals_t;

  typedef enum logic [31:0] {
    StatusFlagCarry,
    StatusFlagOverflow,
    StatusFlagNegative,
    StatusFlagZero,
    StatusFlagEndMarker

  } status_flags_t;

endpackage
