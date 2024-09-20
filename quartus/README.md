# Microcomputer project based on 6502

This project aims to implement a computer system with the 6502 microprocessor
at its core.

## Project Structure

| **Folder or File** |                                        **Description**                                         |
| :----------------: | :--------------------------------------------------------------------------------------------: |
|     synthesis      | Syntesizeable SystemVerilog Files. The actual circuit implementations meant to run on an FPGA. |
|    testbenches     |  Simulation files. Can be used to test the project in a virtual environment such as ModelSim   |
|     waveforms      |                          Waveforms generated for the academic report                           |
|      snippets      |  6502 assembly files and a python helper script to convert them in Quartus acceptable format   |

On the synthesis folder:

- `dev.sv` - this is the top-level file it's supposed to represent the connections
  between the microprocessor and the DE2-115 dev board like in the image attached
  below
  ![DE2-115 connections](../assets/img/dev.png)
- `cpu6502.sv` the actual microprocessor core implementation
- `interface_adapter.sv` roughly based on the 6522 versatile interface adapter,
  provides 16 GPIO pins for the computer.
