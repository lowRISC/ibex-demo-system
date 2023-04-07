module uart #(
    parameter CLOCK_FREQUENCY = 50_000_000,
    parameter RX_FIFO_DEPTH = 128,
    parameter TX_FIFO_DEPTH = 128
) (
    input wire clk_i,               // clock
    input wire rst_ni,              // reset not
    input wire we,                  // write enable
    input wire [3:0] be,            // byte enable
    input wire [31:0] uart_wdata_i, // data bus
    input wire [31:0] addr_i,       // addr bus
    input wire uart_req_i,          // request from core (IBEX LSU)
    input wire rx,                  // rx line
    output wire tx,                 // tx line
    output wire [31:0] uart_rdata_o,// data bus
    output wire uart_req_gnt_o,     // request granted to core (IBEX LSU)
    output wire uart_rvalid_o,      // request valid to core (IBEX LSU)
    output wire uart_irq_o,         // interrupt request (CSR)
    output wire uart_err_o,         // error to core (IBEX LSU)
    
    output wire [31:0] uart_debug_o
);

reg [31:0] uart_rdata_q, uart_rdata_d;
reg uart_rvalid_q, uart_rvalid_d;
reg uart_err_q, uart_err_d;

localparam [31:0] INSTRUCTION_SIZE = 5;                                  // size of instruction in bits
localparam [INSTRUCTION_SIZE-1:0] OP_WRITE_UART_PARAMETERS  = 5'b10000;  // set protocol parameters
localparam [INSTRUCTION_SIZE-1:0] OP_WRITE_UART_EN          = 5'b01000;  // write data from bus to FIFO tx queue
localparam [INSTRUCTION_SIZE-1:0] OP_READ_UART_STATE        = 5'b00100;  // read tx module state
localparam [INSTRUCTION_SIZE-1:0] OP_WRITE_UART_DATA        = 5'b00010;  // read rx module state
localparam [INSTRUCTION_SIZE-1:0] OP_READ_UART_DATA         = 5'b00001;  // read data from FIFO rx queue
localparam [INSTRUCTION_SIZE-1:0] OP_DO_NOTHING             = 5'b00000;  // do nothing
reg [INSTRUCTION_SIZE-1:0] opcode;     // instruction to execute

reg [3:0] data_size;    // data size in bits of protocol
reg parity_size;        // parity of protocol (0 or 1 parity bits)
reg parity_type;        // parity type of protocol (ODD (1) or EVEN (0))
reg [1:0] stop_size;    // stop size in bits of protocol (1 or 2)
reg [31:0] baud_rate;   // baud rate of protocol (default 9600)
wire baud_rate_clk;     // modulated clock according to baud rate

wire [8:0] rx_data;     // data received from serial
wire rx_rdy;            // ready flag
wire rx_err;            // error flag
reg rx_en;              // enable register of rx module

wire rx_fq_re;                  // rx FIFO read enable
wire rx_fq_we;                  // rx FIFO write enable
wire [8:0] rx_fq_data_out;      // rx FIFO data output
wire rx_fq_full;                // rx FIFO is full flag
wire rx_fq_empty;               // rx FIFO is empty flag

wire tx_rdy;            // ready flag
reg tx_en;              // enable register of tx module

wire tx_fq_re;                  // tx FIFO queue read enable
wire tx_fq_we;                  // tx FIFO queue write enable
wire [8:0] tx_fq_data_out;      // tx FIFO data output (to transmit)
wire tx_fq_full;                // tx FIFO is full flag
wire tx_fq_empty;               // tx FIFO is empty flag
wire [31:0] available_tx_space;

clock_divider baud_rate_gen (
    .clk(clk_i),
    .rstn(rst_ni),
    .divisor(baud_rate),
    .clk_m(baud_rate_clk)
);

rx_module rx0 (
    .clk_i(baud_rate_clk),          // baud rate
    .rst_ni(rst_ni),                // negative reset signal
    .en(rx_en),                     // rx enable
    .rx(rx),                        // rx pin
    .data_size_i(data_size),        // data size (payload)
    .parity_size_i(parity_size),    // parity bit
    .parity_type_i(parity_type),    // parity type
    .stop_size_i(stop_size),        // stop bits size
    .data_o(rx_data),               // data out (received data)
    .rx_rdy_o(rx_rdy),              // received new data flag
    .rx_err_o(rx_err)               // parity mismatch flag
);

// FIFO queue for rx module
fifo_queue #(
    .WIDTH(9),                  // width of data bus
    .DEPTH(RX_FIFO_DEPTH)        // depth of FIFO buffer
) rx_async_fifo (
    .clk1(baud_rate_clk),       // input clock 1 (write)
    .clk2(clk_i),               // input clock 2 (read)
    .rstn(rst_ni),              // reset signal
    .data_in(rx_data),          // input data
    .we(rx_fq_we),              // write enable signal
    .data_out(rx_fq_data_out),  // output data
    .re(rx_fq_re),              // read enable signal
    .full(rx_fq_full),          // full flag
    .empty(rx_fq_empty),        // empty flag
    .debug()
);

tx_module tx0 (
    .clk_i(baud_rate_clk),        // baud rate
    .rst_ni(rst_ni),              // reset signal
    .en(tx_en),                   // tx enable
    .tx_start_i(~tx_fq_empty),    // start transmission flag
    .data_size_i(data_size),      // payload size
    .parity_size_i(parity_size),  // parity bit size
    .parity_type_i(parity_type),  // type of parity
    .stop_size_i(stop_size),      // stop bits size
    .data_i(tx_fq_data_out),      // data to transmit
    .tx(tx),                      // tx wire
    .tx_rdy_o(tx_rdy)             // module is ready flag
);

// FIFO queue for tx module
fifo_queue #(
    .WIDTH(9),                  // width of data bus
    .DEPTH(TX_FIFO_DEPTH)        // depth of FIFO buffer
) tx_async_fifo (
    .clk1(clk_i),               // input clock 1 (write)
    .clk2(baud_rate_clk),       // input clock 2 (read)
    .rstn(rst_ni),              // reset signal
    .data_in(uart_wdata_i[8:0]),// input data
    .we(tx_fq_we),              // write enable signal
    .data_out(tx_fq_data_out),  // output data
    .re(tx_fq_re),              // read enable signal
    .full(tx_fq_full),          // full flag
    .empty(tx_fq_empty),        // empty flag
    .debug(uart_debug_o)
);

assign tx_fq_we = (opcode == OP_WRITE_UART_DATA) & tx_en ;
assign tx_fq_re = tx_rdy & tx_en;
assign rx_fq_we = rx_rdy & ~rx_err;
assign rx_fq_re = (opcode == OP_READ_UART_DATA) & rx_en;

assign uart_irq_o = ~rx_fq_empty;

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
    uart_err_d = 1'b0;
    uart_rvalid_d = 1'b1;
    case(opcode)
    OP_WRITE_UART_PARAMETERS : begin
        uart_rdata_d <= 32'b0;
    end
    OP_READ_UART_DATA : begin
        uart_rdata_d <= {23'b0, rx_fq_data_out};
    end
    OP_WRITE_UART_DATA : begin
        uart_rdata_d <= 32'b0;
    end
    OP_READ_UART_STATE : begin
        uart_rdata_d <= {30'b0, ~tx_fq_full, ~rx_fq_empty};
    end
    OP_WRITE_UART_EN : begin
        uart_rdata_d <= 32'b0;
    end
    default : begin
        uart_rdata_d <= 32'b0;
    end
    endcase
end

always @(posedge clk_i, negedge rst_ni) begin
    if(~rst_ni) begin
        uart_rdata_q <= 32'b0;;
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
            2'b11 : data_size <= 4'h8;
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

endmodule