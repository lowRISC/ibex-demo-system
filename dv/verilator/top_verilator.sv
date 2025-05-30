// Corrected top level for Verilator simulation that connects the demo system to virtual devices
module top_verilator (input logic clk_i, rst_ni);

  localparam ClockFrequency = 50_000_000;
  localparam BaudRate       = 115_200;

  logic uart_sys_rx, uart_sys_tx;
  logic irq_external;
  logic [31:0] irq_sources;
  
  // New signals for the updated PLIC DPI bus interface
  logic        plic_req;
  logic [31:0] plic_addr;
  logic        plic_we;
  logic [3:0]  plic_be;
  logic [31:0] plic_wdata;
  logic        plic_rvalid;
  logic [31:0] plic_rdata;

  // Instantiate the Ibex Demo System
  ibex_demo_system #(
    .GpiWidth       ( 8                   ),
    .GpoWidth       ( 16                  ),
    .PwmWidth       ( 12                  ),
    .ClockFrequency ( ClockFrequency      ),
    .BaudRate       ( BaudRate            ),
    .RegFile        ( ibex_pkg::RegFileFF )
  ) u_ibex_demo_system (
    .clk_sys_i (clk_i),
    .rst_sys_ni(rst_ni),
    .uart_rx_i (uart_sys_rx),
    .uart_tx_o (uart_sys_tx),
    // Tie off JTAG
    .trst_ni(1'b1),
    .tms_i  (1'b0),
    .tck_i  (1'b0),
    .td_i   (1'b0),
    .td_o   (    ),
    // Remaining I/O (unused for this example)
    .gp_i      (0),
    .gp_o      ( ),
    .pwm_o     ( ),
    .spi_rx_i  (0),
    .spi_tx_o  ( ),
    .spi_sck_o ( )
    // PLIC interface not directly connected to the demo system in this configuration
  );

  // Instantiate the Virtual UART
  uartdpi #(
    .BAUD(BaudRate),
    .FREQ(ClockFrequency)
  ) u_uartdpi (
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .active (1'b1),
    .tx_o   (uart_sys_rx),
    .rx_i   (uart_sys_tx)
  );

  // Drive default values for the PLIC bus signals (no bus transactions in this testbench)
  assign plic_req   = 1'b0;
  assign plic_addr  = 32'b0;
  assign plic_we    = 1'b0;
  assign plic_be    = 4'b0;
  assign plic_wdata = 32'b0;
  
  // Instantiate the corrected Virtual PLIC DPI module
  plicdpi #(
    .SOURCES(32),
    .TARGETS(1),
    .PRIORITIES(3)
  ) u_plicdpi (
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .req_i(plic_req),
    .addr_i(plic_addr),
    .we_i(plic_we),
    .be_i(plic_be),
    .wdata_i(plic_wdata),
    .rvalid_o(plic_rvalid),
    .rdata_o(plic_rdata),
    .irq_sources_i(irq_sources),
    .irq_pending_o(),       // Not used here
    .irq_o(irq_external)    // External interrupt output
  );

  // For testing, generate a timer interrupt on irq_sources[0]
  logic [31:0] timer_counter;
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      timer_counter <= '0;
      irq_sources   <= '0;
    end else begin
      timer_counter <= timer_counter + 1;
      if (timer_counter == 1000) begin
        timer_counter <= '0;
        irq_sources[0] <= 1'b1;  // Set timer interrupt source
      end else begin
        irq_sources[0] <= 1'b0;  // Clear timer interrupt source
      end
    end
  end

endmodule
