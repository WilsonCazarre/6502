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

    AddressLowSrcEndMarker
  } address_low_bus_source_t;

  typedef enum logic [15:0] {
    AddressHighSrcPcHigh,

    AddressHighSrcDataIn,
    AddressHighSrcDataInLatch,

    AddressHighSrcEndMarker
  } address_high_bus_source_t;

endpackage
