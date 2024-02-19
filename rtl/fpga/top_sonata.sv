// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// Ibex demo system top level for the Sonata board
module top_sonata (
  input              main_clk,
  input              nrst_btn,

  output logic [7:0] led_user,
  output logic       led_bootok,
  output logic       led_halted,
  output logic       led_cheri,
  output logic       led_legacy,
  output logic [8:0] led_cherierr,

  input  logic [4:0] nav_sw,
  input  logic [7:0] user_sw,

  output logic lcd_rst,
  output logic lcd_dc,
  output logic lcd_copi,
  output logic lcd_clk,
  output logic lcd_cs,
  output logic lcd_backlight,

  output logic ser0_tx,
  input  logic ser0_rx,

  input  logic tck_i,
  input  logic tms_i,
  input  logic td_i,
  output logic td_o
);
  parameter SRAMInitFile = "";

  logic mainclk_buf;
  logic clk_sys;
  logic rst_sys_n;
  logic [7:0] reset_counter;

  logic [4:0] nav_sw_n;
  logic [7:0] user_sw_n;

  logic pll_locked;
  logic rst_btn;


  assign led_bootok = rst_sys_n;

  // Switch inputs have pull-ups and switches pull to ground when on. Invert here so CPU sees 1 for
  // on and 0 for off.
  assign nav_sw_n = ~nav_sw;
  assign user_sw_n = ~user_sw;

  ibex_demo_system #(
    .GpiWidth(13),
    .GpoWidth(12),
    .PwmWidth(12),
    .SRAMInitFile(SRAMInitFile)
  ) u_ibex_demo_system (
    .clk_sys_i(clk_sys),
    .rst_sys_ni(rst_sys_n),

    .gp_i({user_sw_n, nav_sw_n}),
    .gp_o({led_user, lcd_backlight, lcd_dc, lcd_rst, lcd_cs}),

    .uart_rx_i(ser0_rx),
    .uart_tx_o(ser0_tx),

    .pwm_o({led_cherierr, led_legacy, led_cheri, led_halted}),

    .spi_rx_i(1'b0),
    .spi_tx_o(lcd_copi),
    .spi_sck_o(lcd_clk),

    .trst_ni(rst_sys_n),
    .tms_i,
    .tck_i,
    .td_i,
    .td_o
  );

  // Produce 50 MHz system clock from 25 MHz Sonata board clock
  clkgen_sonata clkgen(
    .IO_CLK(main_clk),
    .IO_CLK_BUF(mainclk_buf),
    .clk_sys,
    .locked(pll_locked)
  );

  assign rst_btn = ~nrst_btn;

  rst_ctrl u_rst_ctrl (
    .clk_i       (mainclk_buf),
    .pll_locked_i(pll_locked),
    .rst_btn_i   (rst_btn),
    .rst_no      (rst_sys_n)
  );
endmodule
