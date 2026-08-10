// Corrected Virtual PLIC interface for Verilator simulation
module plicdpi #(
    parameter int SOURCES    = 32,
    parameter int TARGETS    = 1,
    parameter int PRIORITIES = 3
)(
    input  logic        clk_i,
    input  logic        rst_ni,

    // Bus interface signals (matching the RTL plic register map)
    input  logic        req_i,
    input  logic [31:0] addr_i,
    input  logic        we_i,
    input  logic [3:0]  be_i,
    input  logic [31:0] wdata_i,
    output logic        rvalid_o,
    output logic [31:0] rdata_o,

    // Interrupt interface
    input  logic [SOURCES-1:0] irq_sources_i,
    output logic [SOURCES-1:0] irq_pending_o,
    output logic [TARGETS-1:0] irq_o
);

    // Register map constants (same as in plic.sv)
    localparam int PRIORITY_BASE  = 'h000000;
    localparam int PENDING_BASE   = 'h001000;
    localparam int ENABLE_BASE    = 'h002000;
    localparam int THRESHOLD_BASE = 'h200000;
    localparam int CLAIM_COMPLETE = 'h200004;

    // Internal registers
    logic [PRIORITIES-1:0] priorities [SOURCES];
    logic [SOURCES-1:0]    enables;
    logic [PRIORITIES-1:0] threshold;
    logic [SOURCES-1:0]    pending;
    logic [$clog2(SOURCES)-1:0] claimed_irq;

    // Register interface read data
    logic [31:0] reg_rdata;

    // ------------------------------
    // Write Handling
    // ------------------------------
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        for (int i = 0; i < SOURCES; i++) begin
          priorities[i] <= '0;
        end
        enables    <= '0;
        threshold  <= '0;
      end else if (req_i && we_i) begin
        case (addr_i[15:12])
          5'h0: begin // Priority registers
            if (addr_i[11:2] < SOURCES)
              priorities[addr_i[11:2]] <= wdata_i[PRIORITIES-1:0];
          end
          5'h2: begin // Enable registers
            if (addr_i[11:2] == 0)
              enables <= wdata_i[SOURCES-1:0];
          end
          5'h20: begin // Threshold and claim/complete region
            if (addr_i[3:2] == 0)
              threshold <= wdata_i[PRIORITIES-1:0];
            else if (addr_i[3:2] == 1) begin
              // Handle interrupt completion: clear pending bit for the given IRQ index
              if (wdata_i < SOURCES)
                pending[wdata_i] <= 1'b0;
            end
          end
          default: ;
        endcase
      end
    end

    // ------------------------------
    // Read Handling
    // ------------------------------
    always_comb begin
      reg_rdata = '0;
      case (addr_i[15:12])
        5'h0: begin // Priority registers
          if (addr_i[11:2] < SOURCES)
            reg_rdata = {{(32-PRIORITIES){1'b0}}, priorities[addr_i[11:2]]};
        end
        5'h1: begin // Pending registers
          if (addr_i[11:2] == 0)
            reg_rdata = pending;
        end
        5'h2: begin // Enable registers
          if (addr_i[11:2] == 0)
            reg_rdata = enables;
        end
        5'h20: begin // Threshold and claim/complete region
          if (addr_i[3:2] == 0)
            reg_rdata = {{(32-PRIORITIES){1'b0}}, threshold};
          else if (addr_i[3:2] == 1)
            reg_rdata = claimed_irq;
        end
        default: reg_rdata = '0;
      endcase
    end

    // ------------------------------
    // Interrupt Pending Update
    // ------------------------------
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni)
        pending <= '0;
      else begin
        for (int i = 0; i < SOURCES; i++) begin
          if (irq_sources_i[i] && enables[i])
            pending[i] <= 1'b1;
        end
      end
    end

    // ------------------------------
    // Highest-Priority Pending Interrupt Logic
    // ------------------------------
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
    
    // ------------------------------
    // Response Valid Signal
    // ------------------------------
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni)
        rvalid_o <= 1'b0;
      else
        rvalid_o <= req_i;
    end

    assign rdata_o = reg_rdata;

endmodule
