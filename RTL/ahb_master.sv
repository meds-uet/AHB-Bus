`ifndef HEADER.svh
`define HEADER.svh


module ahb_master (

    // Global Signals
    input logic Hclk,
    input logic Hresetn,

    // Processor input signals
    input logic [DATA_WIDTH-1:0] Pwdata,
    input logic [DATA_WIDTH-1:0] Paddr,
    input logic [2:0] Psize,
    input logic [DATA_WIDTH/8-1:0] Pstrb,
    input logic Pload,
    input logic Pstore,
    input logic [2:0] Pburst,
    input logic [1:0] Ptrans,

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
    output logic [DATA_WIDTH/8-1:0] Hstrb,
    output logic Hreq,
    output logic [DATA_WIDTH-1:0] Prdata,

    // Write Bus Data
    output logic [DATA_WIDTH-1:0] HWdata

);

logic addr_put;
logic data_put;

typedef enum logic [1:0] {
    IDLE,
    REQUEST,
    ADDR_PHASE,
    DATA_PHASE
} state_t;

state_t C_state, N_state;

always_ff @(posedge Hclk or negedge Hresetn) begin

    if (!Hresetn) begin
        C_state <= IDLE;
        Htrans <= 2'b00;
        Hreq <= 1'b0;

    end else begin
        C_state <= N_state;

        if (addr_put) begin
            Haddr <= Paddr;
            Hsize <= Psize;
            Hburst <= 3'b000;
            Htrans <= 2'b10;
            Hstrb <= Pstrb;
            HWrite <= Pstore; // Write if store, else read
        end
        if (data_put) begin
            if (Pstore) HWdata <= Pwdata; // Store data to write bus
            if (Pload) Prdata <= HRdata; // Load data from read bus
        end

    end

end

always_comb begin
    // Default values
    N_state = C_state;
    addr_put = 1'b0;
    data_put = 1'b0;
end

always_comb begin

    case (C_state)

        IDLE: begin
            if (Pload || Pstore)  begin
                Hreq = 1'b1; // Assert request to the arbiter
                N_state = REQUEST;
            end
        end

        REQUEST: begin
            Hreq = 1'b1; // Keep assert request after entering REQUEST state
            if (Hgrant) begin
                N_state = ADDR_PHASE;
                Hreq = 1'b0; // Deassert request once granted
            end
        end
        ADDR_PHASE: begin
            if (Hgrant && Hready) begin
                addr_put = 1'b1;
                N_state = DATA_PHASE;
            end else begin
                addr_put = 1'b0;
            end
        end
        DATA_PHASE: begin
            if (Hgrant && Hready) begin
                data_put = 1'b1;
                addr_put = 1'b1;
                N_state = IDLE;
            end
        end

    endcase

end

endmodule

`endif