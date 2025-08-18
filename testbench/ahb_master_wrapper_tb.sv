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
// Date:   18-August-2025

`timescale 1ns/1ps
`include "../defines/parameters.svh"

module ahb_master_wrapper_tb;

  // Clock & Reset
  logic Hclk;
  logic Hresetn;

  // Functional Module Interface
  logic cmd_valid;
  logic [`ADDR_WIDTH-1:0] cmd_addr;
  logic [`DATA_WIDTH-1:0] cmd_data;
  logic cmd_write;
  logic [2:0] cmd_size;
  logic [2:0] cmd_burst_len;

  logic cmd_ready;
  logic [`DATA_WIDTH-1:0] read_data;
  logic [1:0] resp;

  // AHB master interface
  logic [`ADDR_WIDTH-1:0] Haddr;
  logic [1:0]  Htrans;
  logic        Hwrite;
  logic [2:0]  Hsize;
  logic [2:0]  Hburst;
  logic [`DATA_WIDTH-1:0] HWdata;
  logic [`DATA_WIDTH-1:0] HRdata;
  logic        Hready;
  logic [1:0]  Hresp;

  // Arbiter interface
  logic Hreq;
  logic Hgrant;

  // DUT
  ahb_master_wrapper dut (
    .Hclk(Hclk),
    .Hresetn(Hresetn),

    // Functional interface
    .cmd_valid(cmd_valid),
    .cmd_addr(cmd_addr),
    .cmd_data(cmd_data),
    .cmd_write(cmd_write),
    .cmd_size(cmd_size),
    .cmd_burst_len(cmd_burst_len),

    .cmd_ready(cmd_ready),
    .read_data(read_data),
    .resp(resp),

    // AHB interface
    .Haddr(Haddr),
    .Htrans(Htrans),
    .Hwrite(Hwrite),
    .Hsize(Hsize),
    .Hburst(Hburst),
    .HWdata(HWdata),
    .HRdata(HRdata),
    .Hready(Hready),
    .Hresp(Hresp),

    // Arbiter
    .Hreq(Hreq),
    .Hgrant(Hgrant)
  );

  // Clock generation
  always #5 Hclk = ~Hclk;

  // Stimulus
  initial begin
    Hclk = 0;
    Hresetn = 0;
    cmd_valid = 0;
    cmd_addr = '0;
    cmd_data = '0;
    cmd_write = 0;
    cmd_size = 3'b000;
    cmd_burst_len = 3'b000;
    HRdata = '0;
    Hready = 1;
    Hresp  = 2'b00;
    Hgrant = 0;

    // Apply reset
    repeat (3) @(posedge Hclk);
    Hresetn = 1;

    // Wait a little
    @(posedge Hclk);


    // Example: Write transaction to full fifo
    for (int i = 0; i < 4; i++) begin
        @(posedge Hclk);
        cmd_addr = 32'h1000_0000 + (4*i);
        cmd_data = 32'hDEADBEEF + i;
        cmd_write = 1;
        cmd_size = 3'b010;       // word (4 bytes)
        cmd_burst_len = 3'b000;  // single
        cmd_valid = 1;

    end

    @(posedge Hclk);
    cmd_addr = 32'h2000_0000;
    cmd_data = 32'hDEafBEEF;
    cmd_write = 1;
    cmd_size = 3'b010;       // word (4 bytes)
    cmd_burst_len = 3'b000;  // single
    cmd_valid = 1;


    @(posedge Hclk);
    cmd_valid = 0;

    // Grant bus
    @(posedge Hclk); 
    Hgrant = 1;

    repeat (3) @(posedge Hclk);


    // // Example: Read transaction to full fifo
    // for (int = 0; i < 4; i++) begin
    //     @(posedge Hclk);
    //     cmd_addr = 32'h2000_0004;
    //     cmd_data = '0;
    //     cmd_write = 0;
    //     cmd_size = 3'b010;       // word
    //     cmd_burst_len = 3'b000;  // single
    //     cmd_valid = 1;
    //     @(posedge Hclk);
    //     cmd_valid = 0;
    // end


    // // Drive read data from slave
    // @(posedge Hclk);
    // HRdata = 32'hBEEFCAFE;

    // End simulation 
    #200 $stop;
  end

endmodule
