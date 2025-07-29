// Copyright 2025 Maktab-e-Digital Systems Lahore.
// Licensed under the Apache License, Version 2.0, see LICENSE file for details.
// SPDX-License-Identifier: Apache-2.0
//
// Description: 
// This module is a decoder for AHB bus.
// That uses the address to determine which slave is selected.
// This outputs the assert signal to the selected slave.
//
// Author: Muhammad Yousaf and Ali Tahir
// Date:   29-July-2025



module decoder #(
    parameter NUM_SLAVES = 4,
    parameter ADDR_WIDTH = 32,

    parameter logic [ADDR_WIDTH-1:0] BASE_ADDR [0:NUM_SUBORD-1] = '{
        32'h0000_0000,
        32'hEEEE_0000,
        32'hFFFF_0000
    },

    parameter logic [ADDR_WIDTH-1:0] HIGH_ADDR [0:NUM_SUBORD-1] = '{
        32'hEEEE_0000,
        32'hFFFF_0000,
        32'hFFFF_FFFF
    }

) (
    input logic [ADDR_WIDTH-1:0] Haddr,

    output logic [NUM_SUBORD-1:0] Hsel
);

logic over;

always_comb begin

    Hsel = 'b0;
    over = 'b0;
    for (int i = 0; i < NUM_SUBORD; i++) begin
            if ((Haddr >= BASE_ADDR[i]) && (Haddr < HIGH_ADDR[i]) && (Hready == 1'b1) && !over) begin
                Hsel[i] = 1'b1;
                over = 1'b1;
            end
    end

end

endmodule