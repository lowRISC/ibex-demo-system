module sync_fifo #(
    parameter WIDTH = 32,
    parameter DEPTH = 128
) (
    input wire clk_i,
    input wire rst_ni,
    input wire [WIDTH-1:0] wdata_i,
    input wire we_i,
    input wire re_i,
    output wire [WIDTH-1:0] rdata_o,
    output wire full_o,
    output wire empty_o,
    output wire near_full_o,
    output wire near_empty_o
);

localparam ADDR_BITS = $clog2(DEPTH);   // address width for buffer

reg [ADDR_BITS:0] w_ptr, r_ptr;
wire [ADDR_BITS:0] w_ptr_incr, r_ptr_incr;
wire [ADDR_BITS:0] w_ptr_next, r_ptr_next;

wire [ADDR_BITS-1:0] w_addr, r_addr;

wire full_next, empty_next;

reg [WIDTH-1:0] mem [0:DEPTH-1];

assign w_ptr_incr = w_ptr + 1'b1;
assign r_ptr_incr = r_ptr + 1'b1;

assign w_ptr_next = (~full_o & we_i)? w_ptr_incr : w_ptr;
assign r_ptr_next = (~empty_o & re_i)? r_ptr_incr : r_ptr;

assign full_o = r_ptr == {~w_ptr[ADDR_BITS], w_ptr[ADDR_BITS-1:0]};
assign empty_o = r_ptr == w_ptr;

assign near_full_o = r_ptr == {~w_ptr_incr[ADDR_BITS], w_ptr_incr[ADDR_BITS-1:0]+1'b1};
assign near_empty_o = r_ptr_incr == w_ptr;

assign rdata_o = (empty_o)? {WIDTH{1'b0}} : mem[r_addr];

assign w_addr = w_ptr[ADDR_BITS-1:0];
assign r_addr = r_ptr[ADDR_BITS-1:0];

always @(posedge clk_i, negedge rst_ni) begin
    if(~rst_ni) begin
        w_ptr <= {ADDR_BITS+1{1'b0}};
        r_ptr <= {ADDR_BITS+1{1'b0}};
    end
    else begin
        w_ptr <= w_ptr_next;
        r_ptr <= r_ptr_next;
    end
end

always @(posedge clk_i) begin
    if(we_i & ~full_o) begin
        mem[w_addr] <= wdata_i;
    end
end

endmodule