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
// Date:   29-July-2025




module slave_to_master_mux #(

    parameter integer NUM_SLAVES = 4,
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32

) (
    input  logic                        Hclk,
    input  logic                        Hresetn,
    input  logic [NUM_SLAVES-1:0]       slave_select,         // One-hot signal from decoder
    input  logic [DATA_WIDTH-1:0]       Hrdata_S [NUM_SLAVES],         // From slaves
    input  logic [1:0]                  Hresp_S  [NUM_SLAVES],
    input  logic                        Hreadyout_S [NUM_SLAVES],

    output logic [DATA_WIDTH-1:0]       Hrdata,
    output logic [1:0]                  Hresp,
    output logic                        Hready                // Global Hready for master
);

    // Register selected slave (for pipelined response)
    logic [NUM_SLAVES-1:0] selected_slave;

    always_ff @(posedge Hclk or negedge Hresetn) begin
        if (!Hresetn)
            selected_slave <= 4'b0000;
        else if (Hready) // Only update on valid transfer complete
            selected_slave <= slave_select;
    end

    // Output MUX
    always_comb begin
        case (1'b1)
            selected_slave[0]: begin
                Hrdata = Hrdata_S[0];
                Hresp  = Hresp_S[0];
                Hready = Hreadyout_S[0];
            end
            selected_slave[1]: begin
                Hrdata = Hrdata_S[1];
                Hresp  = Hresp_S[1];
                Hready = Hreadyout_S[1];
            end
            selected_slave[2]: begin
                Hrdata = Hrdata_S[2];
                Hresp  = Hresp_S[2];
                Hready = Hreadyout_S[2];
            end
            selected_slave[3]: begin
                Hrdata = Hrdata_S[3];
                Hresp  = Hresp_S[3];
                Hready = Hreadyout_S[3];
            end
            default: begin
                Hrdata = 32'hDEADBEEF;
                Hresp  = 2'b00;
                Hready = 1'b1; // default: no wait
            end
        endcase
    end

endmodule