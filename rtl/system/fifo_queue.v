module fifo_queue #(
    parameter WIDTH = 32,       // width of data bus
    parameter DEPTH = 16       // depth of FIFO buffer
) (
    input wire [WIDTH-1:0] data_in,
    input wire clk1,
    input wire clk2,
    input wire rstn,
    input wire we,
    input wire re,
    output wire [WIDTH-1:0] data_out,
    output wire full,
    output wire empty,
    
    output wire [15:0] debug
);

localparam ADDR_BITS = $clog2(DEPTH);   // address width for buffer

reg [ADDR_BITS:0] w_ptr, r_ptr;
wire [ADDR_BITS:0] w_ptr_gray, r_ptr_gray;

wire [ADDR_BITS:0] w_ptr_next, r_ptr_next;
wire [ADDR_BITS:0] w_ptr_next_gray, r_ptr_next_gray;

wire [ADDR_BITS-1:0] w_addr, r_addr;

wire [ADDR_BITS:0] w_ptr_sync_gray, r_ptr_sync_gray;
reg [ADDR_BITS:0] w_ptr_sync_bin, r_ptr_sync_bin;

wire full_next, empty_next;

reg [WIDTH-1:0] mem [0:DEPTH-1];

assign w_ptr_next = (we & ~full)? w_ptr + 1'b1 : w_ptr;
assign r_ptr_next = (re & ~empty)? r_ptr + 1'b1 : r_ptr;

assign w_addr = w_ptr[ADDR_BITS-1:0];
assign r_addr = r_ptr[ADDR_BITS-1:0];

assign w_ptr_gray = w_ptr ^ (w_ptr >> 1);
assign r_ptr_gray = r_ptr ^ (r_ptr >> 1);

assign w_ptr_next_gray = w_ptr_next ^ (w_ptr_next >> 1);
assign r_ptr_next_gray = r_ptr_next ^ (r_ptr_next >> 1);

cdc #(
    .WIDTH(ADDR_BITS+1)
) cdc_w2r_w_ptr (
    .clk(clk2),
    .rstn(rstn),
    .data_in(w_ptr_gray),
    .data_out(w_ptr_sync_gray)
);

cdc #(
    .WIDTH(ADDR_BITS+1)
) cdc_r2w_r_ptr (
    .clk(clk1),
    .rstn(rstn),
    .data_in(r_ptr_gray),
    .data_out(r_ptr_sync_gray)
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

always @(posedge clk1, negedge rstn)
    if(~rstn)
        w_ptr <= 0;
    else
        w_ptr <= w_ptr_next;

always @(posedge clk1, negedge rstn) begin : write
    if(~rstn)
        for(i = 0; i < DEPTH; i = i+1)
            mem[i] <= 0; 
    else if(we & ~full)
        mem[w_addr] <= data_in;
end

always @(posedge clk2, negedge rstn) begin : read
    if(~rstn)
        r_ptr <= 0;
    else
        r_ptr <= r_ptr_next;
end

assign full = w_ptr == {~r_ptr_sync_bin[ADDR_BITS], r_ptr_sync_bin[ADDR_BITS-1:0]};
assign empty = r_ptr == w_ptr_sync_bin;
assign data_out = mem[r_addr];
assign debug = {mem[1][7:0], mem[0][7:0]};

endmodule