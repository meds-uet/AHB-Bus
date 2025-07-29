// Copyright 2025 Maktab-e-Digital Systems Lahore.
// Licensed under the Apache License, Version 2.0, see LICENSE file for details.
// SPDX-License-Identifier: Apache-2.0
//
// Description: 
// This module is a slave wrapper for AHB bus.
// That maps the input and ouput signals to the selected slave.
//
// Author: Muhammad Yousaf and Ali Tahir
// Date:   29-July-2025



`include "../defines/header.svh"
import param_pkg::*;

module ahb_slave_wrapper (

    input                              Hclk,
    input                              Hresetn,
    input  [ADDR_WIDTH-1:0]            Haddr,
    input  [1:0]                       Htrans,
    input                              Hwrite,
    input  [2:0]                       Hsize,
    input  [2:0]                       Hburst,
    input  [DATA_WIDTH-1:0]            HWdata,
    input  [DATA_WIDTH/8-1:0]          Hstrob,
    input                              Hsel,
    input                              Hready,
    output [DATA_WIDTH-1:0]            HRdata,
    output                             Hreadyout,
    output [1:0]                       Hresp

);

    // Internal control signals
    reg [31:0] addr_reg;
    reg        write_en, read_en;
    reg [31:0] write_data_reg;

    wire [31:0] read_data;
    wire        slave_ready;
    wire [1:0]  slave_resp;

    // Transaction phase
    wire trans_valid = Hsel && Hready && (Htrans[1] == 1'b1);

    always @(posedge Hclk or negedge Hresetn) begin
        if (!Hresetn) begin
            addr_reg      <= 0;
            write_en      <= 0;
            read_en       <= 0;
            write_data_reg <= 0;
        end else if (trans_valid) begin
            addr_reg <= Haddr;
            write_data_reg <= HWdata;
            write_en <= Hwrite;
            read_en  <= ~Hwrite;
        end else begin
            write_en <= 0;
            read_en  <= 0;
        end
    end

    my_slave slave_inst (
        .clk(Hclk),
        .resetn(Hresetn),
        .addr(addr_reg),
        .write_data(write_data_reg),
        .write_en(write_en),
        .read_en(read_en),
        .read_data(read_data),
        .ready(slave_ready),
        .resp(slave_resp)
    );

    // Output assignments
    assign HRdata    = read_data;
    assign Hreadyout = slave_ready;
    assign Hresp     = slave_resp;

endmodule