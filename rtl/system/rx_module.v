module rx_module (
    input wire clk_i,
    input wire rst_ni,
    input wire en,
    input wire rx,
    input wire [3:0] data_size_i,
    input wire parity_size_i,
    input wire parity_type_i,
    input wire [1:0] stop_size_i,
    output wire [8:0] data_o,
    output wire rx_rdy_o,
    output wire rx_err_o
);

localparam	IDLE = 0;
localparam	DATA = 1;
localparam	PARITY = 2;
localparam	STOP = 3;

reg [3:0] data_counter;
reg [3:0] data_size;
reg parity_counter;
reg parity_size;
reg [1:0] stop_counter;
reg [1:0] stop_size;
reg [8:0] data_buf;
reg parity_buf;
reg parity_type;
reg [1:0] stop_buf;
reg [1:0] state;
reg [1:0] next_state;

reg [8:0] data_d;
reg rx_rdy_d;
reg rx_err_d;

always @(*) begin
    case(data_size)
	   6 : data_d <= {3'b0, data_buf[8:3]};
       7 : data_d <= {2'b0, data_buf[8:2]};
       8 : data_d <= {1'b0, data_buf[8:1]};
       9 : data_d <= data_buf;
       default : data_d <= data_buf;
    endcase
end

always @(*) begin
    case(state)
    IDLE : begin
        rx_rdy_d <= 1'b0;
        rx_err_d <= 1'b0;
    end
    DATA : begin
        rx_rdy_d <= rx_rdy_d;
        rx_err_d <= rx_err_d;
    end
    PARITY : begin
        rx_rdy_d <= rx_rdy_d;
        rx_err_d <= rx_err_d;
    end
    STOP : begin
        rx_rdy_d <= ~|stop_counter;
        rx_err_d <= (|parity_size) & ((^{data_buf, parity_buf} & ~parity_type) | 
                    (~^{data_buf, parity_buf} & parity_type));
    end
    endcase
end

always @(posedge clk_i, negedge rst_ni) begin
    if(~rst_ni) begin
       state <= IDLE;
	end
    else begin
	   state <= next_state;
	   case(state)
            IDLE : begin                
                data_counter <= data_size_i - 1;
                parity_counter <= parity_size_i - 1;
                stop_counter <= stop_size_i - 1;
                
                data_size <= data_size_i;
                parity_size <= parity_size_i;
                parity_type <= parity_type_i;
                stop_size <= stop_size_i;
                
                data_buf <= 0;
                parity_buf <= 0;
                stop_buf <= 0;
            end
            DATA : begin
                data_counter <= data_counter - 1;
                data_buf <= {rx, data_buf[8:1]};
            end
            PARITY : begin
                parity_counter <= parity_counter - 1;
                parity_buf <= rx;
            end
            STOP : begin
                stop_counter <= stop_counter - 1;
                stop_buf <= {rx, stop_buf[1]};
            end
        endcase
    end
end

always @ (*) begin
	case(state)
		IDLE : next_state <= (~rx & en)? DATA : IDLE;
		DATA : next_state <= (|data_counter)? DATA : (|(parity_size))? PARITY : STOP;
		PARITY : next_state <= (|parity_counter)? PARITY : STOP;
		STOP : next_state <= (|stop_counter)? STOP : IDLE;
		default : next_state <= IDLE;
	endcase
end

assign data_o = data_d;
assign rx_rdy_o = rx_rdy_d;
assign rx_err_o = rx_err_d;

endmodule