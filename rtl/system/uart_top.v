`include "uart.vh"

module uart_top #(
    parameter CLOCK_FREQUENCY = 50_000_000,
    parameter RX_FIFO_DEPTH = 128,
    parameter TX_FIFO_DEPTH = 128
) (
    input wire clk_i,               // core clock
`ifdef ASYNC
    input wire clk_M_i,             // master clock
`endif
    input wire rst_ni,              // reset not
    input wire we,                  // write enable
    input wire [3:0] be,            // byte enable
    input wire [31:0] uart_wdata_i, // data bus
    input wire [31:0] addr_i,       // addr bus
    input wire uart_req_i,          // request from core (IBEX LSU)
    input wire uart_rx_i,           // rx line
    output wire uart_tx_o,          // tx line
    output wire [31:0] uart_rdata_o,// data bus
    output wire uart_req_gnt_o,     // request granted to core (IBEX LSU)
    output wire uart_rvalid_o,      // request valid to core (IBEX LSU)
    output wire [1:0] uart_irq_o,   // interrupt request (CSR)
    output wire uart_err_o          // error to core (IBEX LSU)
);

reg [31:0] uart_rdata_q, uart_rdata_d;
reg uart_rvalid_q, uart_rvalid_d;
reg uart_err_q, uart_err_d;

localparam [31:0] INSTRUCTION_SIZE = 5;                                  // size of instruction in bits
localparam [INSTRUCTION_SIZE-1:0] OP_WRITE_UART_PARAMETERS  = 5'b10000;  // set protocol parameters
localparam [INSTRUCTION_SIZE-1:0] OP_WRITE_UART_EN          = 5'b01000;  // write data from bus to enable or diable rx/tx sub-modules
localparam [INSTRUCTION_SIZE-1:0] OP_READ_UART_STATE        = 5'b00100;  // read uart module state
localparam [INSTRUCTION_SIZE-1:0] OP_WRITE_UART_DATA        = 5'b00010;  // write data from bus to FIFO tx queue
localparam [INSTRUCTION_SIZE-1:0] OP_READ_UART_DATA         = 5'b00001;  // read data from FIFO rx queue
localparam [INSTRUCTION_SIZE-1:0] OP_DO_NOTHING             = 5'b00000;  // do nothing
reg [INSTRUCTION_SIZE-1:0] opcode;     // instruction to execute

reg [3:0] data_size;    // data size in bits of protocol
reg parity_size;        // parity of protocol (0 or 1 parity bits)
reg parity_type;        // parity type of protocol (ODD (1) or EVEN (0))
reg [1:0] stop_size;    // stop size in bits of protocol (1 or 2)
reg [31:0] baud_rate;   // baud rate of protocol (default 9600)

wire [8:0] rx_data;     // data received from serial
wire rx_rdy;            // ready flag
wire rx_err;            // error flag
reg rx_en;              // enable register of rx module
wire [1:0] rx_state;    // rx state machine status
wire rx_start;          // rx start signal (stability improvment)
reg [2:0] rx_buf;       // rx buffer

wire rx_fq_re;                  // rx FIFO read enable
wire rx_fq_we;                  // rx FIFO write enable
wire [8:0] rx_fq_data_out;      // rx FIFO data output
wire rx_fq_full;                // rx FIFO is full flag
wire rx_fq_empty;               // rx FIFO is empty flag
wire rx_fq_near_full;           // rx FIFO is almost full
wire rx_fq_near_empty;               // rx FIFO is almost empty

wire tx_rdy;            // ready flag
reg tx_en;              // enable register of tx module
wire tx_state;          // tx state machine status
wire tx_start;

wire tx_fq_re;                  // tx FIFO queue read enable
wire tx_fq_we;                  // tx FIFO queue write enable
wire [8:0] tx_fq_data_out;      // tx FIFO data output (to transmit)
wire tx_fq_full;                // tx FIFO is full flag
wire tx_fq_empty;               // tx FIFO is empty flag
wire tx_fq_near_full;           // tx FIFO is almost full
wire tx_fq_near_empty;          // tx FIFO is almost empty

reg [31:0] rx_tick_counter;
reg rx_clk_en;
reg [31:0] tx_tick_counter;
reg tx_clk_en;

uart_rx rx0 (
`ifndef ASYNC
    .clk_i(clk_i),                  // clock
`else
    .clk_i(clk_M_i),                // clock
`endif
    .clk_en_i(rx_clk_en),           // clock enable
    .rst_ni(rst_ni),                // negative reset signal
    .en(rx_en),                     // rx enable
    .rx_i(rx_buf[0]),               // rx pin
    .data_size_i(data_size),        // data size (payload)
    .parity_size_i(parity_size),    // parity bit
    .parity_type_i(parity_type),    // parity type
    .stop_size_i(stop_size),        // stop bits size
    .data_o(rx_data),               // data out (received data)
    .rx_rdy_o(rx_rdy),              // received new data flag
    .rx_err_o(rx_err),              // parity mismatch flag
    .rx_state_o(rx_state)
);

`ifndef ASYNC
// Synchronous FIFO queue for rx module
sync_fifo #(
    .WIDTH(9),                    // width of data bus
    .DEPTH(RX_FIFO_DEPTH)         // depth of FIFO buffer
) rx_sync_fifo (
    .clk_i(clk_i),                  // input clock    
    .rst_ni(rst_ni),                // reset signal
    .wdata_i(rx_data),              // input data
    .we_i(rx_fq_we),                // write enable signal
    .re_i(rx_fq_re),                // read enable signal
    .rdata_o(rx_fq_data_out),       // output data
    .full_o(rx_fq_full),            // full flag
    .empty_o(rx_fq_empty),          // empty flag
    .near_full_o(rx_fq_near_full),  // near full flag
    .near_empty_o(rx_fq_near_empty) // near empty flag
);
`else
// Asynchronous FIFO queue for rx module
async_fifo #(
    .WIDTH(9),
    .DEPTH(RX_FIFO_DEPTH)
) rx_async_fifo (
    .wclk_i(clk_M_i),
    .rst_ni(rst_ni),
    .wdata_i(rx_data),
    .rclk_i(clk_i),
    .we_i(rx_fq_we),
    .re_i(rx_fq_re),
    .rdata_o(rx_fq_data_out),
    .full_o(rx_fq_full),
    .empty_o(rx_fq_empty),
    .near_full_o(rx_fq_near_full),
    .near_empty_o(rx_fq_near_empty)
);
`endif


uart_tx tx0 (
`ifndef ASYNC
    .clk_i(clk_i),                // clock
`else
    .clk_i(clk_M_i),              // clock
`endif
    .clk_en_i(tx_clk_en),         // clock enable
    .rst_ni(rst_ni),              // negative reset signal
    .en(tx_en),                   // tx enable
    .tx_start_i(tx_start),        // start transmission flag
    .data_size_i(data_size),      // payload size
    .parity_size_i(parity_size),  // parity bit size
    .parity_type_i(parity_type),  // type of parity
    .stop_size_i(stop_size),      // stop bits size
    .data_i(tx_fq_data_out),      // data to transmit
    .tx_o(uart_tx_o),             // tx wire
    .tx_rdy_o(tx_rdy),            // module is ready flag
    .tx_state_o(tx_state)
);

`ifndef ASYNC
// Synchronous FIFO queue for tx module
sync_fifo #(
    .WIDTH(9),                      // width of data bus
    .DEPTH(TX_FIFO_DEPTH)           // depth of FIFO buffer
) tx_sync_fifo (
    .clk_i(clk_i),                  // input clock
    .rst_ni(rst_ni),                // reset signal
    .wdata_i(uart_wdata_i[8:0]),    // input data
    .we_i(tx_fq_we),                // write enable signal
    .re_i(tx_fq_re),                // read enable signal
    .rdata_o(tx_fq_data_out),       // output data
    .full_o(tx_fq_full),            // full flag
    .empty_o(tx_fq_empty),          // empty flag
    .near_full_o(tx_fq_near_full),  // near full flag
    .near_empty_o(tx_fq_near_empty) // near emtpy flag
);
`else
// Asynchronous FIFO queue for tx module
async_fifo #(
    .WIDTH(9), 
    .DEPTH(TX_FIFO_DEPTH)
) tx_async_fifo (
    .wclk_i(clk_i),
    .rst_ni(rst_ni),
    .wdata_i(uart_wdata_i[8:0]),
    .rclk_i(clk_M_i),
    .we_i(tx_fq_we),
    .re_i(tx_fq_re),
    .rdata_o(tx_fq_data_out),
    .full_o(tx_fq_full),
    .empty_o(tx_fq_empty),
    .near_full_o(rx_fq_near_full),
    .near_empty_o(rx_fq_near_empty)
);
`endif

assign rx_start = rx_buf[2] & ~rx_buf[1] & ~rx_buf[0] & rx_state == rx0.IDLE;

assign tx_start = ~tx_fq_empty;
assign tx_fq_we = (opcode == OP_WRITE_UART_DATA) & tx_en ;
assign tx_fq_re = tx_rdy & tx_en & tx_clk_en;
assign rx_fq_we = rx_rdy & ~rx_err & rx_clk_en;
assign rx_fq_re = (opcode == OP_READ_UART_DATA) & rx_en;

assign uart_irq_o = {tx_fq_near_full, ~rx_fq_empty};

always
`ifndef ASYNC
    @(posedge clk_i, negedge rst_ni)
`else
    @(posedge clk_M_i, negedge rst_ni)
`endif
begin
    if(~rst_ni) begin
        rx_buf <= 3'b111;
    end
    else begin
        rx_buf <= {rx_buf[1:0], uart_rx_i};
    end
end

always
`ifndef ASYNC
    @(posedge clk_i, negedge rst_ni)
`else
    @(posedge clk_M_i, negedge rst_ni) 
`endif begin
    if(~rst_ni) begin
        rx_tick_counter <= 32'b0;
        rx_clk_en <= 1'b0;
    end
    else begin
        rx_tick_counter <= (rx_clk_en)? 32'b0 : (rx_start)? baud_rate >> 1 : rx_tick_counter + 1'b1;
        rx_clk_en <= (rx_tick_counter == (baud_rate - 1'b1));
    end
end


always
`ifndef ASYNC
    @(posedge clk_i, negedge rst_ni)
`else
    @(posedge clk_M_i, negedge rst_ni)
`endif
begin
    if(~rst_ni) begin
        tx_tick_counter <= 32'b0;
        tx_clk_en <= 1'b0;
    end
    else begin
        tx_tick_counter <= (tx_clk_en)? 32'b0 : tx_tick_counter + 1'b1;
        tx_clk_en <= (tx_tick_counter == (baud_rate - 1'b1));
    end
end


always @(*) begin
    if(uart_req_i)
    case(addr_i[7:0])
    8'h00   : opcode <= (~we)? OP_READ_UART_DATA            : OP_DO_NOTHING;
    8'h04   : opcode <= (we)?  OP_WRITE_UART_DATA           : OP_DO_NOTHING;
    8'h08   : opcode <= (~we)? OP_READ_UART_STATE           : OP_DO_NOTHING;
    8'h0c   : opcode <= (we)?  OP_WRITE_UART_EN             : OP_DO_NOTHING;
    8'h10   : opcode <= (we)?  OP_WRITE_UART_PARAMETERS     : OP_DO_NOTHING;
    default : opcode <=        OP_DO_NOTHING;
    endcase
    else
    opcode <= OP_DO_NOTHING;
end

always @(*) begin
    uart_rvalid_d = 1'b1;
    case(opcode)
    OP_WRITE_UART_PARAMETERS : begin
        uart_rdata_d <= 32'b0;
        uart_err_d = 1'b0;
    end
    OP_READ_UART_DATA : begin
        uart_rdata_d <= {23'b0, rx_fq_data_out};
        uart_err_d = rx_fq_empty;
    end
    OP_WRITE_UART_DATA : begin
        uart_rdata_d <= 32'b0;
        uart_err_d <= tx_fq_full;
    end
    OP_READ_UART_STATE : begin
        uart_rdata_d <= {28'b0, tx_fq_near_full, rx_fq_near_empty, tx_fq_full, rx_fq_empty};
        uart_err_d = 1'b0;
    end
    OP_WRITE_UART_EN : begin
        uart_rdata_d <= 32'b0;        
    end
    default : begin
        uart_rdata_d <= 32'b0;
        uart_err_d = 1'b0;
    end
    endcase
end

always @(posedge clk_i, negedge rst_ni) begin
    if(~rst_ni) begin
        uart_rdata_q <= 32'b0;
        uart_rvalid_q <= 1'b0;
        uart_err_q <= 1'b0;
    end
    else begin
        uart_rdata_q <= uart_rdata_d;
        uart_rvalid_q <= uart_rvalid_d;
        uart_err_q <= uart_err_d;   
    end
end

always @(posedge clk_i, negedge rst_ni) begin
    if(~rst_ni) begin
        baud_rate <= CLOCK_FREQUENCY / 9600;
        data_size <= 4'h8;
        parity_size <= 1'b0;
        parity_type <= 1'b0;
        stop_size <= 2'b01;
        rx_en <= 1'b0;
        tx_en <= 1'b0;
    end
    else begin
        case(opcode)
        OP_WRITE_UART_PARAMETERS : begin
            case(uart_wdata_i[1:0])
            2'b00 : data_size <= 4'h6;
            2'b01 : data_size <= 4'h7;
            2'b10 : data_size <= 4'h8;
            2'b11 : data_size <= 4'h9;
            endcase
            parity_size <= uart_wdata_i[2];
            parity_type <= uart_wdata_i[3];
            stop_size <= (uart_wdata_i[4])? 2'b10 : 2'b01;
            case(uart_wdata_i[6:5])
            2'b00 : baud_rate <= CLOCK_FREQUENCY / 4800;
            2'b01 : baud_rate <= CLOCK_FREQUENCY / 9600; 
            2'b10 : baud_rate <= CLOCK_FREQUENCY / 57600;
            2'b11 : baud_rate <= CLOCK_FREQUENCY / 115200;
            endcase
        end
        OP_WRITE_UART_EN : begin
            {tx_en, rx_en} <= uart_wdata_i[1:0];
        end
        default : begin
        end
    endcase
    end
end

assign uart_rdata_o = uart_rdata_q;
assign uart_rvalid_o = uart_rvalid_q;
assign uart_err_o = uart_err_q;
assign uart_req_gnt_o = 1'b1;

endmodule