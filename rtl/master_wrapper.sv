module ahb_master_wrapper (
    input         HCLK,
    input         HRESETn,

    // AHB master interface
    output reg [31:0] HADDR,
    output reg [1:0]  HTRANS,
    output reg        HWRITE,
    output reg [2:0]  HSIZE,
    output reg [2:0]  HBURST,
    output reg [31:0] HWDATA,
    input      [31:0] HRDATA,
    input             HREADY,
    input      [1:0]  HRESP,

    // Arbiter interface
    output reg HBUSREQ,
    input      HGRANT
);

    // ----------------------------------------
    // Internal Interface from Functional Module
    // ----------------------------------------
    wire        cmd_valid;
    wire [31:0] cmd_addr;
    wire [31:0] cmd_data;
    wire        cmd_write;
    wire [2:0]  cmd_size;
    wire [2:0]  cmd_burst_len;
    wire        cmd_ready;

    // Feedback to functional module
    reg  [31:0] read_data;
    reg  [1:0]  resp;

    // ----------------------------------------
    // Internal Functional Logic Instantiation
    // ----------------------------------------
    my_functional_controller u_func (
        .clk        (HCLK),
        .resetn     (HRESETn),
        .cmd_ready  (cmd_ready),
        .cmd_valid  (cmd_valid),
        .cmd_addr   (cmd_addr),
        .cmd_data   (cmd_data),
        .cmd_write  (cmd_write),
        .cmd_size   (cmd_size),
        .cmd_burst_len (cmd_burst_len),
        .read_data  (read_data),
        .resp       (resp)
    );

    // ----------------------------------------
    // Command FIFO
    // ----------------------------------------
    localparam FIFO_DEPTH = 4;
    typedef struct packed {
        logic [31:0] addr;
        logic [31:0] data;
        logic        write;
        logic [2:0]  size;
        logic [2:0]  burst_len;
    } cmd_t;

    cmd_t cmd_fifo [0:FIFO_DEPTH-1];
    logic [1:0] fifo_rd_ptr, fifo_wr_ptr;
    logic [2:0] fifo_count;

    assign cmd_ready = (fifo_count < FIFO_DEPTH);

    always_ff @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            fifo_rd_ptr <= 0;
            fifo_wr_ptr <= 0;
            fifo_count  <= 0;
        end else begin
            if (cmd_valid && cmd_ready) begin
                cmd_fifo[fifo_wr_ptr] <= '{cmd_addr, cmd_data, cmd_write, cmd_size, cmd_burst_len};
                fifo_wr_ptr <= fifo_wr_ptr + 1;
                fifo_count <= fifo_count + 1;
            end

            if (state == RESPOND && HREADY && beat_count == 0) begin
                fifo_rd_ptr <= fifo_rd_ptr + 1;
                fifo_count <= fifo_count - 1;
            end
        end
    end

    // ----------------------------------------
    // FSM
    // ----------------------------------------
    typedef enum logic [1:0] {
        IDLE, REQUEST, SETUP, RESPOND
    } state_t;
    state_t state, next_state;

    reg [4:0] beat_count;
    reg [4:0] total_beats;

    wire fifo_not_empty = (fifo_count != 0);
    wire last_beat = (beat_count == 0);

    cmd_t current_cmd;
    always_comb current_cmd = cmd_fifo[fifo_rd_ptr];

    always_ff @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn)
            state <= IDLE;
        else
            state <= next_state;
    end

    always_comb begin
        next_state = state;
        case (state)
            IDLE:    next_state = fifo_not_empty ? REQUEST : IDLE;
            REQUEST: next_state = HGRANT ? SETUP : REQUEST;
            SETUP:   next_state = HREADY ? RESPOND : SETUP;
            RESPOND: next_state = (HREADY && last_beat) ? IDLE : RESPOND;
        endcase
    end

    // ----------------------------------------
    // Beat Count and Burst Size Lookup
    // ----------------------------------------
    reg [4:0] beats_for_burst;
    always_comb begin
        case (current_cmd.burst_len)
            3'b000: beats_for_burst = 1;   // SINGLE
            3'b001: beats_for_burst = 4;   // INCR4
            3'b010: beats_for_burst = 8;   // INCR8
            3'b011: beats_for_burst = 16;  // INCR16
            3'b100: beats_for_burst = 4;   // WRAP4
            3'b101: beats_for_burst = 8;   // WRAP8
            3'b110: beats_for_burst = 16;  // WRAP16
            default: beats_for_burst = 1;
        endcase
    end

    always_ff @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            beat_count  <= 0;
            total_beats <= 0;
        end else if (state == SETUP && HREADY) begin
            total_beats <= beats_for_burst;
            beat_count  <= beats_for_burst - 1;
        end else if (state == RESPOND && HREADY && beat_count != 0) begin
            beat_count <= beat_count - 1;
        end
    end

    // ----------------------------------------
    // Output Signals
    // ----------------------------------------
    always_ff @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            HBUSREQ <= 0;
            HTRANS  <= 2'b00;
        end else begin
            case (state)
                REQUEST: begin
                    HBUSREQ <= 1;
                end
                SETUP: begin
                    if (HREADY) begin
                        HADDR  <= current_cmd.addr;
                        HWRITE <= current_cmd.write;
                        HSIZE  <= current_cmd.size;
                        HBURST <= current_cmd.burst_len;
                        HTRANS <= 2'b10; // NONSEQ
                        if (current_cmd.write)
                            HWDATA <= current_cmd.data;
                    end
                end
                RESPOND: begin
                    if (HREADY) begin
                        HADDR  <= HADDR + (1 << current_cmd.size);
                        HTRANS <= 2'b11; // SEQ
                        if (current_cmd.write)
                            HWDATA <= current_cmd.data;
                        else
                            read_data <= HRDATA;

                        resp <= HRESP;

                        if (last_beat)
                            HBUSREQ <= 0;
                    end
                end
                default: HTRANS <= 2'b00;
            endcase
        end
    end

endmodule
