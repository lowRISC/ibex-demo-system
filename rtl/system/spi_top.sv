module spi_top #(
  parameter CLK_DIV = 2
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

    output logic spi_tx_o,
    output logic sck_o,

    output logic [7:0] byte_data_o,
    output logic busy_o
  );

  localparam int unsigned SPI_TX_REG = 32'h0;
  localparam int unsigned SPI_STATUS_REG = 32'h4;


  logic        read_status_q, read_status_d;
  logic [11:0] reg_addr;

  logic next_tx_byte;

  logic       tx_fifo_wvalid;
  logic       tx_fifo_rvalid, tx_fifo_rready;
  logic [7:0] tx_fifo_rdata;
  logic       tx_fifo_full;

  always @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      device_rvalid_o <= '0;
    end else begin
      device_rvalid_o <= device_req_i;
    end
  end

  assign reg_addr = device_addr_i[11:0];

  assign tx_fifo_wvalid = (device_req_i & (reg_addr == SPI_TX_REG) & device_be_i[0] & device_we_i);
  assign tx_fifo_rready = next_tx_byte;
  assign read_status_d = (device_req_i & (reg_addr == SPI_STATUS_REG) & device_be_i[0] & ~device_we_i);

  assign device_rdata_o = read_status_q ? {31'b0, tx_fifo_full} : 32'b0;

  prim_fifo_sync #(
    .Width(8),
    .Pass(1'b0),
    .Depth(128)
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


  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      read_status_q  <= 0;
    end else begin
      read_status_q  <= read_status_d;
    end
  end

  spi_host #(.CLK_DIV(CLK_DIV), .CPOL(0), .CPHA(0)) u_spi_host (
    .clk_i (clk_i),
    .rst_ni(rst_ni),

    .miso_i('0), // connect this when you want to talk with Super System through SPI
    .mosi_o(spi_tx_o), // this is the actual pin out
    .sck_o(sck_o), // this is serial clock output

    .start_i(tx_fifo_wvalid),
    .byte_data_i(device_wdata_i[7:0]), // 8-bit data, from FIFO possibly
    .byte_data_o(byte_data_o),
    .next_tx_byte_o(next_tx_byte), // requests new byte
    .busy_o(busy_o)
  );

endmodule
