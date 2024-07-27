package instruction_set;

  typedef enum logic [7:0] {
    OpcADC_imm  = 8'h69,
    OpcADC_abs  = 8'h6d,
    OpcADC_absx = 8'h7d,

    OpcAND_imm  = 8'h29,
    OpcAND_abs  = 8'h2d,
    OpcAND_absx = 8'h3d,

    OpcBCC_abs = 8'h90,
    OpcBCS_abs = 8'hb0,
    OpcBEQ_abs = 8'hf0,
    OpcBMI_abs = 8'h30,
    OpcBNE_abs = 8'hd0,
    OpcBPL_abs = 8'h10,
    OpcBVC_abs = 8'h50,
    OpcBVS_abs = 8'h70,

    OpcCLC_impl = 8'h18,

    OpcCMP_imm  = 8'hc9,
    OpcCMP_abs  = 8'hcd,
    OpcCMP_absx = 8'hdd,

    OpcCPX_imm = 8'he0,
    OpcCPX_abs = 8'hec,

    OpcCPY_imm = 8'hc0,
    OpcCPY_abs = 8'hcc,

    OpcEOR_imm  = 8'h49,
    OpcEOR_abs  = 8'h4d,
    OpcEOR_absx = 8'h5d,

    OpcINX_impl = 8'he8,

    OpcJMP_abs = 8'h4c,

    OpcLDA_imm  = 8'ha9,
    OpcLDA_abs  = 8'had,
    OpcLDA_absx = 8'hbd,

    OpcLDX_imm = 8'ha2,
    OpcLDX_abs = 8'hae,

    OpcLDY_imm  = 8'ha0,
    OpcLDY_abs  = 8'hac,
    OpcLDY_absx = 8'hbc,

    OpcNOP_impl = 8'hea,

    OpcORA_imm  = 8'h09,
    OpcORA_abs  = 8'h0d,
    OpcORA_absx = 8'h1d,

    OpcPHA_impl = 8'h48,
    OpcPHX_impl = 8'hda,
    OpcPHY_impl = 8'h5a,

    OpcPLA_impl = 8'h68,
    OpcPLX_impl = 8'hfa,
    OpcPLY_impl = 8'h7a,

    OpcSBC_imm  = 8'he9,
    OpcSBC_abs  = 8'hed,
    OpcSBC_absx = 8'hfd,

    OpcSEC_impl = 8'h38,

    OpcSTA_abs  = 8'h8d,
    OpcSTA_absx = 8'h9d,

    OpcSTX_abs = 8'h8e,

    OpcSTY_abs = 8'h8c
  } opcode_t;

  typedef enum logic [7:0] {
    AddrModeImm,
    AddrModeAbs,
    AddrModeAbsX,
    AddrModeStack,
    AddrModeImpl
  } address_mode_t;

endpackage
