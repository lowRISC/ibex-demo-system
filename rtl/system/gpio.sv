// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

module gpio #(
  GpiWidth = 8,
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

  input  logic [GpiWidth-1:0] gp_i,
  output logic [GpoWidth-1:0] gp_o
);

  localparam int unsigned GPIO_OUT_REG = 32'h0;
  localparam int unsigned GPIO_IN_REG = 32'h4;
  localparam int unsigned GPIO_IN_DBNC_REG = 32'h8;

  logic [11:0] reg_addr;

  logic [2:0][GpiWidth-1:0] gp_i_q;
  logic [GpiWidth-1:0] gp_i_dbnc;
  logic [GpoWidth-1:0] gp_o_d;

  logic                gp_o_wr_en;
  logic                gp_i_rd_en_d, gp_i_rd_en_q;
  logic                gp_i_dbnc_rd_en_d, gp_i_dbnc_rd_en_q;

  // instantiate debouncers for all GP inputs
  for (genvar i = 0; i < GpiWidth; i++) begin
    debounce #(
      .ClkCount(500)
    ) dbnc (
      .clk_i,
      .rst_ni,  
      .btn_i(gp_i_q[2][i]),
      .btn_o(gp_i_dbnc[i])
    );
  end

  always @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      gp_i_q            <= '0;
      gp_o              <= '0;
      device_rvalid_o   <= '0;
      gp_i_rd_en_q      <= '0;
      gp_i_dbnc_rd_en_q <= '0;
    end else begin
      gp_i_q <= {gp_i_q[1:0], gp_i};
      if (gp_o_wr_en) begin
        gp_o <= gp_o_d;
      end
      device_rvalid_o   <= device_req_i;
      gp_i_rd_en_q      <= gp_i_rd_en_d;
      gp_i_dbnc_rd_en_q <= gp_i_dbnc_rd_en_d;
    end
  end

  // assign gp_o_d regarding to device_be_i and GpoWidth
  for (genvar i_byte = 0; i_byte < 4; ++i_byte) begin : g_gp_o_d;
    if (i_byte * 8 < GpoWidth) begin : g_gp_o_d_inner
      localparam int gpo_byte_end = (i_byte + 1) * 8 <= GpoWidth ? (i_byte + 1) * 8 : GpoWidth;
      assign gp_o_d[gpo_byte_end - 1 : i_byte * 8] =
        device_be_i[i_byte] ? device_wdata_i[gpo_byte_end - 1 : i_byte * 8] :
                              gp_o[gpo_byte_end - 1 : i_byte * 8];
    end
  end

  // decode write and read requests
  assign reg_addr = device_addr_i[11:0];
  assign gp_o_wr_en = device_req_i & device_we_i & (reg_addr == GPIO_OUT_REG[11:0]);
  assign gp_i_rd_en_d = device_req_i & ~device_we_i & (reg_addr == GPIO_IN_REG[11:0]);
  assign gp_i_dbnc_rd_en_d = device_req_i & ~device_we_i & (reg_addr == GPIO_IN_DBNC_REG[11:0]);

  // assign device_rdata_o according to request type
  always_comb begin
    if (gp_i_dbnc_rd_en_q)
      device_rdata_o = {{(32 - GpiWidth){1'b0}}, gp_i_dbnc};
    else if (gp_i_rd_en_q)
      device_rdata_o = {{(32 - GpiWidth){1'b0}}, gp_i_q[2]};
    else
      device_rdata_o = {{(32 - GpoWidth){1'b0}}, gp_o};
  end

  logic unused_device_addr, unused_device_be, unused_device_wdata;

  assign unused_device_addr = ^device_addr_i[31:10];
  // TODO: Do this more neatly
  assign unused_device_be = ^device_be_i;
  assign unused_device_wdata = ^device_wdata_i[31:GpoWidth];
endmodule
