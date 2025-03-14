// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// This is the top level SystemVerilog file that connects the IO on the board to the Ibex Demo System.
module top_artys7 (
    // These inputs are defined in data/pins_nexysa7.xdc
    input               IO_CLK,
    input               IO_RST,
    input  [3:0]        SW,
    input  [2:0]        BTN,
    output [3:0]        LED,
    output [5:0]        RGB_LED,
    input               UART_RX,
    output              UART_TX
  );
    parameter SRAMInitFile = "";

    logic clk_sys, rst_sys_n;

    // Instantiating the Ibex Demo System.
    ibex_demo_system #(
      .GpiWidth(7),
      .GpoWidth(4),
      .PwmWidth(6),
      .SRAMInitFile(SRAMInitFile)
    ) u_ibex_demo_system (
      //input
      .clk_sys_i(clk_sys),
      .rst_sys_ni(rst_sys_n),
      .gp_i({SW, BTN}),
      .uart_rx_i(UART_RX),

      //output
      .gp_o(LED),
      .pwm_o(RGB_LED),
      .uart_tx_o(UART_TX),

      .spi_rx_i(1'b0),
      .spi_tx_o(),
      .spi_sck_o(),

      .trst_ni(1'b1),
      .tms_i  (1'b0),
      .tck_i  (1'b0),
      .td_i   (1'b0),
      .td_o   ()
    );

    logic IO_RST_N;
    assign IO_RST_N = ~IO_RST;

    // Generating the system clock and reset for the FPGA.
    // Arty S7 has a 100 MHz clock.
    clkgen_xil7series clkgen(
      .IO_CLK,
      .IO_RST_N,
      .clk_sys,
      .rst_sys_n
    );

  endmodule
