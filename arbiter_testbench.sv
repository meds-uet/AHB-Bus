`timescale 1ns/1ps

module tb_ahb_arbiter;

    // Clock and reset
    logic Hclk;
    logic Hresetn;

    // Inputs to DUT
    logic [3:0] Hreq;
    logic       Hready;
    logic [1:0] Htrans;
    logic [2:0] Hburst;

    // Outputs from DUT
    logic [3:0] Hgrant;
    logic [1:0] Hmaster;

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

    // Simulation logic
    initial begin
        $dumpfile("ahb_arbiter.vcd");
        $dumpvars(0, tb_ahb_arbiter);

        // Initialize
        Hresetn = 0;
        Hreq    = 0;
        Hready  = 1;
        Htrans  = 2'b00;
        Hburst  = 3'b000;

        // Apply reset
        repeat (3) @(posedge Hclk);
        Hresetn = 1;

        // === Master 0: Fixed 4-beat burst ===
        @(posedge Hclk);
        Hreq[0]   = 1;
        wait (Hgrant[0] == 1); // Wait for grant
        @(posedge Hclk);
        Hburst    = 3'b011;     // INCR4
        Htrans    = 2'b10;      // NONSEQ

        repeat (1) @(posedge Hclk);
        Htrans = 2'b11;         // SEQ
        repeat (3) @(posedge Hclk); // 3 remaining beats

        // Burst ends
        Htrans = 2'b00;
        Hreq[0] = 0;

        // === Master 1: INCR burst that ends manually ===
        @(posedge Hclk);
        Hreq[1]   = 1;
        wait (Hgrant[1] == 1); // Wait for grant
        @(posedge Hclk);
        Hburst    = 3'b001;     // INCR
        Htrans    = 2'b10;      // NONSEQ

        repeat (1) @(posedge Hclk);
        Htrans = 2'b11;         // SEQ
        repeat (4) @(posedge Hclk);

        // Manually deassert Hreq
        Hreq[1] = 0;
        Htrans  = 2'b00;

        // === Master 2: No request (idle cycle) ===
        repeat (2) @(posedge Hclk);

        // === Master 3: INCR4 burst ===
        @(posedge Hclk);
        Hreq[3]   = 1;
        wait (Hgrant[3] == 1); // Wait for grant
        @(posedge Hclk);
        Hburst    = 3'b011;     // INCR4
        Htrans    = 2'b10;

        repeat (1) @(posedge Hclk);
        Htrans = 2'b11;
        repeat (3) @(posedge Hclk);

        Hreq[3] = 0;
        Htrans = 2'b00;

        // End simulation
        repeat (10) @(posedge Hclk);
        $finish;
    end

endmodule
