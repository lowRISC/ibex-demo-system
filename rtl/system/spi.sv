module spi_host #(parameter CLK_DIV = 2,
                  parameter CPOL = 0,
                  parameter CPHA = 0)(
    input clk_i,
    input rst_ni,

    input  logic miso_i,
    output logic mosi_o,
    output logic sck_o,

    input  logic start_i,
    input  logic [7:0] byte_data_i,
    output logic [7:0] byte_data_o,
    output logic next_tx_byte_o,
    output logic busy_o
  );

logic sclk_gated;
prim_clock_gating spi_clock_gate_i (
  .clk_i    (clk_i),
  .en_i     (busy_o),
  .test_en_i('0),
  .clk_o    (sclk_gated)
);

// Counter to parse bits to fill to a byte.
logic [2:0] bit_num;
// Register to hold outgoing data bits
logic [7:0] data_tx_d, data_tx_q;
// Register to hold incoming data bits
logic [7:0] data_rx_d, data_rx_q;
logic busy_d, busy_q;
always_ff @(posedge clk_i or negedge rst_ni) begin : data_catch
  if (!rst_ni) begin
    data_tx_d <= '0;
    busy_q <= '0;
  end
  else if (start_i && !busy_q) begin
    data_tx_d <= byte_data_i;
    busy_q <= 1'b1;
  end else begin
    data_tx_q <= data_tx_d;
    busy_q <= busy_d;
  end
end

generate
  // If CPHA is HIGH, data will be sampled on the falling edge while it
  // will get shifted out on the rising edge.
  if (CPHA) begin
    always_ff @(posedge sclk_gated or negedge rst_ni) begin : data_shift_out
      if (!rst_ni) begin
        mosi_o <= '0;
      end else begin
        mosi_o <= data_tx_q[bit_num];
      end
    end
    always_ff @(negedge sclk_gated or negedge rst_ni) begin : data_sample_in
      if (!rst_ni) begin
        bit_num <= '0;
        data_rx_q <= '0;
      end else begin
        data_rx_d[bit_num] <= miso_i;
        bit_num <= bit_num + 1;
        if (bit_num == '1) begin
          data_rx_q <= data_rx_d;
        end
      end
    end
  end
  // If CPHA is LOW, data will be sampled on the rising edge while it
  // will get shifted out on the falling edge.
  else begin
    always_ff @(posedge sclk_gated or negedge rst_ni) begin : data_sample_in
      if (!rst_ni) begin
        data_rx_q <= '0;
      end else begin
        data_rx_d[bit_num] <= miso_i;
        if (bit_num == '1) begin
          data_rx_q <= data_rx_d;
        end
      end
    end
    always_ff @(negedge sclk_gated or negedge rst_ni) begin : data_shift_out
      if (!rst_ni) begin
        bit_num <= '0;
      end else begin
        mosi_o <= data_tx_q[bit_num];
        bit_num <= bit_num + 1;
      end
    end
  end
  // If CPOL is HIGH, clock polarity in Idle state is HIGH.
  if (CPOL) begin
    assign sck_o = busy_q ? sclk_gated : !sclk_gated;
  end else begin
    assign sck_o = sclk_gated;
  end
endgenerate

always_comb begin
  next_tx_byte_o = busy_q && (bit_num == 3'b000);
  busy_d = (bit_num != 3'b111);
  busy_o = busy_q;
  byte_data_o = data_rx_q;
end

endmodule
