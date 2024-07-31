typedef enum logic [3:0] {
  ORB_IRB,
  ORA_IRA,
  DDRB,
  DDRA,
  CtrlRegisterEndMarker
} ctrl_register;


module interface_adapter (
    input  logic [7:0] port_a_in,
    output logic [7:0] port_a_out,

    input  logic [7:0] port_b_in,
    output logic [7:0] port_b_out,

    input  logic [7:0] data_in,
    output logic [7:0] data_out,

    input logic [3:0] register_select,
    input logic chip_en1,

    input logic clk,
    input logic reset,
    input logic readb_write
);


  typedef enum logic [3:0] {
    IDLE,
    READ_PORT_A,
    READ_PORT_B,
    WRITE_PORT_A,
    WRITE_PORT_B
  } ctrl_state;

  logic [7:0] ctrl_registers[CtrlRegisterEndMarker];
  logic [7:0] port_a, port_b;

  assign port_a_out = port_a;
  assign port_b_out = port_b;

  ctrl_state current_state, next_state;

  always_ff @(posedge clk) begin
    if (reset) begin
      ctrl_registers <= '{default: '0};
      port_a <= 8'h0;
      port_b <= 8'h0;
    end else
    if (!chip_en1) begin

    end else begin
      case (register_select)
        DDRA: ctrl_registers[DDRA] <= data_in;
        DDRB: ctrl_registers[DDRB] <= data_in;
        ORA_IRA: begin
          for (int i = 0; i < 8; i++) begin
            if (ctrl_registers[DDRA][i]) begin
              port_a[i] <= data_in[i];
            end else begin
              data_out[i] <= port_a_in[i];
              port_a[i]   <= port_a_in[i];
            end
          end
        end
        ORB_IRB: begin
          for (int i = 0; i < 8; i++) begin
            if (ctrl_registers[DDRB][i]) begin
              port_b[i] <= data_in[i];
            end else begin
              data_out[i] <= port_b_in[i];
              port_b[i]   <= port_b_in[i];
            end
          end
        end
      endcase
    end
  end

endmodule
