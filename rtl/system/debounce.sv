// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// Maintain a counter that increments whilst the input is in the opposite state
// from the debounced output. If the input remains in that state for a certain
// number of cycles (ClkCount) it is deemed stable and becomes the debounced
// output. If the input changes (i.e. it is bouncing) we reset the counter.

typedef int unsigned count_t;

module debounce #(
    parameter count_t ClkCount = 500
) (
    input  logic clk_i,
    input  logic rst_ni,

    input  logic btn_i,
    output logic btn_o
);

  logic [$clog2(ClkCount+1)-1:0] cnt_d, cnt_q;
  logic btn_d, btn_q;

  assign btn_o = btn_q;

  always_ff @(posedge clk_i or negedge rst_ni) begin : p_fsm_reg
    if (!rst_ni) begin
      cnt_q <= '0;
      btn_q <= '0;
    end else begin
      cnt_q <= cnt_d;
      btn_q <= btn_d;
    end
  end

  assign btn_d = (count_t'(cnt_q) >= ClkCount) ? btn_i : btn_q;
  // Clear counter if button input equals stored value or if maximum counter value is reached,
  // otherwise increment counter.
  assign cnt_d = (btn_i == btn_q || count_t'(cnt_q) >= ClkCount) ? '0 : cnt_q + 1;

endmodule
