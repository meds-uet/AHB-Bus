`timescale 1ns/1ps

module tb_ahb_arbiter;

    // Clock and reset
    logic HCLK;
    logic HRESETn;

    // Inputs to DUT
    logic [3:0] HREQ;
    logic       HREADY;
    logic [1:0] HTRANS;
    logic [2:0] HBURST;

    // Outputs from DUT
    logic [3:0] HGRANT;
    logic [1:0] HMASTER;

    // Instantiate DUT
    ahb_arbiter dut (
        .HCLK(HCLK),
        .HRESETn(HRESETn),
        .HREQ(HREQ),
        .HREADY(HREADY),
        .HTRANS(HTRANS),
        .HBURST(HBURST),
        .HGRANT(HGRANT),
        .HMASTER(HMASTER)
    );

    // Clock generation
    initial HCLK = 0;
    always #5 HCLK = ~HCLK; // 100MHz

    // Simulation logic
    initial begin
        $dumpfile("ahb_arbiter.vcd");
        $dumpvars(0, tb_ahb_arbiter);

        // Initialize
        HRESETn = 0;
        HREQ    = 0;
        HREADY  = 1;
        HTRANS  = 2'b00;
        HBURST  = 3'b000;

        // Apply reset
        repeat (3) @(posedge HCLK);
        HRESETn = 1;

        // === Master 0: Fixed 4-beat burst ===
        @(posedge HCLK);
        HREQ[0]   = 1;
        wait (HGRANT[0] == 1); // Wait for grant
        @(posedge HCLK);
        HBURST    = 3'b011;     // INCR4
        HTRANS    = 2'b10;      // NONSEQ

        repeat (1) @(posedge HCLK);
        HTRANS = 2'b11;         // SEQ
        repeat (3) @(posedge HCLK); // 3 remaining beats

        // Burst ends
        HTRANS = 2'b00;
        HREQ[0] = 0;

        // === Master 1: INCR burst that ends manually ===
        @(posedge HCLK);
        HREQ[1]   = 1;
        wait (HGRANT[1] == 1); // Wait for grant
        @(posedge HCLK);
        HBURST    = 3'b001;     // INCR
        HTRANS    = 2'b10;      // NONSEQ

        repeat (1) @(posedge HCLK);
        HTRANS = 2'b11;         // SEQ
        repeat (4) @(posedge HCLK);

        // Manually deassert HREQ
        HREQ[1] = 0;
        HTRANS  = 2'b00;

        // === Master 2: No request (idle cycle) ===
        repeat (2) @(posedge HCLK);

        // === Master 3: INCR4 burst ===
        @(posedge HCLK);
        HREQ[3]   = 1;
        wait (HGRANT[3] == 1); // Wait for grant
        @(posedge HCLK);
        HBURST    = 3'b011;     // INCR4
        HTRANS    = 2'b10;

        repeat (1) @(posedge HCLK);
        HTRANS = 2'b11;
        repeat (3) @(posedge HCLK);

        HREQ[3] = 0;
        HTRANS = 2'b00;

        // End simulation
        repeat (10) @(posedge HCLK);
        $finish;
    end

endmodule
