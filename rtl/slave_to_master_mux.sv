// Copyright 2025 Maktab-e-Digital Systems Lahore.
// Licensed under the Apache License, Version 2.0, see LICENSE file for details.
// SPDX-License-Identifier: Apache-2.0
//
// Description: 
// 
// This module is the slave to master multiplexer for AHB bus.
// That uses the slected slave signal form the Decoder module.
// To derive the DATA and RESPONSE SIGNAL on the bus.
//
// Author: Muhammad Yousaf and Ali Tahir
// Date:   07-August-2025

`include "../defines/parameters.svh"

module slave_to_master_mux (

    input  logic                                Hclk,
    input  logic                                Hresetn,
    input  logic [`NUM_SLAVES-1:0]              slave_select,         // One-hot signal from decoder
    input  logic [$clog2(`NUM_MASTERS)-1:0]     Hmaster,            // Selected master index
    input  logic [`DATA_WIDTH-1:0]              Hrdata_S [`NUM_SLAVES],         // From slaves
    input  logic [1:0]                          Hresp_S  [`NUM_SLAVES],
    input  logic                                Hreadyout_S [`NUM_SLAVES],
    
    output logic [`DATA_WIDTH-1:0]              Hrdata [`NUM_MASTERS],
    output logic [1:0]                          Hresp [`NUM_MASTERS],
    output logic                                Hready                // Global Hready for master
);

    // Register selected slave (for pipelined response)
    logic [`NUM_SLAVES-1:0] selected_slave;
    logic [`NUM_MASTERS-1:0] selected_master;

    always_ff @(posedge Hclk or negedge Hresetn) begin
        if (!Hresetn)
            selected_slave <= 4'b0000;
        else if (Hready) // Only update on valid transfer complete
            selected_slave <= slave_select;
            selected_master <= Hmaster;
    end

    // Output MUX
    always_comb begin
        case (1'b1)
        for (int i = 0; i < `NUM_SLAVES; i++) begin
            selected_slave[i]: begin
                Hrdata[selected_master] = Hrdata_S[i];
                Hresp[selected_master]  = Hresp_S[i];
                Hready[selected_master] = Hreadyout_S[i];
            end
        end
            default: begin
                Hrdata[selected_master] = 32'hDEADBEEF;
                Hresp[selected_master]  = 2'b00;
                Hready[selected_master] = 1'b1; // default: no wait
            end
        endcase
    end

endmodule