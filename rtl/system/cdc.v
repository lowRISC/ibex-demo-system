/*
* 2 DFF sync clock domain crossing
* for async fifo queue
*/
module cdc #(
    parameter WIDTH = 32
) (
    input wire clk_i,
    input wire rst_ni,
    input wire [WIDTH-1:0] wdata_i,
    output reg [WIDTH-1:0] rdata_o
);

reg [WIDTH-1:0] p0;

always @(posedge clk_i, negedge rst_ni)
    if(~rst_ni) begin
        p0 <= 0;
        rdata_o <= 0;
    end
    else
        {rdata_o, p0} <= {p0, wdata_i};

endmodule
