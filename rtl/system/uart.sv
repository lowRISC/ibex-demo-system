// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

module uart #(
  parameter int unsigned ClockFrequency = 50_000_000,
  parameter int unsigned BaudRate = 115_200
) (
  input logic         clk_i,
  input logic         rst_ni,

  input  logic        device_req_i,
  /* verilator lint_off UNUSED */
  input  logic [31:0] device_addr_i,
  input  logic        device_we_i,
  input  logic [3:0]  device_be_i,
  input  logic [31:0] device_wdata_i,
  output logic        device_rvalid_o,
  output logic [31:0] device_rdata_o,

  output logic        uart_tx_o
);

  localparam int unsigned ClocksPerBaud = ClockFrequency / BaudRate;

  logic [$clog2(ClocksPerBaud)-1:0] baud_counter_q, baud_counter_d;
  logic                             baud_tick;

  /* verilator lint_off WIDTH */
  localparam int unsigned UART_TX_REG = 32'h0;
  /* verilator lint_off WIDTH */
  localparam int unsigned UART_STATUS_REG = 32'h4;

  typedef enum logic[1:0] {
    IDLE,
    START,
    SEND,
    STOP
  } uart_state_t;

  uart_state_t state_q, state_d;
  logic [2:0]  bit_counter_q, bit_counter_d;
  logic [7:0]  current_byte_q, current_byte_d;
  logic        next_tx_byte;
  logic        read_status_q, read_status_d;
  logic        req;

  logic [11:0] reg_addr;

  logic        tx_fifo_wvalid;
  logic        tx_fifo_rvalid, tx_fifo_rready;
  logic [7:0]  tx_fifo_rdata;
  logic        tx_fifo_full;

  assign reg_addr = device_addr_i[11:0];

  assign tx_fifo_wvalid  = (device_req_i & (reg_addr == UART_TX_REG) & device_be_i[0] & device_we_i);
  assign tx_fifo_rready  = baud_tick & next_tx_byte;

  assign read_status_d   = (device_req_i & (reg_addr == UART_STATUS_REG) & device_be_i[0] & ~device_we_i);

  assign device_rdata_o  = read_status_q ? {31'b0, tx_fifo_full} : 32'b0;
  assign device_rvalid_o = req;

  prim_fifo_sync #(
    .Width ( 8    ),
    .Pass  ( 1'b0 ),
    .Depth ( 128  )
  ) u_tx_fifo (
    .clk_i,
    .rst_ni,
    .clr_i   (1'b0),

    .wvalid_i(tx_fifo_wvalid),
    .wready_o(),
    .wdata_i (device_wdata_i[7:0]),

    .rvalid_o(tx_fifo_rvalid),
    .rready_i(tx_fifo_rready),
    .rdata_o (tx_fifo_rdata),

    .full_o  (tx_fifo_full),
    .depth_o (),
    .err_o()
  );

  assign baud_counter_d = baud_tick ? '0 : baud_counter_q + 1'b1;
  /* verilator lint_off WIDTH */
  assign baud_tick      = baud_counter_q == (ClocksPerBaud - 1);

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      read_status_q  <=  0;
      req            <=  0;
      baud_counter_q <= '0;
    end else begin
      read_status_q  <= read_status_d;
      req            <= device_req_i;
      baud_counter_q <= baud_counter_d;
    end
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      state_q        <= IDLE;
      bit_counter_q  <= '0;
      current_byte_q <= '0;
    end else if (baud_tick) begin
      state_q        <= state_d;
      bit_counter_q  <= bit_counter_d;
      current_byte_q <= current_byte_d;
    end
  end

  always_comb begin
    uart_tx_o      = 1'b0;
    bit_counter_d  = bit_counter_q;
    current_byte_d = current_byte_q;
    next_tx_byte   = 1'b0;
    state_d        = state_q;

    case (state_q)
      IDLE: begin
        uart_tx_o = 1'b1;

        if (tx_fifo_rvalid) begin
          state_d = START;
        end
      end
      START: begin
        uart_tx_o      = 1'b0;
        state_d        = SEND;
        bit_counter_d  = 3'd0;
        current_byte_d = tx_fifo_rdata;
        next_tx_byte   = 1'b1;
      end
      SEND: begin
        uart_tx_o = current_byte_q[0];

        current_byte_d = {1'b0, current_byte_q[7:1]};
        if (bit_counter_q == 3'd7) begin
          state_d = STOP;
        end else begin
          bit_counter_d = bit_counter_q + 3'd1;
        end
      end
      STOP: begin
        uart_tx_o = 1'b1;
        if (tx_fifo_rvalid) begin
          state_d = START;
        end else begin
          state_d = IDLE;
        end
      end
    endcase
  end
endmodule
