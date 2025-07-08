`ifndef HEADER.svh
`define HEADER.svh

module arbiter (

    // Global Signals
    input logic Hclk,
    input logic Hresetn,

    // Master Request Signals
    input logic Hreq_0,
    input logic Hreq_1,
    input logic Hreq_2,

    // Master Control Signals
    input logic [1:0] Htrans,
    input logic [2:0] Hburst,

    // Slave Response Signals
    input logic Hready,
    input logic [1:0] Hresp,

    // Master Response Signals
    output logic [0:MASTER_NUM-1] Hgrant

);

// Internal signals

logic [0:MASTER_NUM-1] Hreq;
assign Hreq = {Hreq_0, Hreq_1, Hreq_2}; // Concatenate master requests

logic grantset;
logic grantreqset;
logic brst;
logic grst;
logic bstop;
logic [3:0] beat;

// Counter for each master to track the number of grants
// This will be used to implement a round-robin with priority-based arbitration

logic [2:0] counter [MASTER_NUM];
logic [0:MASTER_NUM] enable;

always_ff @(posedge Hclk or negedge Hresetn or posedge grst) begin
    if (!Hresetn || grst) begin
        for (int i = 0; i < MASTER_NUM; i++) begin
            counter[i] <= 3'b000; // Reset counters for each master
        end
    end else begin
        for (int j = 0; j < MASTER_NUM; j++) begin
            if (enable[j]) begin
                counter[j] <= counter[j] + 1; // Increment counter for the granted master
            end
        end
    end
end


// Burst Counter to keep track of the burst length
logic [3:0] burst_counter;

always_ff @(posedge Hclk or negedge Hresetn or posedge brst) begin
    if (!Hresetn || brst) begin
        burst_counter <= 4'b0000; // Reset burst counter
    end else begin
        if ((Htrans == 2'b11 && Hready)) begin
            burst_counter <= burst_counter + 1; // Increment burst counter
        end
    end
end

// States are handled in a finite state machine (FSM)
// Define the states for the FSM

typedef enum logic [1:0] {
    IDLE,
    GRANT,
    BURST,
    PRIORITY
} state_t;

state_t C_state, N_state;

always_ff @(posedge Hclk or negedge Hresetn) begin

    if (!Hresetn) begin
        C_state <= IDLE;
        Hgrant <= '0; // Reset grants
    end else begin
        C_state <= N_state;
    end

end

always_comb begin

    // Default values for combinational logic

    N_state = C_state; // Default next state is current state
    enable = '0; // Default: no enables
    grantset = 1'b0; // Reset grant set flag
    grantreqset = 1'b0; // Reset grant request set flag
    bstop = burst_counter == beat; // Check if burst is stopped
    beat = 4'b0000; // Default beat value
    brst = 1'b0; // Reset burst flag
    grst = 1'b0; // Reset counter flag

    case (C_state)

        IDLE: begin
                for (int i=0; i< MASTER_NUM; i++) begin
                    if (Hreq[i]) begin
                        N_state = PRIORITY;
                        break; // Exit the loop
                    end
                end
            end

        PRIORITY: begin
            // Priority arbitration for multiple masters
            for (int i = 0; i < MASTER_NUM; i++) begin
                if (Hreq[i]) begin
                    if (counter[i] < 6) begin
                        Hgrant[i] = 1'b1;
                        enable[i] = 1'b1;
                        grantset = 1'b1; // Set grant for some master
                        break; // Grant to the highest priority requesting master
                    end
                end
            end

            if (!grantset) begin
                for (int i = 0; i < MASTER_NUM; i++) begin
                    if (Hreq[i]) begin
                        Hgrant[i] = 1'b1; // Grant to the first requesting master
                        enable[i] = 1'b1;
                        break; // Exit the loop after granting
                    end
                end
            end

            N_state = GRANT;
        end

        GRANT: begin

            for (int i=0; i< MASTER_NUM; ++i) begin
                    if (Hreq[i]) begin
                        grantreqset = 1'b1; // Set grant request flag
                        break; // Exit the loop
                    end
            end

            // Handle the granted state
            for (int i = 0; i < MASTER_NUM; i++) begin
                if (Hgrant[i]) begin
                    if (Htrans == 2'b10 && Hburst == 3'b000) begin // Non-sequential and single
                        N_state = GRANT;
                        enable[i] = 1'b1;
                    end else if (Htrans == 2'b10 && Hburst != 3'b000) begin // Non-sequential and not single
                        N_state = BURST;
                        brst = 1'b1;
                        enable[i] = 1'b1;
                        if ((Hburst == 3'b010) || (Hburst == 3'b011)) begin
                            beat = 4'b0011; // count 3 beats
                        end else if ((Hburst == 3'b100) || (Hburst == 3'b101)) begin
                            beat = 4'b0111; // count 7 beats
                        end else if ((Hburst == 3'b110) || (Hburst == 3'b111)) begin
                            beat = 4'b1111; // count 15 beats
                        end
                    end else if (Htrans == 2'b00 && !grantreqset) begin  // Htrans is idle and no grant request
                        N_state = IDLE;
                        Hgrant = '0;
                        enable = '0;
                    end else if (Htrans == 2'b00 && grantreqset) begin  // Htrans is idle and any grant request
                        N_state = PRIORITY;
                        Hgrant = '0;
                        enable = '0;
                    end else if (Htrans == 2'b01) begin // Htrans is busy
                        N_state = GRANT;
                        enable = '0;
                    end
                    break; // Exit the loop after setting the next state
                end
            end
        end

        BURST: begin

            for (int i=0; i< MASTER_NUM; ++i) begin
                    if (Hreq[i]) begin
                        grantreqset = 1'b1; // Set grant request flag
                        break; // Exit the loop
                    end
            end

            // Handle burst state
            for (int i = 0; i < MASTER_NUM; i++) begin
                if (Hgrant[i]) begin
                    if (Hready) begin
                        if ((bstop || Htrans == 2'b00) && (!grantreqset)) begin
                            N_state = IDLE; // Go back to idle after burst completion
                            Hgrant = '0;
                            enable = '0;
                            brst = 1'b0;
                        end else if ((bstop || Htrans == 2'b00) && (grantreqset)) begin
                            N_state = PRIORITY; // Go back to priority after burst completion if any grant request
                            Hgrant = '0;
                            enable = '0;
                            brst = 1'b0;
                        end else begin
                            N_state = BURST; // Continue in burst state
                        end
                    end else begin
                        N_state = BURST; // Stay in burst state if not ready
                    end
                    break; // Exit the loop after setting the next state
                end
            end

        end

    endcase
end

endmodule

`endif