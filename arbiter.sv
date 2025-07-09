module ahb_arbiter (
    input  logic         HCLK,
    input  logic         HRESETn,
    input  logic [3:0]   HREQ,       // Master requests
    input  logic         HREADY,     // Bus ready
    input  logic [1:0]   HTRANS,     // Transaction type
    input  logic [2:0]   HBURST,     // Burst type

    output logic [3:0]   HGRANT,     // Grant to each master
    output logic [1:0]   HMASTER     // Active master index
);

    localparam IDLE   = 2'b00;
    localparam NONSEQ = 2'b10;
    localparam SEQ    = 2'b11;

    // === Internal State ===
    logic [1:0] current_master;
    logic [1:0] next_master;
    logic [3:0] grant;

    logic [4:0] burst_counter;      // Max 16 beats (fits in 5 bits)
    logic       in_burst;           // Active burst flag
    logic       is_incr;            // INCR burst flag

    // === Burst length decoding ===
    function automatic logic [4:0] burst_length(input logic [2:0] hburst);
        case (hburst)
            3'b000: return 5'd1;   // SINGLE
            3'b010, 3'b011: return 5'd4;   // WRAP4 / INCR4
            3'b100, 3'b101: return 5'd8;   // WRAP8 / INCR8
            3'b110, 3'b111: return 5'd16;  // WRAP16 / INCR16
            default: return 5'd0;          // INCR (3'b001) — unknown length
        endcase
    endfunction

    // === Round-robin next master selection ===
    function automatic logic [1:0] get_next_master(input logic [3:0] req, input logic [1:0] last);
        for (int i = 1; i <= 4; i++) begin
            int idx = (last + i) % 4;
            if (req[idx]) return idx[1:0];
        end
        return last;
    endfunction

    // === Main Arbiter FSM ===
    always_ff @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            current_master  <= 2'd0;
            burst_counter   <= 0;
            in_burst        <= 0;
            is_incr         <= 0;
        end else begin
            // Check for valid transfer
            logic valid_transfer = HREADY && (HTRANS == NONSEQ || HTRANS == SEQ);

            // Start of a burst
            if (!in_burst && valid_transfer && HREQ[current_master]) begin
                in_burst      <= 1;
                is_incr       <= (HBURST == 3'b001); // INCR
                burst_counter <= (HBURST == 3'b001) ? 0 : burst_length(HBURST) - 1;
            end
            // Continue burst
            else if (in_burst && valid_transfer) begin
                // Decrement counter if fixed-length
                if (!is_incr && burst_counter != 0)
                    burst_counter <= burst_counter - 1;

                // Burst done
                if ((!is_incr && burst_counter == 0) ||
                    (is_incr && !HREQ[current_master])) begin
                    in_burst <= 0;
                    current_master <= next_master;
                end
            end
        end
    end

    // === Next Master Pre-Grant ===
    always_comb begin
        // Predict next master while current is active
        next_master = get_next_master(HREQ, current_master);

        // Pre-grant next master 1 beat early (if burst about to end)
        logic pre_grant_condition = 0;
        if (in_burst) begin
            pre_grant_condition = (
                (!is_incr && burst_counter == 1) ||             // Fixed burst
                (is_incr && !HREQ[current_master])              // INCR ends
            );
        end

        grant = 4'b0000;
        if (pre_grant_condition)
            grant[next_master] = 1;
        else
            grant[current_master] = 1;
    end

    // === Outputs ===
    assign HGRANT  = grant;
    assign HMASTER = current_master;

endmodule
