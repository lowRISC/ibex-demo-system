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
    output reg tx,
    output reg tx_rdy_o,
    output reg tx_done_o
);

localparam IDLE = 0; // Waiting to send data
localparam WRITE = 1; // Transmitting frame

reg [3:0] frame_counter;
reg [11:0] frame_buffer;
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
                tx <= 1'b1;
                tx_rdy_o <= 1'b1;
                // Size of frame in bits
                frame_counter <= stop_size_i + parity_size_i + data_size_i + 1;
                // if none parity just fill with logic 1
                // else calculate appropriate parity
                case(data_size_i)
                    6 : begin
                        frame_buffer <= {4'b1111, (~|parity_size_i)? 1'b1 : (parity_type_i)? ^data_i : ~^data_i, data_i[5:0], 1'b0};
                    end
                    7 : begin
                        frame_buffer <= {3'b111, (~|parity_size_i)? 1'b1 : (parity_type_i)? ^data_i : ~^data_i, data_i[6:0], 1'b0};
                    end
                    8 : begin
                        frame_buffer <= {2'b11, (~|parity_size_i)? 1'b1 : (parity_type_i)? ^data_i : ~^data_i, data_i[7:0], 1'b0};
                    end
                    default : begin
                        frame_buffer <= {1'b1, (~|parity_size_i)? 1'b1 : (parity_type_i)? ^data_i : ~^data_i, data_i, 1'b0};
                    end
                endcase
            end
            WRITE : begin
                tx_rdy_o <= 1'b0;
                tx_done_o <= ~|frame_counter;
                tx <= frame_buffer[0];
                if(frame_counter > 0)
                    frame_counter <= frame_counter - 1;
                frame_buffer <= {1'b1, frame_buffer[11:1]};
            end
        endcase
    end
end

always @(state, tx_start_i, frame_counter)
    case(state)
        IDLE : next_state <= (tx_start_i & en)? WRITE : IDLE;
        WRITE : next_state <= (~|frame_counter)? IDLE : WRITE;
        default : next_state <= IDLE;
    endcase

endmodule
