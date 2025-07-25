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
        $dumpfile("sim.vcd");
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

        // === All masters request at the same time ===
        @(posedge Hclk);
        Hreq = 4'b1111; // All request
        Hburst = 3'b011; // INCR4


        Htrans = 2'b10;  // NONSEQ
        repeat (1) @(posedge Hclk);
        Htrans = 2'b11; // SEQ
        repeat (4) @(posedge Hclk);

        Htrans = 2'b10;  // NONSEQ
        repeat (1) @(posedge Hclk);
        Htrans = 2'b11; // SEQ
        repeat (4) @(posedge Hclk);

        Htrans = 2'b10;  // NONSEQ
        repeat (1) @(posedge Hclk);
        Htrans = 2'b11; // SEQ
        repeat (4) @(posedge Hclk);

        

        
        
        $finish;
    end

endmodule
