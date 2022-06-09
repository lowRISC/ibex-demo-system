// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

module uart #(
  parameter int unsigned ClockFrequency = 50_000_000,
  parameter int unsigned BaudRate = 115_200,
  parameter int unsigned RxFifoDepth = 128,
  parameter int unsigned TxFifoDepth = 128
) (
  input logic clk_i,
  input logic rst_ni,

  input  logic        device_req_i,
  input  logic [31:0] device_addr_i,
  input  logic        device_we_i,
  input  logic [3:0]  device_be_i,
  input  logic [31:0] device_wdata_i,
  output logic        device_rvalid_o,
  output logic [31:0] device_rdata_o,

  input  logic        uart_rx_i,
  output logic        uart_irq_o,
  output logic        uart_tx_o
  
);

  localparam int unsigned ClocksPerBaud = ClockFrequency / BaudRate;
  localparam int unsigned UART_RX_REG = 32'h0;
  localparam int unsigned UART_TX_REG = 32'h4;
  localparam int unsigned UART_STATUS_REG = 32'h8;

  logic        device_req_q;
  logic [11:0] reg_addr;
  logic        read_req, write_req;
  logic        rx_req, tx_req, status_req;

  typedef enum logic[1:0] {
    IDLE,
    START,
    PROC,
    STOP
  } uart_state_t;

  logic        status_read_req_q, status_read_req_d;

  logic [$clog2(RxFifoDepth+1)-1:0] rx_fifo_depth;
  logic [$clog2(ClocksPerBaud)-1:0] rx_baud_counter_q, rx_baud_counter_d;
  logic                             rx_baud_tick;

  uart_state_t rx_state_q, rx_state_d;
  logic [2:0]  rx_bit_counter_q, rx_bit_counter_d;
  logic [7:0]  rx_current_byte_q, rx_current_byte_d;
  logic        rx_read_req_q, rx_read_req_d;
  logic        rx_q, rx_q2, rx_q3, rx_start, rx_valid; 

  logic        rx_fifo_wvalid;
  logic        rx_fifo_rvalid, rx_fifo_rready;
  logic [7:0]  rx_fifo_rdata;
  logic        rx_fifo_empty;
  
  logic [$clog2(ClocksPerBaud)-1:0] tx_baud_counter_q, tx_baud_counter_d;
  logic                             tx_baud_tick;
  
  uart_state_t tx_state_q, tx_state_d;
  logic [2:0]  tx_bit_counter_q, tx_bit_counter_d;
  logic [7:0]  tx_current_byte_q, tx_current_byte_d;
  logic        tx_next_byte;

  logic        tx_fifo_wvalid;
  logic        tx_fifo_rvalid, tx_fifo_rready;
  logic [7:0]  tx_fifo_rdata;
  logic        tx_fifo_full;

  assign reg_addr = device_addr_i[11:0];
  
  assign read_req = (device_req_i & device_be_i[0] & ~device_we_i);
  assign write_req = (device_req_i & device_be_i[0] & device_we_i);
  
  assign rx_req = (reg_addr == $bits(reg_addr)'(UART_RX_REG));
  assign tx_req = (reg_addr == $bits(reg_addr)'(UART_TX_REG));
  assign status_req = (reg_addr == $bits(reg_addr)'(UART_STATUS_REG));
  assign rx_read_req_d = rx_req & read_req;
  assign status_read_req_d = status_req & read_req;

  assign device_rdata_o = (rx_read_req_q & rx_fifo_rvalid) ? {24'b0, rx_fifo_rdata} :
                          status_read_req_q ? {30'b0, tx_fifo_full, rx_fifo_empty} : 
                          32'b0;
  assign device_rvalid_o = device_req_q;

  assign rx_fifo_wvalid = rx_baud_tick & rx_valid;
  assign rx_fifo_rready = rx_read_req_q;
  assign rx_fifo_empty  = (rx_fifo_depth == '0);

  assign tx_fifo_wvalid = tx_req & write_req;
  assign tx_fifo_rready = tx_baud_tick & tx_next_byte;

  // Set the rx_baud_counter half-way on rx_start to ensure sampling the bits 'in the middle'
  assign rx_baud_counter_d = rx_baud_tick ? '0 : 
                             rx_start ? $bits(rx_baud_counter_q)'(ClocksPerBaud >> 1) : 
                             rx_baud_counter_q + 1'b1;
  assign rx_baud_tick      = rx_baud_counter_q == $bits(rx_baud_counter_q)'(ClocksPerBaud - 1);

  assign tx_baud_counter_d = tx_baud_tick ? '0 : tx_baud_counter_q + 1'b1;
  assign tx_baud_tick      = tx_baud_counter_q == $bits(tx_baud_counter_q)'(ClocksPerBaud - 1);

  assign uart_irq_o        = !rx_fifo_empty;

  prim_fifo_sync #(
    .Width(8),
    .Pass(1'b0),
    .Depth(RxFifoDepth)
  ) u_rx_fifo (
    .clk_i,
    .rst_ni,
    .clr_i(1'b0),

    .wvalid_i(rx_fifo_wvalid),
    .wready_o(),
    .wdata_i(rx_current_byte_q),

    .rvalid_o(rx_fifo_rvalid),
    .rready_i(rx_fifo_rready),
    .rdata_o(rx_fifo_rdata),

    .full_o(),
    .depth_o(rx_fifo_depth)
  );

  prim_fifo_sync #(
    .Width(8),
    .Pass(1'b0),
    .Depth(TxFifoDepth)
  ) u_tx_fifo (
    .clk_i,
    .rst_ni,
    .clr_i(1'b0),

    .wvalid_i(tx_fifo_wvalid),
    .wready_o(),
    .wdata_i(device_wdata_i[7:0]),

    .rvalid_o(tx_fifo_rvalid),
    .rready_i(tx_fifo_rready),
    .rdata_o(tx_fifo_rdata),

    .full_o(tx_fifo_full),
    .depth_o()
  );

  //  Synchronize RX and derive rx_start signal
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      rx_q <= 0;
      rx_q2 <= 0;
      rx_q3 <= 0;
    end else begin
      rx_q <= uart_rx_i;
      rx_q2 <= rx_q;
      rx_q3 <= rx_q2;
    end
  end

  assign rx_start = !rx_q2 & rx_q3 & (rx_state_q == IDLE);

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      status_read_req_q <= 0;
      device_req_q      <= 0;
      rx_read_req_q     <= 0;
      rx_baud_counter_q <= '0;
      tx_baud_counter_q <= '0;
    end else begin
      status_read_req_q <= status_read_req_d;
      device_req_q      <= device_req_i;
      rx_read_req_q     <= rx_read_req_d;
      rx_baud_counter_q <= rx_baud_counter_d;
      tx_baud_counter_q <= tx_baud_counter_d;
    end
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      rx_state_q        <= IDLE;
      rx_bit_counter_q  <= '0;
      rx_current_byte_q <= '0;
    // Transition the rx state on both rx_start and an rx_baud_tick
    end else if (rx_start | rx_baud_tick) begin
      rx_state_q        <= rx_state_d;
      rx_bit_counter_q  <= rx_bit_counter_d;
      rx_current_byte_q <= rx_current_byte_d;
    end
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      tx_state_q        <= IDLE;
      tx_bit_counter_q  <= '0;
      tx_current_byte_q <= '0;
    end else if (tx_baud_tick) begin
      tx_state_q        <= tx_state_d;
      tx_bit_counter_q  <= tx_bit_counter_d;
      tx_current_byte_q <= tx_current_byte_d;
    end
  end

  always_comb begin
    rx_valid          = 0;
    rx_bit_counter_d  = rx_bit_counter_q;
    rx_current_byte_d = rx_current_byte_q;
    rx_state_d        = rx_state_q;

    case (rx_state_q)
      IDLE: begin

        if (rx_start) begin
          rx_state_d = START;
        end
      end
      START: begin
        rx_current_byte_d = '0;
        rx_bit_counter_d = '0;
        
        if (!rx_q3) begin
          rx_state_d = PROC;
        end else begin
          rx_state_d = IDLE;
        end
      end
      PROC: begin
        rx_current_byte_d = {rx_q3, rx_current_byte_q[7:1]};

        if (rx_bit_counter_q == 3'd7) begin
          rx_state_d = STOP;
        end else begin
          rx_bit_counter_d = rx_bit_counter_q + 3'd1;
        end
      end
      STOP: begin
        if (rx_q3) begin
          rx_valid = 1;
        end
        rx_state_d = IDLE;
      end
    endcase
  end

  always_comb begin
    uart_tx_o         = 1'b0;
    tx_bit_counter_d  = tx_bit_counter_q;
    tx_current_byte_d = tx_current_byte_q;
    tx_next_byte      = 1'b0;
    tx_state_d        = tx_state_q;

    case (tx_state_q)
      IDLE: begin
        uart_tx_o = 1'b1;

        if (tx_fifo_rvalid) begin
          tx_state_d = START;
        end
      end
      START: begin
        uart_tx_o         = 1'b0;
        tx_state_d        = PROC;
        tx_bit_counter_d  = 3'd0;
        tx_current_byte_d = tx_fifo_rdata;
        tx_next_byte      = 1'b1;
      end
      PROC: begin
        uart_tx_o = tx_current_byte_q[0];

        tx_current_byte_d = {1'b0, tx_current_byte_q[7:1]};
        if (tx_bit_counter_q == 3'd7) begin
          tx_state_d = STOP;
        end else begin
          tx_bit_counter_d = tx_bit_counter_q + 3'd1;
        end
      end
      STOP: begin
        uart_tx_o = 1'b1;
        if (tx_fifo_rvalid) begin
          tx_state_d = START;
        end else begin
          tx_state_d = IDLE;
        end
      end
    endcase
  end

endmodule
