module clock_divider(
    clk,
    rstn,
    divisor,
    clk_m
);

input wire clk;
input wire rstn;
input wire [31:0] divisor;
output reg clk_m;

reg [31:0] counter;

always @ (posedge clk, negedge rstn) begin
    if(~rstn) begin
        counter <= 32'b0;
        clk_m <= 1'b1;
    end
    else begin
        counter <= (counter < divisor - 1)? counter + 1'b1 : 32'b0;
        clk_m <= (counter < divisor / 2)? 1'b1 : 1'b0;
    end
end
endmodule