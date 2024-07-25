package bus_sources;
  typedef enum logic [15:0] {
    DataBusSrcRegAccumulator,
    DataBusSrcRegX,
    DataBusSrcRegY,
    DataBusSrcRegAluResult,

    DataBusSrcFF,

    DataBusSrcDataIn,
    DataBusSrcDataInLatch,

    DataBusSrcEndMarker
  } data_bus_source_t;

  typedef enum logic [15:0] {
    AddressLowSrcPcLow,

    AddressLowSrcDataIn,
    AddressLowSrcDataInLatch,

    AddressLowSrcAddrLowReg,

    AddressLowSrcEndMarker
  } address_low_bus_source_t;

  typedef enum logic [15:0] {
    AddressHighSrcPcHigh,

    AddressHighSrcDataIn,
    AddressHighSrcDataInLatch,

    AddressHighSrcAddrHighReg,

    AddressHighSrcEndMarker
  } address_high_bus_source_t;

endpackage
