// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// This is the top level SystemVerilog file that connects the IO on the board to the Ibex Demo System.
module top_cw312a35 (
  // These inputs are defined in data/pins_cw305.xdc
  input  logic          IO_CLK,
  input  logic          IO_RST_N,
  input  logic          IO3,
  output logic          IO4,
  output logic [ 2:0]   LED,
  input  logic          UART_RX,
  output logic          UART_TX
);
  parameter SRAMInitFile = "";

  logic clk_sys, rst_sys_n;
  reg [24:0] clock_heartbeat;

  assign LED[0] = clock_heartbeat[24];
  assign LED[1] = ~UART_RX || ~UART_TX;
  assign LED[2] = IO4;

  always @(posedge clk_sys) clock_heartbeat <= clock_heartbeat +  25'd1;

  // Instantiating the Ibex Demo System.
  ibex_demo_system #(
    .GpiWidth(1),
    .GpoWidth(1),
    .PwmWidth(1),
    .SRAMInitFile(SRAMInitFile)
  ) u_ibex_demo_system (
    //input
    .clk_sys_i(clk_sys),
    .rst_sys_ni(rst_sys_n),
    .gp_i(IO3),
    .uart_rx_i(UART_RX),

    //output
    .gp_o(IO4),
    .pwm_o(),
    .uart_tx_o(UART_TX),

    .spi_rx_i(1'b0),
    .spi_tx_o(),
    .spi_sck_o()
  );

  // Generating the system clock and reset for the FPGA.
  clkgen_xil7series clkgen(
    .IO_CLK,
    .IO_RST_N,
    .clk_sys,
    .rst_sys_n
  );

endmodule
