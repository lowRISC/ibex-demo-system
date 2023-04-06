module cdc #(
    parameter WIDTH = 32
) (
    input wire clk, rstn,
    input wire [WIDTH-1:0] data_in,
    output reg [WIDTH-1:0] data_out
);

reg [WIDTH-1:0] p0;

always @(posedge clk, negedge rstn)
    if(~rstn) begin
        p0 <= 0;
        data_out <= 0;
    end
    else
        {data_out, p0} <= {p0, data_in};

endmodule
