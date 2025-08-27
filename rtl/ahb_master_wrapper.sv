// Copyright 2025 Maktab-e-Digital Systems Lahore.
// Licensed under the Apache License, Version 2.0, see LICENSE file for details.
// SPDX-License-Identifier: Apache-2.0
//
// Description: 
// This module is master wrapper for AHB bus.
// That maps the signals from master to the AHB bus.
//
// Author: Muhammad Yousaf and Ali Tahir
// Date:   27-August-2025


`include "../defines/parameters.svh"

module ahb_master_wrapper (
    input logic Hclk,
    input logic Hresetn,


    // Functional Module Interface

    input logic [`ADDR_WIDTH-1:0] Paddr,
    input logic [`DATA_WIDTH-1:0] PWdata,
    input logic Pload,
    input logic Pstore,
    input logic [2:0] Psize,
    input logic [2:0] Pburst,
    input logic [1:0] Ptrans,

    output logic Pready,
    output logic [`DATA_WIDTH-1:0] PRdata,
    output logic [1:0] Presp,


    // AHB master interface
    output logic [`ADDR_WIDTH-1:0] Haddr,
    output logic [1:0]  Htrans,
    output logic        Hwrite,
    output logic [2:0]  Hsize,
    output logic [2:0]  Hburst,
    output logic [`DATA_WIDTH-1:0] HWdata,
    input logic  [`DATA_WIDTH-1:0] HRdata,
    input logic         Hready,
    input logic  [1:0]  Hresp,

    // Arbiter interface
    output logic   Hreq,
    input logic    Hgrant
);

typedef enum logic { 
    IDLE,
    PROCESS
} state;

state C_state, N_state;

logic [`DATA_WIDTH-1:0] latched_data;
logic latched_write;


always_ff @(posedge Hclk or negedge Hresetn) begin
    if (!Hresetn) begin
        C_state = IDLE;
    end else begin
        C_state <= N_state;
        if (Hready) begin
            if (Pstore) begin
                latched_data <= PWdata;
                latched_write <= 1'b1;
            end else begin
                latched_write <= 1'b0;
            end
        end
    end
end

always_comb begin

    Hreq = Pload || Pstore;
    Haddr = 32'h0;
    Hburst = 3'b000;
    Hsize = 3'b000;
    Htrans = 2'b00;
    Hwrite = 1'b0;
    N_state = C_state;

    case (C_state)
        IDLE: begin
            if ((Hgrant == 1'b1) && (Hready == 1'b1)) begin
                Haddr = Paddr;
                Hburst = Pburst;
                Hsize = Psize;
                Htrans = Ptrans;
                Hwrite = Pstore;
                N_state = PROCESS;
            end
        end
        PROCESS: begin
            if (Hready) begin
                Pready = Hready;
                Presp = Hresp;
                if (latched_write) begin
                    HWdata = latched_data;
                end else begin
                    PRdata = HRdata;
                end
                if (Hgrant == 1'b1) begin
                    if (Pburst == 3'b000) begin
                        Haddr = Paddr;
                        Hburst = Pburst;
                        Hsize = Psize;
                        Htrans = Ptrans;
                        Hwrite = Pstore;
                        N_state = PROCESS;
                    end else begin
                        Haddr = Paddr + 1 << Psize;
                        Hburst = Pburst;
                        Hsize = Psize;
                        Htrans = Ptrans;
                        Hwrite = Pstore;
                        N_state = PROCESS;
                    end
                end
                else begin
                    N_state = IDLE;
                end
            end
        end
    endcase
end

endmodule