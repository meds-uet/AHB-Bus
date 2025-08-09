// Copyright 2025 Maktab-e-Digital Systems Lahore.
// Licensed under the Apache License, Version 2.0, see LICENSE file for details.
// SPDX-License-Identifier: Apache-2.0
//
// Description: 
// This module is a slave wrapper for AHB bus.
// That maps the input and ouput signals to the selected slave.
//
// Author: Muhammad Yousaf and Ali Tahir
// Date:   09-August-2025



`include "../defines/parameters.svh"

module ahb_slave_wrapper (

    input  logic                             Hclk,
    input  logic                             Hresetn,
    input  logic [`ADDR_WIDTH-1:0]           Haddr,
    input  logic [1:0]                       Htrans,
    input  logic                             Hwrite,
    input  logic [2:0]                       Hsize,
    input  logic [2:0]                       Hburst,
    input  logic [`DATA_WIDTH-1:0]           HWdata,
    input  logic [`DATA_WIDTH/8-1:0]         Hstrob,
    input  logic                             Hsel,
    input  logic                             Hready,
    output logic [`DATA_WIDTH-1:0]           HRdata,
    output logic                             Hreadyout,
    output logic [1:0]                       Hresp

);

    // Internal control signals
    reg [`ADDR_WIDTH-1:0] addr_reg;
    reg        write_en, read_en;
    reg [`DATA_WIDTH-1:0] write_data_reg;

    wire [`DATA_WIDTH-1:0] read_data;
    wire        slave_ready;
    wire [$clog2(`Num_Slaves)-1:0]  slave_resp;

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