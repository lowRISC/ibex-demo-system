// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// This is the top level SystemVerilog file that connects the IO on the board to the Ibex Demo System.
module top_pynqz2 (
  // These inputs are defined in data/pins_pynqz2.xdc
  input               IO_CLK,
  input               IO_RST,
  input  [1:0]        SW,
  input  [2:0]        BTN,
  output [3:0]        LED,
  output [3:0]        GPIOS,
  output [5:0]        RGB_LED,
  input               UART_RX,
  output              UART_TX,
  input               SPI_RX,
  output              SPI_TX,
  output              SPI_SCK
);
  parameter SRAMInitFile = "";

  logic clk_sys, rst_sys_n;

  // Instantiating the Ibex Demo System.
  ibex_demo_system #(
    .GpiWidth(5),
    .GpoWidth(8),
    .PwmWidth(6),
    .SRAMInitFile(SRAMInitFile)
  ) u_ibex_demo_system (
    //input
    .clk_sys_i(clk_sys),
    .rst_sys_ni(rst_sys_n),
    .gp_i({SW, BTN}),
    .uart_rx_i(UART_RX),

    //output
    .gp_o({LED, GPIOS}),
    .pwm_o(RGB_LED),
    .uart_tx_o(UART_TX),

    .spi_rx_i(SPI_RX),
    .spi_tx_o(SPI_TX),
    .spi_sck_o(SPI_SCK)
  );

  logic IO_RST_N;
  assign IO_RST_N = ~IO_RST;

  // Generating the system clock and reset for the FPGA.
  clkgen_pynqz2 clkgen(
    .IO_CLK,
    .IO_RST_N,
    .clk_sys,
    .rst_sys_n
  );

endmodule
