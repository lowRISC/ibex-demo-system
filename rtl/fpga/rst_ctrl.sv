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

    // Ignore the reset button whilst in phase 0 (indicating we've just had power on and we're doing
    // the PoR or a new reset is happening due to the PLL loosing lock.
    if (rst_btn_debounce && (reset_counter_q >= ResetPhase0Count)) begin
      // When the reset button is pushed immediately move to phase 1 causing the reset to be
      // asserted. We hold at the beginning of phase 1 with an asserted reset, without counting,
      // until the reset button is released.
      reset_counter_d = ResetPhase0Count;
    end else begin
      // Only increment reset counter when the reset button isn't pushed and the PLL is locked
      if (pll_locked_i) begin
        if (reset_counter_q < ResetPhase1Count) begin
          // At the end of phase 1 we're in phase 2 which has unbounded length so stop counting
          reset_counter_d <= reset_counter_d + 1;
        end
      end else begin
        // Hold reset counter at 0 when PLL isn't locked. When PLL locks we'll proceed through
        // phase 0/phase 1/phase 2 exactly the same as a PoR.
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

  // Set reset output depending upon the phase
  assign rst_n_d = reset_counter_q < ResetPhase0Count ? 1'b1 :
                   reset_counter_q < ResetPhase1Count ? 1'b0 :
                                                        1'b1;

  // Debouncer reset follows the same pattern as the output reset other than for the phase 0 ->
  // phase 1 transition. This happens one reset counter cycle later so that when the reset button is
  // pushed the debouncer doesn't get reset as the counter is held at the beginning of phase 1. When
  // the button is released the counter will start incrementing and reset the debouncer.
  assign debounce_rst_n_d = reset_counter_q <= ResetPhase0Count ? 1'b1 :
                            reset_counter_q <  ResetPhase1Count ? 1'b0 :
                                                                  1'b1;
  assign rst_no = rst_n_q;
endmodule
