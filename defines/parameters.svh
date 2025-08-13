// Copyright 2025 Maktab-e-Digital Systems Lahore.
// Licensed under the Apache License, Version 2.0, see LICENSE file for details.
// SPDX-License-Identifier: Apache-2.0
//
// Description: 
// This module contains the parameters for AHB bus.
//
//
// Author: Muhammad Yousaf and Ali Tahir
// Date:   07-August-2025


`define NUM_MASTERS 4
`define NUM_SLAVES 4
`define DATA_WIDTH 32
`define ADDR_WIDTH 32

`define MASTER_WIDTH (`NUM_MASTERS > 1) ? $clog2(`NUM_MASTERS) : 1
`define SLAVE_WIDTH (`NUM_SLAVES > 1) ? $clog2(`NUM_SLAVES) : 1

// Do not forget to match the address range with the NUM_SLAVES

localparam [`ADDR_WIDTH-1:0] BASE_ADDR [0:`NUM_SLAVES-1] = '{
    32'h0000_0000,
    32'h1000_0000,
    32'h2000_0000,
    32'h3000_0000
};

localparam [`ADDR_WIDTH-1:0] HIGH_ADDR [0:`NUM_SLAVES-1] = '{
    32'h0FFF_FFFF,
    32'h1FFF_FFFF,
    32'h2FFF_FFFF,
    32'h3FFF_FFFF
};