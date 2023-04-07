module tx_module (
    input wire clk_i,
    input wire rst_ni,
    input wire en,
    input wire tx_start_i,
    input wire [3:0] data_size_i,
    input wire parity_size_i,
    input wire parity_type_i,
    input wire [1:0] stop_size_i,
    input wire [8:0] data_i,
    output wire tx,
    output wire tx_rdy_o
);

localparam IDLE  = 0; // Waiting to send data
localparam WRITE = 1; // Transmitting frame

reg [3:0] frame_counter;
reg [12:0] frame_buffer;
reg state;
reg next_state;

always @ (posedge clk_i, negedge rst_ni) begin
    if(~rst_ni) begin
        state <= IDLE;
    end
    else begin
        state <= next_state;
        case(state)
            IDLE : begin
                // Size of frame in bits
                frame_counter <= stop_size_i + parity_size_i + data_size_i + 1 + 1;
                // if none parity just fill with logic 1
                // else calculate appropriate parity
                case(data_size_i)
                    6 : begin
                        frame_buffer <= {4'b1111, (~|parity_size_i)? 1'b1 : (parity_type_i)? ^data_i : ~^data_i, data_i[5:0], 2'b01};
                    end
                    7 : begin
                        frame_buffer <= {3'b111, (~|parity_size_i)? 1'b1 : (parity_type_i)? ^data_i : ~^data_i, data_i[6:0], 2'b01};
                    end
                    8 : begin
                        frame_buffer <= {2'b11, (~|parity_size_i)? 1'b1 : (parity_type_i)? ^data_i : ~^data_i, data_i[7:0], 2'b01};
                    end
                    default : begin
                        frame_buffer <= {1'b1, (~|parity_size_i)? 1'b1 : (parity_type_i)? ^data_i : ~^data_i, data_i, 2'b01};
                    end
                endcase
            end
            WRITE : begin
                frame_counter <= frame_counter - 1;
                frame_buffer <= {1'b1, frame_buffer[11:1]};
            end
        endcase
    end
end

always @(*)
    case(state)
        IDLE : next_state <= (tx_start_i & en)? WRITE : IDLE;
        WRITE : next_state <= (~|frame_counter)? IDLE : WRITE;
        default : next_state <= IDLE;
    endcase

assign tx_rdy_o = state == IDLE;
assign tx = (state == WRITE)? frame_buffer[0] : 1'b1;

endmodule
