// Copyright 2025 Maktab-e-Digital Systems Lahore.
// Licensed under the Apache License, Version 2.0, see LICENSE file for details.
// SPDX-License-Identifier: Apache-2.0
//
// Description: 
// 
// This module tests the master wrapper for the AHB bus.
//
//
// Author: Muhammad Yousaf and Ali Tahir
// Date:   27-August-2025

`timescale 1ns/1ps
`include "../defines/parameters.svh"

module ahb_master_wrapper_tb;

    logic    Hclk;
    logic    Hresetn;

    // Functional Module Interface
    logic [`ADDR_WIDTH-1:0] Paddr;
    logic [`DATA_WIDTH-1:0] PWdata;
    logic                   Pload;
    logic                   Pstore;
    logic [2:0]             Psize;
    logic [2:0]             Pburst;
    logic [1:0]             Ptrans;

    logic                   Pready;
    logic [`DATA_WIDTH-1:0] PRdata;
    logic [1:0]             Presp;


    // AHB master interface
    logic [`ADDR_WIDTH-1:0] Haddr;
    logic [1:0]             Htrans;
    logic                   Hwrite;
    logic [2:0]             Hsize;
    logic [2:0]             Hburst;
    logic [`DATA_WIDTH-1:0] HWdata;
    logic [`DATA_WIDTH-1:0] HRdata;
    logic                   Hready;
    logic [1:0]             Hresp;

    // Arbiter interface
    logic                   Hreq;
    logic                   Hgrant;


    ahb_master_wrapper dut (
        .*
    );

    always #5 Hclk = ~Hclk;

    initial begin

        Hclk = 0;
        Hresetn = 0;

        #10 Hresetn = 1;

        @(posedge Hclk);
        Hgrant = 1;
        Hready = 1;

        for (int i; i < 5; i++) begin
            @(posedge Hclk);
            Paddr = 32'h1000_0000 + i;
            Pload = 0;
            Pstore = 1;
            Psize = 3'b010;
            Pburst = 3'b000;
            Ptrans = 2'b01;
            PWdata = 32'hDEADBEEF + i;
        end

        repeat (2) @(posedge Hclk);

        for (int i; i < 5; i++) begin
            @(posedge Hclk);
            Paddr = 32'h2000_0000 + i;
            Pload = 1;
            Pstore = 0;
            Psize = 3'b010;
            Pburst = 3'b000;
            Ptrans = 2'b01;
            @(posedge Hclk);
            HRdata = 32'hBEEFDEAF + i;
            Hresp = 2'b01;
        end

        repeat (2) @(posedge Hclk);

        @(posedge Hclk);
        Paddr = 32'h3000_0000;
        Pload = 0;
        Pstore = 1;
        Psize = 3'b010;
        Pburst = 3'b000;
        Ptrans = 2'b01;
        PWdata = 32'hDEEDBEEF;

        @(posedge Hclk);
        Paddr = 32'h3000_0004;
        Pload = 1;
        Pstore = 0;
        Psize = 3'b010;
        Pburst = 3'b000;
        Ptrans = 2'b01;
        @(posedge Hclk);
        HRdata = 32'hDEEFDEAF;
        Hresp = 2'b01;

        repeat (2) @(posedge Hclk);

        $stop;

    end

endmodule