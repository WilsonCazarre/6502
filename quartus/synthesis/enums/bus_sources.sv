package bus_sources;
  typedef enum logic [15:0] {
    DataBusSrcRegAccumulator,
    DataBusSrcRegX,
    DataBusSrcRegY,
    DataBusSrcRegAluResult,

    DataBusSrcFF,
    DataBusSrcZero,

    DataBusSrcDataIn,
    DataBusSrcDataInLatch,

    DataBusSrcAddrLowBus,
    DataBusSrcAddrHighBus,

    DataBusSrcPCHigh,
    DataBusSrcPCLow,

    DataBusSrcStatusRegister,

    DataBusSrcEndMarker
  } data_bus_source_t;

  typedef enum logic [15:0] {
    AddressLowSrcPcLow,

    AddressLowSrcDataIn,
    AddressLowSrcDataInLatch,

    AddressLowSrcAddrLowReg,
    AddressLowSrcZero,

    AddressLowSrcFA,
    AddressLowSrcFB,
    AddressLowSrcFC,
    AddressLowSrcFD,
    AddressLowSrcFE,
    AddressLowSrcFF,

    AddressLowSrcStackPointer,
    AddressLowSrcDataBus,

    AddressLowSrcEndMarker
  } address_low_bus_source_t;

  typedef enum logic [15:0] {
    AddressHighSrcPcHigh,

    AddressHighSrcDataIn,
    AddressHighSrcDataInLatch,

    AddressHighSrcAddrHighReg,

    AddressHighSrcZero,
    AddressHighSrcFF,

    AddressHighSrcStackPointer,
    AddressHighSrcDataBus,

    AddressHighSrcEndMarker
  } address_high_bus_source_t;

endpackage
