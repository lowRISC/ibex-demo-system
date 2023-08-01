`include "synchronizer.v"
`timescale 1ns/1ps

module async_fifo #(
    parameter WIDTH = 32,      // width of data bus
    parameter DEPTH = 16       // depth of FIFO buffer
) (
    input wire [WIDTH-1:0] wdata_i,
    input wire wclk_i,
    input wire rclk_i,
    input wire rst_ni,
    input wire we_i,
    input wire re_i,
    output wire [WIDTH-1:0] rdata_o,
    output wire full_o,
    output wire empty_o
);

localparam ADDR_BITS = $clog2(DEPTH);   // address width for buffer

reg [ADDR_BITS:0] w_ptr, r_ptr;
wire [ADDR_BITS:0] w_ptr_gray, r_ptr_gray;

wire [ADDR_BITS:0] w_ptr_next, r_ptr_next;
wire [ADDR_BITS:0] w_ptr_next_gray, r_ptr_next_gray;

wire [ADDR_BITS-1:0] w_addr, r_addr;

wire [ADDR_BITS:0] w_ptr_sync_gray, r_ptr_sync_gray;
reg [ADDR_BITS:0] w_ptr_sync_bin, r_ptr_sync_bin;

reg [WIDTH-1:0] mem [0:DEPTH-1];

assign w_ptr_next = (we_i & ~full_o)? w_ptr + 1'b1 : w_ptr;
assign r_ptr_next = (re_i & ~empty_o)? r_ptr + 1'b1 : r_ptr;

assign w_addr = w_ptr[ADDR_BITS-1:0];
assign r_addr = r_ptr[ADDR_BITS-1:0];

assign w_ptr_gray = w_ptr ^ (w_ptr >> 1);
assign r_ptr_gray = r_ptr ^ (r_ptr >> 1);

assign w_ptr_next_gray = w_ptr_next ^ (w_ptr_next >> 1);
assign r_ptr_next_gray = r_ptr_next ^ (r_ptr_next >> 1);

ff2_sync #(
    .WIDTH(ADDR_BITS+1)
) sync_w2r_w_ptr (
    .clk_i(rclk_i),
    .rst_ni(rst_ni),
    .wdata_i(w_ptr_gray),
    .rdata_o(w_ptr_sync_gray)
);

ff2_sync #(
    .WIDTH(ADDR_BITS+1)
) sync_r2w_r_ptr (
    .clk_i(wclk_i),
    .rst_ni(rst_ni),
    .wdata_i(r_ptr_gray),
    .rdata_o(r_ptr_sync_gray)
);

integer i;
always @(*) begin : gray_to_bin_w_ptr
    for(i=0; i<ADDR_BITS+1; i = i+1)
        w_ptr_sync_bin[i] = ^(w_ptr_sync_gray >> i);
end

always @(*) begin : gray_to_bin_r_ptr
    for(i=0; i<ADDR_BITS+1; i = i+1)
        r_ptr_sync_bin[i] = ^(r_ptr_sync_gray >> i);
end

always @(posedge wclk_i, negedge rst_ni)
    if(~rst_ni)
        w_ptr <= 0;
    else
        w_ptr <= w_ptr_next;

always @(posedge wclk_i) begin : write
    if(we_i & ~full_o)
        mem[w_addr] <= wdata_i;
end

always @(posedge rclk_i, negedge rst_ni) begin : read
    if(~rst_ni)
        r_ptr <= 0;
    else
        r_ptr <= r_ptr_next;
end

assign full_o = w_ptr == {~r_ptr_sync_bin[ADDR_BITS], r_ptr_sync_bin[ADDR_BITS-1:0]};
assign empty_o = r_ptr == w_ptr_sync_bin;
assign rdata_o = mem[r_addr];

endmodule