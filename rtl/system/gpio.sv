// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

module gpio #(
  GpoWidth = 16
) (
  input  logic                clk_i,
  input  logic                rst_ni,

  input  logic                device_req_i,
  input  logic [31:0]         device_addr_i,
  input  logic                device_we_i,
  input  logic [ 3:0]         device_be_i,
  input  logic [31:0]         device_wdata_i,
  output logic                device_rvalid_o,
  output logic [31:0]         device_rdata_o,

  output logic [GpoWidth-1:0] gp_o
);
  logic [GpoWidth-1:0] gp_d;
  logic                gp_en;

  always @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      gp_o            <= '0;
      device_rvalid_o <= '0;
    end else begin
      if (gp_en) begin
        gp_o <= gp_d;
      end

      device_rvalid_o <= device_req_i;
    end
  end

  assign gp_en = device_req_i & device_we_i & (device_addr_i[9:0] == 0);

  for (genvar i_byte = 0; i_byte < 4; ++i_byte) begin : g_gp_d;
    if (i_byte * 8 < GpoWidth) begin : g_gp_d_inner
      localparam int gpo_byte_end = (i_byte + 1) * 8 <= GpoWidth ? (i_byte + 1) * 8 : GpoWidth;
      assign gp_d[gpo_byte_end - 1 : i_byte * 8] =
        device_be_i[i_byte] ? device_wdata_i[gpo_byte_end - 1 : i_byte * 8] :
                              gp_o[gpo_byte_end - 1 : i_byte * 8];
    end
  end

  assign device_rdata_o = {{(32 - GpoWidth){1'b0}}, gp_o};

  logic unused_device_addr, unused_device_be, unused_device_wdata;

  assign unused_device_addr = ^device_addr_i[31:10];
  // TODO: Do this more neatly
  assign unused_device_be = ^device_be_i;
  assign unused_device_wdata = ^device_wdata_i[31:GpoWidth];
endmodule
