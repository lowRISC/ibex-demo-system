module plic #(
    parameter int SOURCES    = 32,
    parameter int TARGETS    = 1,
    parameter int PRIORITIES = 3,
    parameter int MAX_PENDING = 32
) (
    input  logic                clk_i,
    input  logic                rst_ni,

    // Bus interface
    input  logic                req_i,
    input  logic [31:0]         addr_i,
    input  logic                we_i,
    input  logic [3:0]          be_i,
    input  logic [31:0]         wdata_i,
    output logic                rvalid_o,
    output logic [31:0]         rdata_o,

    // Interrupt sources
    input  logic [SOURCES-1:0]  irq_sources_i,
    output logic [SOURCES-1:0]  irq_pending_o,

    // Interrupt notification to target
    output logic [TARGETS-1:0]  irq_o
);

    // Register map
    localparam int PRIORITY_BASE    = 'h000000;    // Source priority registers
    localparam int PENDING_BASE     = 'h001000;    // Pending bits
    localparam int ENABLE_BASE      = 'h002000;    // Enable bits
    localparam int THRESHOLD_BASE   = 'h200000;    // Priority threshold
    localparam int CLAIM_COMPLETE   = 'h200004;    // Claim/complete

    // Internal registers
    logic [PRIORITIES-1:0] priorities [SOURCES];
    logic [SOURCES-1:0]    enables;
    logic [PRIORITIES-1:0] threshold;
    logic [SOURCES-1:0]    pending;
    logic [$clog2(SOURCES)-1:0] claimed_irq;

    // Register interface
    logic [31:0] reg_rdata;
    logic reg_write;
    logic reg_read;
    
    assign reg_write = req_i & we_i;
    assign reg_read  = req_i & ~we_i;
    
    // Write handling
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            for (int i = 0; i < SOURCES; i++) begin
                priorities[i] <= '0;
            end
            enables    <= '0;
            threshold <= '0;
        end else if (reg_write) begin
            case (addr_i[15:12])
                5'h0: begin // Priority registers
                    if (addr_i[11:2] < SOURCES) begin
                        priorities[addr_i[11:2]] <= wdata_i[PRIORITIES-1:0];
                    end
                end
                5'h2: begin // Enable registers
                    if (addr_i[11:2] == 0) enables <= wdata_i[SOURCES-1:0];
                end
                5'h20: begin // Threshold and claim/complete
                    if (addr_i[3:2] == 0) threshold <= wdata_i[PRIORITIES-1:0];
                    else if (addr_i[3:2] == 1) begin
                        // Handle interrupt completion
                        if (wdata_i < SOURCES) pending[wdata_i] <= 1'b0;
                    end
                end
                default: begin end
            endcase
        end
    end

    // Read handling
    always_comb begin
        reg_rdata = '0;
        case (addr_i[15:12])
            5'h0: begin // Priority registers
                if (addr_i[11:2] < SOURCES) begin
                    reg_rdata = {{(32-PRIORITIES){1'b0}}, priorities[addr_i[11:2]]};
                end
            end
            5'h1: begin // Pending registers
                if (addr_i[11:2] == 0) reg_rdata = pending;
            end
            5'h2: begin // Enable registers
                if (addr_i[11:2] == 0) reg_rdata = enables;
            end
            5'h20: begin // Threshold and claim/complete
                if (addr_i[3:2] == 0) begin
                    reg_rdata = {{(32-PRIORITIES){1'b0}}, threshold};
                end else if (addr_i[3:2] == 1) begin
                    // Return highest priority pending interrupt
                    reg_rdata = claimed_irq;
                end
            end
            default: reg_rdata = '0;
        endcase
    end

    // Interrupt handling logic
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            pending <= '0;
        end else begin
            for (int i = 0; i < SOURCES; i++) begin
                if (irq_sources_i[i] && enables[i]) pending[i] <= 1'b1;
            end
        end
    end

    // Find highest priority pending interrupt
    always_comb begin
        logic found_irq;
        logic [$clog2(SOURCES)-1:0] highest_irq;
        logic [PRIORITIES-1:0] highest_priority;
        
        found_irq = 1'b0;
        highest_irq = '0;
        highest_priority = '0;
        
        for (int i = 0; i < SOURCES; i++) begin
            if (pending[i] && enables[i] && (priorities[i] > threshold) &&
                (!found_irq || priorities[i] > highest_priority)) begin
                found_irq = 1'b1;
                highest_irq = i;
                highest_priority = priorities[i];
            end
        end
        
        claimed_irq = highest_irq;
        irq_o = found_irq;
    end

    assign irq_pending_o = pending;
    
    // Response valid signal
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            rvalid_o <= 1'b0;
        end else begin
            rvalid_o <= req_i;
        end
    end

    assign rdata_o = reg_rdata;

endmodule
