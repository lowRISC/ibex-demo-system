module uart #(
    parameter FREQUENCY = 100_000_000,
    parameter RX_FIFO_SIZE = 4,
    parameter TX_FIFO_SIZE = 4
) (
    input wire clk_i,               // clock
    input wire rst_ni,              // reset not
    input wire we,                  // write enable
    input wire [3:0] be,            // byte enable
    input wire [31:0] data_i,       // data bus
    input wire [31:0] addr_i,       // addr bus
    input wire uart_req_i,          // request from core (IBEX LSU)
    input wire rx,                  // rx line
    output wire tx,                 // tx line
    output wire [31:0] data_o,      // data bus
    output wire uart_req_gnt_o,     // request granted to core (IBEX LSU)
    output reg uart_rvalid_o,       // request valid to core (IBEX LSU)
    output reg [1:0] uart_irq_o,    // interrupt request (CSR)
    output reg uart_err_o           // error to core (IBEX LSU)
);

localparam [31:0] INSTRUCTION_SIZE = 4;                             // size of instruction in bits
localparam [INSTRUCTION_SIZE-1:0] OP_WRITE_PARAMETERS = 4'b0111;    // set protocol parameters
localparam [INSTRUCTION_SIZE-1:0] OP_WRITE_TX_EN = 4'b0110;         // write enable register of tx module
localparam [INSTRUCTION_SIZE-1:0] OP_WRITE_RX_EN = 4'b0101;         // write enable register of rx module
localparam [INSTRUCTION_SIZE-1:0] OP_WRITE_TX_DATA = 4'b0100;       // write data from bus to FIFO tx queue
localparam [INSTRUCTION_SIZE-1:0] OP_READ_TX_STATE = 4'b0011;       // read tx module state
localparam [INSTRUCTION_SIZE-1:0] OP_READ_RX_STATE = 4'b0010;       // read rx module state
localparam [INSTRUCTION_SIZE-1:0] OP_READ_RX_DATA = 4'b0001;        // read data from FIFO rx queue
localparam [INSTRUCTION_SIZE-1:0] OP_DO_NOTHING = 4'b0000;          // do nothing
reg [INSTRUCTION_SIZE-1:0] opcode;     // instruction to execute
reg ce;                                // chip enable (on valid address and request)

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

wire [8:0] tx_data;     // data to be transmited
wire tx_start;          // start flag
wire tx_rdy;            // ready flag
wire tx_done;           // transmission done flag
reg tx_en;              // enable register of tx module

wire tx_fq_re;                  // tx FIFO queue read enable
wire tx_fq_we;                  // tx FIFO queue write enable
wire [8:0] tx_fq_data_out;      // tx FIFO data output (to transmit)
wire tx_fq_full;                // tx FIFO is full flag
wire tx_fq_empty;               // tx FIFO is empty flag

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
    .DEPTH(RX_FIFO_SIZE)        // depth of FIFO buffer
) rx_async_fifo (
    .clk1(baud_rate_clk),       // input clock 1 (write)
    .clk2(clk_i),               // input clock 2 (read)
    .rstn(rst_ni),              // reset signal
    .data_in(rx_data),          // input data
    .we(rx_fq_we),              // write enable signal
    .data_out(rx_fq_data_out),  // output data
    .re(rx_fq_re),              // read enable signal
    .full(rx_fq_full),          // full flag
    .empty(rx_fq_empty)         // empty flag
);

tx_module tx0 (
    .clk_i(baud_rate_clk),        // baud rate
    .rst_ni(rst_ni),              // reset signal
    .en(tx_en),                   // tx enable
    .tx_start_i(tx_start),        // start transmission flag
    .data_size_i(data_size),      // payload size
    .parity_size_i(parity_size),  // parity bit size
    .parity_type_i(parity_type),  // type of parity
    .stop_size_i(stop_size),      // stop bits size
    .data_i(tx_fq_data_out),      // data to transmit
    .tx(tx),                      // tx wire
    .tx_rdy_o(tx_rdy),            // module is ready flag
    .tx_done_o(tx_done)           // done transmitting
);

// FIFO queue for tx module
fifo_queue #(
    .WIDTH(9),                  // width of data bus
    .DEPTH(TX_FIFO_SIZE)        // depth of FIFO buffer
) tx_async_fifo (
    .clk1(clk_i),               // input clock 1 (write)
    .clk2(baud_rate_clk),       // input clock 2 (read)
    .rstn(rst_ni),              // reset signal
    .data_in(tx_data),          // input data
    .we(tx_fq_we),              // write enable signal
    .data_out(tx_fq_data_out),  // output data
    .re(tx_fq_re),              // read enable signal
    .full(tx_fq_full),          // full flag
    .empty(tx_fq_empty)         // empty flag
);

assign data_o = (opcode == OP_READ_RX_DATA)? {23'b0, rx_fq_data_out} :
                (opcode == OP_READ_RX_STATE)? {31'b0, ~rx_fq_empty} :
                (opcode == OP_READ_TX_STATE)? {31'b0, ~tx_fq_full} : 32'bz;

assign uart_req_gnt_o = (opcode == OP_READ_RX_DATA)? ~rx_fq_empty :
                        (opcode == OP_DO_NOTHING)? 1'b0 : 1'b1;

always @(addr_i, uart_req_i) ce <= addr_i >= 32'hffff_ffe0 && addr_i <= 32'hffff_fff8 && uart_req_i;

always @(ce, addr_i, we) begin
    if(ce)
    case(addr_i[7:0])
    8'he0   : opcode <= (~we)? OP_READ_RX_DATA      : OP_DO_NOTHING;
    8'he4   : opcode <= (we)? OP_WRITE_TX_DATA      : OP_DO_NOTHING;
    8'he8   : opcode <= (~we)? OP_READ_RX_STATE     : OP_DO_NOTHING;
    8'hec   : opcode <= (~we)? OP_READ_TX_STATE     : OP_DO_NOTHING;
    8'hf0   : opcode <= (we)? OP_WRITE_RX_EN        : OP_DO_NOTHING;
    8'hf4   : opcode <= (we)? OP_WRITE_TX_EN        : OP_DO_NOTHING;
    8'hf8   : opcode <= (we)? OP_WRITE_PARAMETERS   : OP_DO_NOTHING;
    default : opcode <= OP_DO_NOTHING;
    endcase
    else
    opcode <= OP_DO_NOTHING;
end

assign tx_data = data_i[8:0];
assign tx_fq_we = opcode == OP_WRITE_TX_DATA & tx_en ;
assign tx_fq_re = tx_rdy & tx_en;
assign tx_start = ~tx_fq_empty;

assign rx_fq_we = rx_rdy & ~rx_err;
assign rx_fq_re = opcode == OP_READ_RX_DATA & rx_en;

always @(posedge clk_i, negedge rst_ni) begin
    if(~rst_ni) begin
        uart_irq_o <= 2'b0;
        uart_rvalid_o <= 1'b0;
        uart_err_o <= 1'b0;
    end
    else begin
        uart_irq_o[0] <= (opcode == OP_READ_RX_DATA)? 1'b0 : (~rx_fq_empty)? 1'b1 : uart_irq_o[0];  // packet received
        uart_irq_o[1] <= (opcode == OP_READ_RX_DATA)? 1'b0 : (rx_fq_full)? 1'b1 : uart_irq_o[1];    // fifo queue is full
        uart_rvalid_o <= uart_req_gnt_o;
        uart_err_o <= 1'b0;
    end
end

always @(posedge clk_i, negedge rst_ni) begin
    if(~rst_ni) begin
        baud_rate <= FREQUENCY / 9600;
        data_size <= 4'h8;
        parity_size <= 1'b0;
        parity_type <= 1'b0;
        stop_size <= 2'b01;
        rx_en <= 1'b1;
        tx_en <= 1'b1;
    end
    else begin
        case(opcode)
        OP_WRITE_PARAMETERS : begin
            case(data_i[1:0])
            2'b00 : data_size <= 4'h6;
            2'b01 : data_size <= 4'h7;
            2'b10 : data_size <= 4'h8;
            2'b11 : data_size <= 4'h8;
            endcase
            parity_size <= data_i[2];
            parity_type <= data_i[3];
            stop_size <= (data_i[4])? 2'b10 : 2'b01;
            case(data_i[6:5])
            2'b00 : baud_rate <= FREQUENCY / 4800;
            2'b01 : baud_rate <= FREQUENCY / 9600; 
            2'b10 : baud_rate <= FREQUENCY / 57600;
            2'b11 : baud_rate <= FREQUENCY /115200;
            endcase
        end
        OP_WRITE_TX_DATA : begin     
        end
        OP_READ_RX_DATA : begin
        end
        OP_READ_RX_STATE : begin
        end
        OP_READ_TX_STATE : begin
        end
        OP_WRITE_RX_EN : begin
            rx_en <= data_i[0];
        end
        OP_WRITE_TX_EN : begin
            tx_en <= data_i[0];
        end
        OP_DO_NOTHING : begin
        end
        default : begin
        end
    endcase
    end
end

endmodule