// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

module spi_host #(
  parameter int unsigned ClockFrequency = 50_000_000,
  parameter int unsigned BaudRate = 12_500_000,
  parameter bit CPOL = 0,
  parameter bit CPHA = 0
)(
    input clk_i,
    input rst_ni,

    input  logic spi_rx_i,
    output logic spi_tx_o,
    output logic sck_o,

    input  logic start_i,
    input  logic [7:0] byte_data_i,
    output logic [7:0] byte_data_o,
    output logic next_tx_byte_o
  );

  // ClocksPerBaud: Clock cycles in between two SPI SCLK cycles (DEFAULT:4)
  localparam int unsigned ClocksPerBaud = ClockFrequency / BaudRate;
  // ToggleCount: The point which SCK would toggle (DEFAULT:2)
  localparam int unsigned ToggleCount = ClocksPerBaud / 2;
  // CountWidth: Width of the implemented counter for generating SCK (DEFAULT:1)
  localparam int unsigned CountWidth = $clog2(ToggleCount);

  logic [CountWidth-1:0] limit, count;
  logic sck, count_at_limit, sck_pos, sck_neg;

  logic sck_en;
  assign sck_en = (state_q == SEND);

  assign limit = CountWidth'(ToggleCount - 1);
  assign count_at_limit = (count >= limit);

  always_ff @(posedge clk_i or negedge rst_ni) begin
    // Do not start clock related logic unless we are starting
    // SPI transmission or already at SEND state.
    if (!rst_ni) begin
      count <= '0;
      sck <= CPOL;
    end else if (!(sck_en||start_i)) begin
      count <= '0;
      sck <= CPOL;
    // In the case of counter reaching to the limit, toggle SCK and start over.
    end else if (count_at_limit) begin
      count <= '0;
      sck <= ~sck;
    end else begin
      count <= count + 1'b1;
    end
  end

  // Only send clock to the pad when we are at the SEND state.
  assign sck_o = sck_en ? sck : CPOL;
  // Set to HIGH at the posedge of the serial clock, used internally.
  assign sck_pos = count_at_limit && !sck;
  // Set to HIGH at the negedge of the serial clock, used internally.
  assign sck_neg = count_at_limit && sck;

  typedef enum logic[1:0] {
    IDLE,
    START,
    SEND,
    STOP
  } spi_state_t;

  spi_state_t state_q, state_d;

  logic [2:0] bit_counter_q, bit_counter_d;
  logic [7:0] current_byte_q, current_byte_d, recieved_byte_d, recieved_byte_q;

  always_comb begin
    spi_tx_o       = 1'b1;
    bit_counter_d  = bit_counter_q;
    current_byte_d = current_byte_q;
    next_tx_byte_o = 1'b0;
    state_d        = state_q;
    byte_data_o    = '0;

    case (state_q)
      IDLE: begin
        spi_tx_o = 1'b1;
        if (start_i) begin
          state_d = START;
        end
      end
      START: begin
        state_d        = SEND;
        bit_counter_d  = 3'd7;
        current_byte_d = byte_data_i;
      end
      SEND: begin
        spi_tx_o       = current_byte_q[7];
        current_byte_d = {current_byte_q[6:0], 1'b0};
        if (bit_counter_q == 3'd0) begin
          state_d = STOP;
        end else begin
          bit_counter_d = bit_counter_q - 3'd1;
        end
      end
      STOP: begin
        spi_tx_o       = 1'b1;
        next_tx_byte_o = 1'b1;
        byte_data_o    = recieved_byte_q;
        state_d        = IDLE;
      end
    endcase
  end

  generate
    // If CPHA is HIGH, incoming data will be sampled on the falling edge while outgoing
    // data will get shifted out on the rising edge.
    if (CPHA) begin
      always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
          current_byte_q  <= '0;
          bit_counter_q   <= '0;
          recieved_byte_q <= '0;
          state_q         <= IDLE;
        end else if (sck_pos) begin
          bit_counter_q   <= bit_counter_d;
          recieved_byte_q <= recieved_byte_d;
          state_q         <= state_d;
        // Set current byte half a cycle before transmitting it.
        end else if (sck_neg) begin
          current_byte_q <= current_byte_d;
          if (state_q == SEND) begin
            recieved_byte_d <= {recieved_byte_q[6:0], spi_rx_i};
          end
        end
      end
    // If CPHA is LOW, incoming data will be sampled on the rising edge while outgoing
    // data will get shifted out on the falling edge.
    end else begin
      always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
          current_byte_q  <= '0;
          bit_counter_q   <= '0;
          recieved_byte_q <= '0;
          state_q         <= IDLE;
        // Set current byte half a cycle before transmitting it.
        end else if (sck_pos) begin
          current_byte_q <= current_byte_d;
          if (state_q == SEND) begin
            recieved_byte_d <= {recieved_byte_q[6:0], spi_rx_i};
          end
        end else if (sck_neg) begin
          bit_counter_q   <= bit_counter_d;
          recieved_byte_q <= recieved_byte_d;
          state_q         <= state_d;
        end
      end
    end
  endgenerate

endmodule
