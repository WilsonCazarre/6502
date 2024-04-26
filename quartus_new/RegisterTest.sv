module RegisterTest ();

  reg[7:0] data_bus;
  reg reset;

  reg bus_enable_a, bus_enable_b;
  reg load_a, load_b;


  Register A (
     .data(data_bus),
     .bus_enable(bus_enable_a),
     .load(load_b),
     .reset(reset)
  );

  Register B (
     .data(data_bus),
     .bus_enable(bus_enable_b),
     .load(load_b),
     .reset(reset)
  );

  initial begin
    reset=1;
    load_a=0;
    load_b=0;
    #5
  end

  
endmodule