module hex_disp_driver(
    clk,
    data_in,
    hex_out,
    sel
);

input wire clk;
input wire [31:0] data_in;
output wire [7:0] hex_out;
output wire [3:0] sel;

reg [1:0] c;

reg [7:0] d0;
reg [7:0] d1;
reg [7:0] d2;
reg [7:0] d3;

assign sel = (c == 0)? 4'bzzz0 : (c == 1)? 4'bzz0z : (c == 2)? 4'bz0zz : 4'b0zzz;
assign hex_out = (c == 0)? d3 : (c == 1)? d2 : (c == 2)? d1 : d0;

parameter DIVISOR = 100_000;
reg [31:0] counter;
reg clk_m;
always @ (posedge clk) begin
    counter <= (counter < DIVISOR - 1)? counter + 1'b1 : 32'b0;
    clk_m <= (counter < DIVISOR / 2)? 1'b1 : 1'b0;
end

always @(posedge clk_m)
    c <= c + 1'b1;

reg [7:0] map_ra [0:15];
initial begin
    map_ra[0] <= 'heb;
    map_ra[1] <= 'h28;
    map_ra[2] <= 'hb3;
    map_ra[3] <= 'hba;
    map_ra[4] <= 'h78;
    map_ra[5] <= 'hda;
    map_ra[6] <= 'hdb;
    map_ra[7] <= 'ha8;
    map_ra[8] <= 'hfb;
    map_ra[9] <= 'hfa;
    map_ra[10] <= 'hf9;
    map_ra[11] <= 'h5b;
    map_ra[12] <= 'hc3;
    map_ra[13] <= 'h3b;
    map_ra[14] <= 'hd3;
    map_ra[15] <= 'hd1;
end
always @(data_in) begin
    d3 <= map_ra[data_in[3:0]];
    d2 <= map_ra[data_in[7:4]];
    d1 <= map_ra[data_in[15:8]];
    d0 <= map_ra[data_in[23:16]];
end

endmodule
