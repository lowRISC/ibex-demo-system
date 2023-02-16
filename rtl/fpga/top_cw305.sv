// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// This is the top level SystemVerilog file that connects the IO on the board to the Ibex Demo System.
module top_cw305 (
  // These inputs are defined in data/pins_cw305.xdc
  input               IO_CLK,
  input               IO_RST_N,
  input  [ 3:0]       SW,
  output [ 2:0]       LED,
  output [11:0]       RGB_LED,
  input               UART_RX,
  output              UART_TX
);
  parameter SRAMInitFile = "";

  logic clk_sys, rst_sys_n;

  // Instantiating the Ibex Demo System.
  ibex_demo_system #(
    .GpiWidth(3),
    .GpoWidth(3),
    .PwmWidth(12),
    .SRAMInitFile(SRAMInitFile)
  ) u_ibex_demo_system (
    //input
    .clk_sys_i(clk_sys),
    .rst_sys_ni(rst_sys_n),
    .gp_i(SW),
    .uart_rx_i(UART_RX),

    //output
    .gp_o(LED),
    .pwm_o(RGB_LED),
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
