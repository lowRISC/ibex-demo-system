// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

module pwm #(
  parameter int CtrSize = 8
) (
  input  logic               clk_i,
  input  logic               rst_ni,

  // To produce an always-on signal, you will need to make pulse_width_i > max_counter_i.
  input  logic [CtrSize-1:0] pulse_width_i,
  input  logic [CtrSize-1:0] max_counter_i,

  output logic               modulated_o
);
  logic [CtrSize-1:0] counter;

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      counter     <= 'b0;
      modulated_o <= 'b0;
    end else if (max_counter_i == 0) begin
      // Set output to low when maximum is zero.
      counter     <= 'b0;
      modulated_o <= 'b0;
    end else begin
      // Wrap the counter once it gets to the maximum.
      if (counter < max_counter_i) begin
        counter <= counter + 1;
      end else begin
        counter <= 0;
      end
      // Set output to high for pulse_width_i/max_counter_i amount of time.
      if (pulse_width_i > counter) begin
        modulated_o <= 1'b1;
      end else begin
        modulated_o <= 1'b0;
      end
    end
  end
endmodule
