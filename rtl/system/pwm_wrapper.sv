// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// This wrapper instantiates a series of PWMs and distributes requests from the device bus.
module pwm_wrapper #(
  parameter int PwmWidth   = 12,
  parameter int PwmCtrSize = 8,
  parameter int BusWidth   = 32
) (
  input  logic                clk_i,
  input  logic                rst_ni,

  // IO for device bus.
  input  logic                device_req_i,
  input  logic [BusWidth-1:0] device_addr_i,
  input  logic                device_we_i,
  input  logic [         3:0] device_be_i,
  input  logic [BusWidth-1:0] device_wdata_i,
  output logic                device_rvalid_o,
  output logic [BusWidth-1:0] device_rdata_o,

  // Collected output of all PWMs.
  output logic [PwmWidth-1:0] pwm_o
);

  localparam int unsigned AddrWidth = 10;
  localparam int unsigned PwmIdxOffset = $clog2(BusWidth / 8) + 1;
  localparam int unsigned PwmIdxWidth = AddrWidth - PwmIdxOffset;

  // Generate PwmWidth number of PWMs.
  for (genvar i = 0; i < PwmWidth; i++) begin : gen_pwm
    logic [PwmCtrSize-1:0] data_d;
    logic [PwmCtrSize-1:0] counter_q;
    logic [PwmCtrSize-1:0] pulse_width_q;
    logic counter_en;
    logic pulse_width_en;
    logic [PwmIdxWidth-1:0] pwm_idx;

    assign pwm_idx = i;

    // Byte enables are currently unsupported for PWM.
    assign data_d         = device_wdata_i[PwmCtrSize-1:0]; // Only take PwmCtrSize LSBs.
    // Each PWM has a 64-bit block. The most significant 32 bits are the counter and the least
    // significant 32 bits are the pulse width.
    assign counter_en     = device_req_i & device_we_i
                                         & (device_addr_i[AddrWidth-1:PwmIdxOffset] == pwm_idx)
                                         & device_addr_i[PwmIdxOffset-1];
    assign pulse_width_en = device_req_i & device_we_i
                                         & (device_addr_i[AddrWidth-1:PwmIdxOffset] == pwm_idx)
                                         & ~device_addr_i[PwmIdxOffset-1];

    always @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        counter_q       <= '0;
        pulse_width_q   <= '0;
      end else begin
        if (counter_en) begin
          counter_q     <= data_d;
        end
        if (pulse_width_en) begin
          pulse_width_q <= data_d;
        end
      end
    end
    pwm #(
      .CtrSize( PwmCtrSize )
    ) u_pwm (
      .clk_i        (clk_i),
      .rst_ni       (rst_ni),
      .pulse_width_i(pulse_width_q),
      .max_counter_i(counter_q),
      .modulated_o  (pwm_o[i])
    );
  end : gen_pwm

  // Generating the device bus output.
  // Reading from PWM currently not possible.
  assign device_rdata_o = 32'b0;
  always @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      device_rvalid_o <= 1'b0;
    end else begin
      // TODO only set rvalid if rdata was valid.
      device_rvalid_o <= device_req_i;
    end
  end

  logic _unused;
  assign _unused = ^device_be_i ^ ^device_wdata_i;
endmodule
