// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

module debounce #(
  parameter int unsigned ClkCount = 500
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

  /* verilator lint_off WIDTH */
  assign btn_d = (cnt_q >= ClkCount) ? btn_i : btn_q;
  /* verilator lint_off WIDTH */
  assign cnt_d = (btn_i == btn_q) ? '0 : // clear counter if input equals stored value
                 (cnt_q >= ClkCount) ? '0 : // clear counter if maximum value reached
                 cnt_q + 1; // otherwise increment counter

endmodule
