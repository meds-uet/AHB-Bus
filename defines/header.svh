// Copyright 2025 Maktab-e-Digital Systems Lahore.
// Licensed under the Apache License, Version 2.0, see LICENSE file for details.
// SPDX-License-Identifier: Apache-2.0
//
// Description: 
// This module contains the parameters for AHB bus.
//
//
// Author: Muhammad Yousaf and Ali Tahir
// Date:   29-July-2025


package param_pkg;

    parameter int NUM_MASTERS = 4;
    parameter int NUM_SLAVES = 4;
    parameter int DATA_WIDTH = 32;
    parameter int ADDR_WIDTH = 32;

    parameter logic [ADDR_WIDTH-1:0] BASE_ADDR [0:NUM_SLAVES-1] = '{
        32'h0000_0000,
        32'hEEEE_0000,
        32'hFFFF_0000
    },

    parameter logic [ADDR_WIDTH-1:0] HIGH_ADDR [0:NUM_SLAVES-1] = '{
        32'hEEEE_0000,
        32'hFFFF_0000,
        32'hFFFF_FFFF
    }


endpackage
