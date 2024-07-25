package instruction_set;

  typedef enum logic [7:0] {
    OpcADC_imm = 8'h69,
    OpcADC_abs = 8'h6d,

    OpcBCC_abs = 8'h90,
    OpcBCS_abs = 8'hb0,
    OpcBEQ_abs = 8'hf0,
    OpcBMI_abs = 8'h30,
    OpcBNE_abs = 8'hd0,
    OpcBPL_abs = 8'h10,
    OpcBVC_abs = 8'h50,
    OpcBVS_abs = 8'h70,

    OpcCLC_impl = 8'h18,

    OpcCMP_imm = 8'hc9,
    OpcCMP_abs = 8'hcd,

    OpcJMP_abs = 8'h4c,

    OpcLDA_imm = 8'ha9,
    OpcLDA_abs = 8'had,

    OpcLDX_imm = 8'ha2,
    OpcLDX_abs = 8'hae,

    OpcLDY_imm = 8'ha0,
    OpcLDY_abs = 8'hac,

    OpcNOP_impl = 8'hea,

    OpcSBC_imm = 8'he9,
    OpcSBC_abs = 8'hed,

    OpcSEC_impl = 8'h38,

    OpcSTA_abs = 8'h8d,

    OpcSTX_abs = 8'h8e,

    OpcSTY_abs = 8'h8c
  } opcode_t;

  typedef enum logic [7:0] {
    AddrModeImm,
    AddrModeAbs,
    AddrModeImpl
  } address_mode_t;

endpackage
