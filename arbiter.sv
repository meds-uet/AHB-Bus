module ahb_arbiter (
    input  logic         HCLK,
    input  logic         HRESETn,
    input  logic [3:0]   HREQ,       // Master requests
    input  logic         HREADY,     // Global HREADY
    input  logic [1:0]   HTRANS,     // Transaction type
    input  logic [2:0]   HBURST,     // Burst type

    output logic [3:0]   HGRANT,     // Grant signal to masters
    output logic [1:0]   HMASTER     // Index of active master
);

    localparam IDLE   = 2'b00;
    localparam NONSEQ = 2'b10;
    localparam SEQ    = 2'b11;

    // === Internal State ===
    logic [1:0] current_master;
    logic [1:0] next_master;
    logic [1:0] granted_master;

    logic [4:0] burst_counter;
    logic       in_burst;
    logic       is_incr;
    logic       valid_transfer;

    // === Burst length decoding ===
    function automatic logic [4:0] burst_length(input logic [2:0] hburst);
        case (hburst)
            3'b000: return 5'd1;    // SINGLE
            3'b010, 3'b011: return 5'd4;    // WRAP4 / INCR4
            3'b100, 3'b101: return 5'd8;    // WRAP8 / INCR8
            3'b110, 3'b111: return 5'd16;   // WRAP16 / INCR16
            default: return 5'd0;           // INCR or undefined
        endcase
    endfunction

    // === Round-robin master selection ===
    function automatic logic [1:0] get_next_master(input logic [3:0] req, input logic [1:0] last);
        for (int i = 1; i <= 4; i++) begin
            int idx = (last + i) % 4;
            if (req[idx])
                return idx[1:0];
        end
        return last;
    endfunction

    // === Handover condition ===
    logic ready_for_handover;

    always_comb begin
        ready_for_handover = (!in_burst) || 
                             (!is_incr && burst_counter == 0 && HREADY) ||
                             (is_incr && !HREQ[current_master] && HREADY);
    end

    // === Grant decision ===
    always_comb begin
        next_master     = get_next_master(HREQ, current_master);
        granted_master  = ready_for_handover ? next_master : current_master;

        HGRANT = 4'b0000;
        HGRANT[granted_master] = 1;
    end

    // === FSM and burst tracking ===
    always_ff @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            current_master <= 2'd0;
            burst_counter  <= 0;
            in_burst       <= 0;
            is_incr        <= 0;
        end else begin
            current_master <= granted_master;

            valid_transfer = HREADY && (HTRANS == NONSEQ || HTRANS == SEQ);

            // Start of burst
            if (!in_burst && valid_transfer && HREQ[current_master]) begin
                in_burst      <= 1;
                is_incr       <= (HBURST == 3'b001); // INCR
                burst_counter <= (HBURST == 3'b001) ? 0 : burst_length(HBURST) - 1;
            end
            // During burst
            else if (in_burst && valid_transfer) begin
                if (!is_incr && burst_counter != 0)
                    burst_counter <= burst_counter - 1;

                if ((!is_incr && burst_counter == 0) ||
                    (is_incr && !HREQ[current_master])) begin
                    in_burst <= 0;
                end
            end
        end
    end

    // === Output active master ===
    assign HMASTER = current_master;

endmodule
