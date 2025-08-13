`timescale 1ns/1ps
`include "../defines/parameters.svh"  // Make sure this defines NUM_SLAVES, NUM_MASTERS, DATA_WIDTH

module slave_to_master_mux_tb;

    // Parameters from para.svh
    localparam NUM_SLAVES  = `NUM_SLAVES;
    localparam NUM_MASTERS = `NUM_MASTERS;
    localparam DATA_WIDTH  = `DATA_WIDTH;
    localparam MASTER_WIDTH  = `MASTER_WIDTH;

    // DUT I/O
    logic                              Hclk;
    logic                              Hresetn;
    logic [NUM_SLAVES-1:0]             Hsel;
    logic [MASTER_WIDTH-1:0]           Hmaster;
    logic [DATA_WIDTH-1:0]             Hrdata_S     [NUM_SLAVES];
    logic [1:0]                        Hresp_S      [NUM_SLAVES];
    logic                              Hreadyout_S  [NUM_SLAVES];

    logic [DATA_WIDTH-1:0]             Hrdata       [NUM_MASTERS];
    logic [1:0]                        Hresp        [NUM_MASTERS];
    logic                              Hready;

    // Instantiate DUT
    slave_to_master_mux dut (
        .Hclk(Hclk),
        .Hresetn(Hresetn),
        .Hsel(Hsel),
        .Hmaster(Hmaster),
        .Hrdata_S(Hrdata_S),
        .Hresp_S(Hresp_S),
        .Hreadyout_S(Hreadyout_S),
        .Hrdata(Hrdata),
        .Hresp(Hresp),
        .Hready(Hready)
    );

    // Clock generation
    initial begin
        Hclk = 0;
        forever #5 Hclk = ~Hclk; // 100 MHz clock
    end

    // Reset generation
    initial begin
        Hresetn = 0;
        #20;
        Hresetn = 1;
    end

    // Stimulus
    initial begin
        // Init inputs
        Hsel         = '0;
        Hmaster      = '0;
        for (int i = 0; i < NUM_SLAVES; i++) begin
            Hrdata_S[i]    = '0;
            Hresp_S[i]     = 2'b00;
            Hreadyout_S[i] = 1'b1;
        end

        @(posedge Hresetn);
        @(posedge Hclk);

        // Test multiple slaves and masters
        for (int m = 0; m < NUM_MASTERS; m++) begin
            for (int s = 0; s < NUM_SLAVES; s++) begin
                drive_slave(s, m, 32'h1000_0000 + s, 2'b01, 1'b1);
                @(posedge Hclk);
                check_output(s, m, 32'h1000_0000 + s, 2'b01, 1'b1);
                @(posedge Hclk);
            end
        end

        // Test default case (no slave selected)
        Hsel = '0;
        Hmaster = 0;
        @(posedge Hclk);
        $display("Checking default output...");
        if (Hrdata[0] !== 32'hDEADBEEF) $error("Default Hrdata mismatch");
        if (Hresp[0]  !== 2'b00)        $error("Default Hresp mismatch");
        if (Hready    !== 1'b1)         $error("Default Hready mismatch");

        $display("All tests completed!");
        $stop;
    end

    // Task to drive one-hot slave and its data
    task drive_slave(input int slave_idx, input int master_idx, 
                     input [DATA_WIDTH-1:0] data, input [1:0] resp, input bit ready);
        Hsel                = '0;
        Hsel[slave_idx]     = 1'b1;
        Hmaster             = master_idx;
        Hrdata_S[slave_idx]    = data;
        Hresp_S[slave_idx]     = resp;
        Hreadyout_S[slave_idx] = ready;
    endtask

    // Task to check output
    task check_output(input int slave_idx, input int master_idx, 
                      input [DATA_WIDTH-1:0] exp_data, input [1:0] exp_resp, input bit exp_ready);
        if (Hrdata[master_idx] !== exp_data)
            $error("Data mismatch: got %h, expected %h", Hrdata[master_idx], exp_data);
        if (Hresp[master_idx] !== exp_resp)
            $error("Resp mismatch: got %b, expected %b", Hresp[master_idx], exp_resp);
        if (Hready !== exp_ready)
            $error("Hready mismatch: got %b, expected %b", Hready, exp_ready);
        else
            $display("PASS: Slave %0d -> Master %0d data=%h resp=%b ready=%b",
                     slave_idx, master_idx, exp_data, exp_resp, exp_ready);
    endtask

endmodule
