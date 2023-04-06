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
    output reg full,
    output reg empty
);

localparam ADDR_BITS = $clog2(DEPTH);   // address width for buffer

reg [ADDR_BITS:0] w_ptr, r_ptr;
wire [ADDR_BITS:0] w_ptr_gray, r_ptr_gray;

wire [ADDR_BITS:0] w_ptr_next, r_ptr_next;
wire [ADDR_BITS:0] w_ptr_next_gray, r_ptr_next_gray;

wire [ADDR_BITS-1:0] w_addr, r_addr;

wire [ADDR_BITS:0] w_ptr_sync_gray, r_ptr_sync_gray;

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

always @(posedge clk1, negedge rstn)
    if(~rstn)
        w_ptr <= 0;
    else
        w_ptr <= w_ptr_next;

integer i;
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

assign full_next = w_ptr_next_gray == {~r_ptr_sync_gray[ADDR_BITS:ADDR_BITS-1], r_ptr_sync_gray[ADDR_BITS-2:0]};
assign empty_next = r_ptr_next_gray == w_ptr_sync_gray;

always @(posedge clk1, negedge rstn)
    if(~rstn)
        full <= 1'b0;
    else
        full <= full_next;

always @(posedge clk2, negedge rstn)
    if(~rstn)
        empty <= 1'b1;
    else
        empty <= empty_next;

assign data_out = mem[r_addr];

endmodule