package instruction_set;

  typedef enum logic [7:0] {
    OpcADC_imm = 8'h69,
    OpcADC_abs = 8'h6d,

    OpcLDA_imm = 8'ha9,
    OpcLDA_abs = 8'had,

    OpcSTA_abs = 8'h8d,

    OpcJMP_abs = 8'h4c,

    OpcNOP_impl = 8'hea
  } opcode_t;

  typedef enum logic [7:0] {
    AddrModeImm,
    AddrModeAbs,
    AddrModeImpl
  } address_mode_t;

endpackage
