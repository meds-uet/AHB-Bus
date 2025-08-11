// Copyright 2025 Maktab-e-Digital Systems Lahore.
// Licensed under the Apache License, Version 2.0, see LICENSE file for details.
// SPDX-License-Identifier: Apache-2.0
//
// Description: 
// 
// This module tests the master to slave multiplexer for the AHB bus.
//
//
// Author: Muhammad Yousaf and Ali Tahir
// Date:   11-August-2025


`timescale 1ns/1ps
`include "../defines/parameters.svh"

module master_to_slave_mux_tb;

  // Parameters from your defines file
  localparam NUM_MASTERS = `NUM_MASTERS;
  localparam DATA_WIDTH  = `DATA_WIDTH;

  // Inputs
  logic [$clog2(NUM_MASTERS)-1:0]          Hmaster;
  logic [DATA_WIDTH-1:0]                   Haddr_M  [NUM_MASTERS];
  logic [1:0]                              Htrans_M [NUM_MASTERS];
  logic                                    Hwrite_M [NUM_MASTERS];
  logic [2:0]                              Hsize_M  [NUM_MASTERS];
  logic [2:0]                              Hburst_M [NUM_MASTERS];
  logic [DATA_WIDTH/8-1:0]                 Hstrob_M [NUM_MASTERS];
  logic [DATA_WIDTH-1:0]                   Hwdata_M [NUM_MASTERS];

  // Outputs
  logic [DATA_WIDTH-1:0]                   Haddr;
  logic [1:0]                              Htrans;
  logic                                    Hwrite;
  logic [2:0]                              Hsize;
  logic [2:0]                              Hburst;
  logic [DATA_WIDTH/8-1:0]                 Hstrob;
  logic [DATA_WIDTH-1:0]                   Hwdata;

  // Instantiate the DUT
  master_to_slave_mux dut (
    .Hmaster(Hmaster),
    .Haddr_M(Haddr_M),
    .Htrans_M(Htrans_M),
    .Hwrite_M(Hwrite_M),
    .Hsize_M(Hsize_M),
    .Hburst_M(Hburst_M),
    .Hstrob_M(Hstrob_M),
    .Hwdata_M(Hwdata_M),

    .Haddr(Haddr),
    .Htrans(Htrans),
    .Hwrite(Hwrite),
    .Hsize(Hsize),
    .Hburst(Hburst),
    .Hstrob(Hstrob),
    .Hwdata(Hwdata)
  );

  // Initialize inputs and drive test vectors
  initial begin
    // Initialize arrays with known values
    for (int i = 0; i < NUM_MASTERS; i++) begin
      Haddr_M[i]  = i * 16'h1111;
      Htrans_M[i] = i[1:0];          // Just use lower 2 bits of i
      Hwrite_M[i] = (i % 2);         // Alternate write 0/1
      Hsize_M[i]  = i[2:0];          // lower 3 bits
      Hburst_M[i] = 3'b010;          // fixed burst for all
      Hstrob_M[i] = {(DATA_WIDTH/8){1'b1}}; // all strobes enabled
      Hwdata_M[i] = i * 16'h2222;
    end

    // Test each master selection
    for (int master = 0; master < NUM_MASTERS; master++) begin
      Hmaster = master;
      #10; // wait for outputs to propagate

      // Display results
      $display("Selecting master %0d:", master);
      $display("  Output Haddr  = 0x%0h (Expected: 0x%0h)", Haddr, Haddr_M[master]);
      $display("  Output Htrans = 0x%0h (Expected: 0x%0h)", Htrans, Htrans_M[master]);
      $display("  Output Hwrite = %0b (Expected: %0b)", Hwrite, Hwrite_M[master]);
      $display("  Output Hsize  = 0x%0h (Expected: 0x%0h)", Hsize, Hsize_M[master]);
      $display("  Output Hburst = 0x%0h (Expected: 0x%0h)", Hburst, Hburst_M[master]);
      $display("  Output Hstrob = 0x%0h (Expected: 0x%0h)", Hstrob, Hstrob_M[master]);
      $display("  Output Hwdata = 0x%0h (Expected: 0x%0h)", Hwdata, Hwdata_M[master]);
      $display("-------------------------------------------------");
    end

    $stop;
  end

endmodule