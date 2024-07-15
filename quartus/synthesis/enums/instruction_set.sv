package instruction_set;

  typedef enum logic [7:0] {
    OpcADC_imm = 8'h69,

    OpcLDA_imm = 8'ha9,
    OpcLDA_abs = 8'had,

    OpcNOP = 8'hea
  } opcode_t;

  typedef enum logic [7:0] {
    AddrModeImmdiate,
    AddrModeAbs,
    AddrModeImpl
  } address_mode_t;

endpackage
