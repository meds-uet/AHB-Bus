// Copyright 2025 Maktab-e-Digital Systems Lahore.
// Licensed under the Apache License, Version 2.0, see LICENSE file for details.
// SPDX-License-Identifier: Apache-2.0
//
// Description: 
// This module tests the decoder for the AHB bus.
//
//
// Author: Muhammad Yousaf and Ali Tahir
// Date:   07-August-2025


`timescale 1ns/1ps

`include "../defines/parameters.svh"

module decoder_tb;

    logic [`ADDR_WIDTH-1:0] Haddr;
    logic [`NUM_SLAVES-1:0] Hsel;

    decoder dut(.Haddr(Haddr), .Hsel(Hsel));

    initial begin
        $display("Time\t\tHaddr\t\t\tHsel");

        // Test address for slave 1
        Haddr = 32'h0000_0001;
        #1;
        $display("%0t\t\t%h\t\t\t%b", $time, Haddr, Hsel);

        // Test address for slave 2
        Haddr = 32'h1000_0001;
        #1;
        $display("%0t\t\t%h\t\t\t%b", $time, Haddr, Hsel);

        // Test address for slave 3
        Haddr = 32'h2000_0001;
        #1;
        $display("%0t\t\t%h\t\t\t%b", $time, Haddr, Hsel);

        // Test address for slave 4
        Haddr = 32'h3000_0001;
        #1;
        $display("%0t\t\t%h\t\t\t%b", $time, Haddr, Hsel);

        // Address not in any range
        Haddr = 32'h4000_0000;
        #1;
        $display("%0t\t\t%h\t\t\t%b", $time, Haddr, Hsel);

        $stop;
    end

endmodule
