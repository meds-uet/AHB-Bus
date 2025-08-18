// Copyright 2025 Maktab-e-Digital Systems Lahore.
// Licensed under the Apache License, Version 2.0, see LICENSE file for details.
// SPDX-License-Identifier: Apache-2.0
//
// Description: 
// This module is master wrapper for AHB bus.
// That maps the signals from master to the AHB bus.
//
// Author: Muhammad Yousaf and Ali Tahir
// Date:   18-August-2025


`include "../defines/parameters.svh"

module ahb_master_wrapper (
    input         Hclk,
    input         Hresetn,


    // Functional Module Interface
    input logic cmd_valid,
    input logic [`ADDR_WIDTH-1:0] cmd_addr,
    input logic [`DATA_WIDTH-1:0] cmd_data,
    input logic cmd_write,
    input logic [2:0] cmd_size,
    input logic [2:0] cmd_burst_len,

    output logic cmd_ready,
    output logic [`DATA_WIDTH-1:0] read_data,
    output logic [1:0] resp,


    // AHB master interface
    output logic [`ADDR_WIDTH-1:0] Haddr,
    output logic [1:0]  Htrans,
    output logic        Hwrite,
    output logic [2:0]  Hsize,
    output logic [2:0]  Hburst,
    output logic [`DATA_WIDTH-1:0] HWdata,
    input        [`DATA_WIDTH-1:0] HRdata,
    input               Hready,
    input        [1:0]  Hresp,

    // Arbiter interface
    output logic   Hreq,
    input          Hgrant
);

    
    // ----------------------------------------
    // FSM
    // ----------------------------------------
    typedef enum logic [1:0] {
        IDLE, REQUEST, SETUP, RESPOND
    } state_t;

    state_t state, next_state;

    reg [4:0] beat_count;
    reg [4:0] total_beats;

    // ----------------------------------------
    // Command FIFO
    // ----------------------------------------
    localparam FIFO_DEPTH = 4;
    typedef struct packed {
        logic [`ADDR_WIDTH-1:0] addr;
        logic [`DATA_WIDTH-1:0] data;
        logic        write;
        logic [2:0]  size;
        logic [2:0]  burst_len;
    } cmd_t;

    cmd_t cmd_fifo [0:FIFO_DEPTH-1];
    logic [1:0] fifo_rd_ptr, fifo_wr_ptr;
    logic [2:0] fifo_count;

    assign cmd_ready = (fifo_count < FIFO_DEPTH);

    always_ff @(posedge Hclk or negedge Hresetn) begin
        if (!Hresetn) begin
            fifo_rd_ptr <= 0;
            fifo_wr_ptr <= 0;
            fifo_count  <= 0;
        end else begin
            if (cmd_valid && cmd_ready) begin
                cmd_fifo[fifo_wr_ptr] <= '{cmd_addr, cmd_data, cmd_write, cmd_size, cmd_burst_len};
                fifo_wr_ptr <= fifo_wr_ptr + 1;
                fifo_count <= fifo_count + 1;
            end

            if (state == RESPOND && Hready && beat_count == 0) begin
                fifo_rd_ptr <= fifo_rd_ptr + 1;
                fifo_count <= fifo_count - 1;
            end
        end
    end

    wire  fifo_not_empty = (fifo_count != 0);
    wire last_beat = (beat_count == 0);

    cmd_t current_cmd;
    cmd_t previous_cmd;
    always_comb current_cmd = cmd_fifo[fifo_rd_ptr];

    always_ff @(posedge Hclk or negedge Hresetn) begin
        if (!Hresetn)
            state <= IDLE;
        else
            state <= next_state;
            previous_cmd <= current_cmd;
    end

    always_comb begin
        next_state = state;
        case (state)
            IDLE:    next_state = fifo_not_empty ? REQUEST : IDLE;
            REQUEST: next_state = Hgrant ? SETUP : REQUEST;
            SETUP:   next_state = Hready ? RESPOND : SETUP;
            RESPOND: next_state = (Hready && last_beat) ? IDLE : RESPOND;
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

    always_comb begin
        if (!Hresetn) begin
            beat_count  = 0;
            total_beats = 0;
        end else if ((state == SETUP) && Hready) begin
            total_beats = beats_for_burst;
            beat_count  = beats_for_burst - 1;
        end else if ((state == RESPOND) && Hready && (beat_count != 0)) begin
            beat_count = beat_count - 1;
        end
    end

    // ----------------------------------------
    // Output Signals
    // ----------------------------------------

    always_comb begin
        Hreq = 0;
        Htrans = 0;
        case (state)
                REQUEST: begin
                    Hreq = 1;
                end
                SETUP: begin
                    Hreq = 1;
                    if (Hready) begin
                        Haddr  = current_cmd.addr;
                        Hwrite = current_cmd.write;
                        Hsize  = current_cmd.size;
                        Hburst = current_cmd.burst_len;
                        Htrans = 2'b10; // NONSEQ
                        // if (current_cmd.write)
                        //     HWdata <= current_cmd.data;
                    end
                end
                RESPOND: begin
                    Hreq = 1;
                    if (Hready) begin
                        if (previous_cmd.burst_len != 3'b000) begin
                            Haddr  = Haddr + (1 << current_cmd.size);
                            Htrans = 2'b11; // SEQ
                        end
                        if (previous_cmd.write) begin
                            HWdata = current_cmd.data;
                        end else begin
                            read_data = HRdata;
                        end

                        resp = Hresp;

                        if (last_beat) begin
                            Hreq = 0;
                        end
                    end
                end
                default: Htrans = 2'b00;
            endcase
    end

endmodule