// Copyright 2025 Maktab-e-Digital Systems Lahore.
// Licensed under the Apache License, Version 2.0, see LICENSE file for details.
// SPDX-License-Identifier: Apache-2.0
//
// Description: 
// This module tests the Arbiter of the AHB bus.
//
//
// Author: Muhammad Yousaf and Ali Tahir
// Date:   07-August-2025

`timescale 1ns/1ps

`include "../defines/parameters.svh"

module ahb_arbiter_tb;

    // Clock and reset
    logic Hclk;
    logic Hresetn;

    // Inputs to DUT
    logic [`NUM_MASTERS-1:0] Hreq;
    logic       Hready;
    logic [1:0] Htrans;
    logic [2:0] Hburst;

    // Outputs from DUT
    logic [`NUM_MASTERS-1:0] Hgrant;
    logic [$clog2(`NUM_MASTERS)-1:0] Hmaster;

    // Instantiate DUT
    ahb_arbiter dut (
        .Hclk(Hclk),
        .Hresetn(Hresetn),
        .Hreq(Hreq),
        .Hready(Hready),
        .Htrans(Htrans),
        .Hburst(Hburst),
        .Hgrant(Hgrant),
        .Hmaster(Hmaster)
    );

    // Clock generation
    initial Hclk = 0;
    always #5 Hclk = ~Hclk; // 100MHz


    task single_transfer(input logic [`NUM_MASTERS-1:0] req, input int mas);
        @(posedge Hclk);
        Hreq = req;

        @(posedge Hclk);
        Htrans = 2'b10;
        Hburst = 3'b000;

        repeat (1) @(posedge Hclk);
        
    endtask

    task burst_transfer(input logic [`NUM_MASTERS-1:0] req, input int mas);
        @(posedge Hclk);
        Hreq = req;

        @(posedge Hclk);
        Htrans = 2'b10;
        Hburst = 3'b011;

        @(posedge Hclk);
        Htrans = 2'b11;

        repeat (3) @(posedge Hclk);
        
    endtask

    // Simulation logic
    initial begin
        $dumpfile("sim.vcd");
        $dumpvars(0, ahb_arbiter_tb);

        // Initialize
        Hresetn = 0;
        Hreq    = 0;
        Hready  = 1;
        Htrans  = 2'b00;
        Hburst  = 3'b000;

        // Apply reset
        repeat (3) @(posedge Hclk);
        Hresetn = 1;
        
        // Test: 1 for the first Master single transfer
        single_transfer(4'b0001, 0);

        // Test: 2 for the second Master single transfer
        single_transfer(4'b0010, 1);

        // Test: 3 for the third Master single transfer
        single_transfer(4'b0100, 2);

        // Test: 4 for the fourth Master single transfer
        single_transfer(4'b1000, 3);

        repeat (3) @(posedge Hclk);

        // Test: 1 for the first Master Burst transfer
        burst_transfer(4'b0001, 0);

        // Test: 2 for the second Master Burst transfer
        burst_transfer(4'b0010, 1);

        // Test: 3 for the third Master Burst transfer
        burst_transfer(4'b0100, 2);

        // Test: 4 for the fourth Master Burst transfer
        burst_transfer(4'b1000, 3);

        repeat (3) @(posedge Hclk);

        $stop;
    end

endmodule