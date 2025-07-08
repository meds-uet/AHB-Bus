`ifndef HEADER.svh
`define HEADER.svh


module ahb_master (

    // Global Signals
    input logic Hclk,
    input logic Hresetn,

    // Processor input signals
    input logic Pdata,
    input logic Paddr,
    input logic Psize,
    input logic Pstrb,
    input logic Pload,
    input logic Pstore,
    input logic Pburst,
    input logic Ptrans,

    // Slave Response
    input logic Hready,
    input logic [1:0] Hresp,
    input logic [DATA_WIDTH-1:0] HRdata,

    // Arbiter Signals
    input logic Hgrant,

    // Address Signals
    output logic [ADDR_WIDTH-1:0] Haddr,

    // Control Signals
    output logic HWrite,
    output logic [2:0] Hburst,
    output logic [2:0] Hsize,
    output logic [1:0] Htrans,
    output logic Hstrb,


    // Write Bus Data
    output logic [DATA_WIDTH-1:0] HWdata

);

typedef enum logic [1:0] {
    IDLE,
    ADDRESS,
    WRITE,
    READ,
} state_t;

state_t C_state, N_state;

always_ff @(posedge Hclk) begin

    if (!Hresetn) begin
        // Reset all outputs
        Haddr <= 0;
        Hburst <= 0;
        Hsize <= 0;
        Htrans <= 0;
        HWrite <= 0;
        HWdata <= 0;
        Hstrb <= 0;

        C_state <= IDLE;

    end else begin
        C_state <= N_state;
    end

end

always_comb begin
    // Default values
    N_state = C_state;
    Haddr = 0;
    Hburst = 0;
    Hsize = 0;
    Htrans = 0;
    HWrite = 0;
    HWdata = 0;
    Hstrb = 0;

    case (C_state)
        IDLE: begin
            if (Pload && Hgrant) begin
                N_state = ADDRESS;
                Haddr = Paddr; // Set address for read
                Htrans = Ptrans; // Non-sequential transfer
                Hburst = Pburst; // Set burst type
            end else if (Pstore && Hgrant) begin
                N_state = ADDRESS;
                Haddr = Paddr; // Set address for write
                Htrans = Ptrans; // Non-sequential transfer
                HWrite = 1; // Indicate write operation
            end
        end

        ADDRESS: begin
            if (Hready) begin
                if (Pload) begin
                    N_state = READ; // Move to read state
                    Hsize = Psize; // Set size for read operation
                end else if (Pstore) begin
                    N_state = WRITE; // Move to write state
                    Hsize = Psize; // Set size for write operation
                    HWdata = Pdata; // Load data to write bus
                    Hstrb = Pstrb; // Set byte enable for write
                end
            end else begin
                N_state = IDLE; // Go back to idle if not ready
            end
        end

        WRITE: begin
            if (Hready) begin
                N_state = IDLE; // Go back to idle after write operation
            end else begin
                N_state = WRITE; // Stay in write state until ready
            end
        end

        READ: begin
            if (Hready) begin
                N_state = IDLE; // Go back to idle after read operation
            end else begin
                N_state = READ; // Stay in read state until ready
            end
        end

        default: N_state = IDLE; // Fallback to idle state

    endcase

end

endmodule

`endif