package instruction_set;

  typedef enum logic [7:0] {
    // 120/149
    OpcADC_imm  = 8'h69,
    OpcADC_abs  = 8'h6d,
    OpcADC_absx = 8'h7d,
    OpcADC_absy = 8'h79,
    OpcADC_indx = 8'h61,
    OpcADC_zpg  = 8'h65,

    OpcAND_imm  = 8'h29,
    OpcAND_abs  = 8'h2d,
    OpcAND_absx = 8'h3d,
    OpcAND_absy = 8'h39,
    OpcAND_indx = 8'h21,
    OpcAND_zpg  = 8'h25,

    OpcASL_abs  = 8'h0e,
    OpcASL_absx = 8'h1e,
    OpcASL_acc  = 8'h0a,
    OpcASL_zpg  = 8'h06,
    OpcASL_zpgx = 8'h16,

    OpcBCC_abs = 8'h90,
    OpcBCS_abs = 8'hb0,
    OpcBEQ_abs = 8'hf0,
    OpcBMI_abs = 8'h30,
    OpcBNE_abs = 8'hd0,
    OpcBPL_abs = 8'h10,
    OpcBVC_abs = 8'h50,
    OpcBVS_abs = 8'h70,

    OpcBRK_impl = 8'h00,

    OpcCLC_impl = 8'h18,
    OpcCLI_impl = 8'h58,

    OpcCMP_imm  = 8'hc9,
    OpcCMP_abs  = 8'hcd,
    OpcCMP_absx = 8'hdd,
    OpcCMP_absy = 8'hd9,
    OpcCMP_indx = 8'hc1,
    OpcCMP_zpg  = 8'hc5,

    OpcCPX_imm = 8'he0,
    OpcCPX_abs = 8'hec,
    OpcCPX_zpg = 8'he4,

    OpcCPY_imm = 8'hc0,
    OpcCPY_abs = 8'hcc,
    OpcCPY_zpg = 8'hc4,

    OpcEOR_imm  = 8'h49,
    OpcEOR_abs  = 8'h4d,
    OpcEOR_absx = 8'h5d,
    OpcEOR_absy = 8'h59,
    OpcEOR_indx = 8'h41,
    OpcEOR_zpg  = 8'h45,

    OpcINX_impl = 8'he8,

    OpcINY_impl = 8'hc8,

    OpcJMP_abs = 8'h4c,
    OpcJMP_ind = 8'h6c,

    OpcJSR_abs = 8'h20,

    OpcLDA_imm  = 8'ha9,
    OpcLDA_abs  = 8'had,
    OpcLDA_absx = 8'hbd,
    OpcLDA_absy = 8'hb9,
    OpcLDA_indx = 8'ha1,
    OpcLDA_zpg  = 8'ha5,
    OpcLDA_zpgx = 8'hb5,

    OpcLDX_imm  = 8'ha2,
    OpcLDX_abs  = 8'hae,
    OpcLDX_absy = 8'hbe,
    OpcLDX_zpg  = 8'ha6,

    OpcLDY_imm  = 8'ha0,
    OpcLDY_abs  = 8'hac,
    OpcLDY_absx = 8'hbc,
    OpcLDY_zpg  = 8'ha4,

    OpcLSR_abs  = 8'h4e,
    OpcLSR_absx = 8'h5e,
    OpcLSR_acc  = 8'h4a,
    OpcLSR_zpg  = 8'h46,
    OpcLSR_zpgx = 8'h56,

    OpcNOP_impl = 8'hea,

    OpcORA_imm  = 8'h09,
    OpcORA_abs  = 8'h0d,
    OpcORA_absx = 8'h1d,
    OpcORA_absy = 8'h19,
    OpcORA_indx = 8'h01,
    OpcORA_zpg  = 8'h05,

    OpcPHA_impl = 8'h48,
    OpcPHX_impl = 8'hda,
    OpcPHY_impl = 8'h5a,

    OpcPLA_impl = 8'h68,
    OpcPLX_impl = 8'hfa,
    OpcPLY_impl = 8'h7a,

    OpcROL_abs  = 8'h2e,
    OpcROL_absx = 8'h3e,
    OpcROL_acc  = 8'h2a,
    OpcROL_zpg  = 8'h26,
    OpcROL_zpgx = 8'h36,

    OpcROR_abs  = 8'h6e,
    OpcROR_absx = 8'h7e,
    OpcROR_acc  = 8'h6a,
    OpcROR_zpg  = 8'h66,
    OpcROR_zpgx = 8'h76,

    OpcRTI_impl = 8'h40,
    OpcRTS_impl = 8'h60,

    OpcSBC_imm  = 8'he9,
    OpcSBC_abs  = 8'hed,
    OpcSBC_absx = 8'hfd,
    OpcSBC_absy = 8'hf9,
    OpcSBC_indx = 8'he1,
    OpcSBC_zpg  = 8'he5,

    OpcSEC_impl = 8'h38,
    OpcSEI_impl = 8'h78,

    OpcSTA_abs  = 8'h8d,
    OpcSTA_absx = 8'h9d,
    OpcSTA_absy = 8'h99,
    OpcSTA_indx = 8'h81,
    OpcSTA_zpg  = 8'h85,
    OpcSTA_zpgx = 8'h95,

    OpcSTX_abs = 8'h8e,
    OpcSTX_zpg = 8'h86,

    OpcSTY_abs = 8'h8c,
    OpcSTY_zpg = 8'h84,

    OpcTAX_impl = 8'haa,
    OpcTAY_impl = 8'ha8,
    OpcTSX_impl = 8'hba,
    OpcTXA_impl = 8'h8a,
    OpcTXS_impl = 8'h9a,
    OpcTYA_impl = 8'h98
  } opcode_t;

  typedef enum logic [7:0] {
    AddrModeImm,
    AddrModeAbs,
    AddrModeAbsX,
    AddrModeAbsY,
    AddrModeAcc,
    AddrModeInd,
    AddrModeIndX,
    AddrModeStack,
    AddrModeImpl,
    AddrModeZpg,
    AddrModeZpgX,
    AddrModeRel
  } address_mode_t;

endpackage
