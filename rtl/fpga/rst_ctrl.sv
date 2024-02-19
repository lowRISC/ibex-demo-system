// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// Produces an active-low power-on-reset (PoR) on output `rst_no`. A reset will only happen once
// `pll_locked_i` is set to indicate the systems PLL(s) have locked and clock(s) are stable. Further
// resets can be triggered by the 'rst_btn_i' input (active high). This input is debounced so it can
// be easily connected to a physical button.
//
// The PoR has three phases:
// * phase 0 - Reset is left deasserted
// * phase 1 - Reset is asserted and held asserted (giving a negative edge on rst_no from phase 0 to
//   phase 1)
// * phase 2 - Reset is deasserted (giving a positive edge on rst_no from phase 1 to phase 2)
//
// The 'ResetPhase0Count' and 'ResetPhase1Count' specify the length of time for phase 0 and phase
// 1 in clock cycles (phase 2 is an unbounded length)
//
// When 'rst_btn_i' is asserted (set to 1) the controller is held at the beginning of phase 1 (reset
// is asserted, and a negative edge seen on `rst_no` when the debounced `rst_btn_i` is first
// asserted). It proceds to phase 2 as normal when the debounced `rst_btn_i` is deasserted.
//
// Debouncing of `rst_btn_i` occurs internally to the module. The `rst_btn_i` input must be in
// a single state for more than `DebounceCount` cycles for that state to take effect.
//
// If the `pll_locked_i` input goes low a new reset will be produced when it goes high again.
//
// The provided `clk_i` is assumed to always be stable and must be independent of the output reset
// `rst_no` and of the PLL providing the `pll_locked_i` input.
//
// The `rst_no` signal is produced directly from a flop to prevent glitches. This flop is clocked
// from `clk_i`.
//
// This module is designed for FPGA implementation as it relies on an 'initial' statement to set the
// power-on contents of registers.

module rst_ctrl #(
  parameter int unsigned ResetPhase0Count = 5,
  parameter int unsigned ResetPhase1Count = 200,
  parameter int unsigned DebounceCount    = 500
) (
  input clk_i,
  input pll_locked_i,
  input rst_btn_i,

  output rst_no
);
  localparam CounterWidth = $clog2(ResetPhase1Count + 1);

  logic [CounterWidth-1:0] reset_counter_d, reset_counter_q;
  logic rst_btn_debounce;
  logic rst_n_d, debounce_rst_n_d, rst_n_q, debounce_rst_n_q;

  initial begin
    reset_counter_q = '0;
    rst_n_q = 1'b1;
    debounce_rst_n_q = 1'b1;
  end

  always_comb begin
    reset_counter_d = reset_counter_q;

    // The output is driven when the counter is between the value of phase
    // 0 and phase 1. When a press on the reset button is detected, we can
    // reset the counter value and make sure that the reset pulse is the same
    // length as when we reset the system at startup.
    if (rst_btn_debounce && (reset_counter_q >= ResetPhase0Count)) begin
      reset_counter_d = ResetPhase0Count;
    end else begin
      if (pll_locked_i) begin
        if (reset_counter_q < ResetPhase1Count) begin
          reset_counter_d <= reset_counter_d + 1;
        end
      end else begin
        reset_counter_d = '0;
      end
    end
  end

  always_ff @(posedge clk_i) begin
    reset_counter_q  <= reset_counter_d;
    rst_n_q          <= rst_n_d;
    debounce_rst_n_q <= debounce_rst_n_d;
  end

  debounce #(.ClkCount(DebounceCount)) u_rst_btn_debounce (
    .clk_i,
    .rst_ni(debounce_rst_n_q),

    .btn_i(rst_btn_i),
    .btn_o(rst_btn_debounce)
  );

  assign rst_n_d = reset_counter_q < ResetPhase0Count ? 1'b1 :
                   reset_counter_q < ResetPhase1Count ? 1'b0 :
                                                        1'b1;

  assign debounce_rst_n_d = reset_counter_q <= ResetPhase0Count ? 1'b1 :
                            reset_counter_q <  ResetPhase1Count ? 1'b0 :
                                                                  1'b1;
  assign rst_no = rst_n_q;
endmodule
