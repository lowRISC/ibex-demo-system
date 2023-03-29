// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// This is the top level SystemVerilog file that connects the IO on the board to the Ibex Demo System.
module top_cw305 (
  // These inputs are defined in data/pins_cw305.xdc
  input  logic          I_pll_clk1,
  input  logic          I_cw_clkin,
  input  logic          IO_RST_N,
  input  logic          IO3,
  input  logic          J16,
  input  logic          K16,
  input  logic          L14,
  input  logic          K15,
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
    .GpiWidth(5),
    .GpoWidth(1),
    .PwmWidth(1),
    .SRAMInitFile(SRAMInitFile)
  ) u_ibex_demo_system (
    //input
    .clk_sys_i(clk_sys),
    .rst_sys_ni(rst_sys_n),
    .gp_i({IO3, K15, L14, K16, J16}),
    .uart_rx_i(UART_RX),

    //output
    .gp_o(IO4),
    .pwm_o(),
    .uart_tx_o(UART_TX),

    .spi_rx_i(1'b0),
    .spi_tx_o(),
    .spi_sck_o()
  );

  // clock source select:
  logic chosen_clock;
  BUFGMUX_CTRL U_clock_source_select (
     .O         (chosen_clock),
     .I0        (I_pll_clk1),
     .I1        (I_cw_clkin),
     .S         (J16) // J16 selects the clock; 0=on-board PLL, 1=from CW HS2 pin
  );    


  // Generating the system clock and reset for the FPGA.
  clkgen_xil7series clkgen(
    .IO_CLK     (chosen_clock),
    .IO_RST_N,
    .clk_sys,
    .rst_sys_n
  );

endmodule
