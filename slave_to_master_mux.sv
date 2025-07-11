module slave_to_master (
    input  logic         HCLK,
    input  logic         HRESETn,
    input  logic         global_HREADYIN,      // Optional: from memory system
    input  logic [3:0]   slave_select,         // One-hot signal from address decoder
    input  logic [31:0]  HRDATA_S [4],         // From slaves
    input  logic [1:0]   HRESP_S  [4],
    input  logic         HREADYOUT_S [4],

    output logic [31:0]  HRDATA,
    output logic [1:0]   HRESP,
    output logic         HREADY                // Global HREADY for master
);

    // Register selected slave (for pipelined response)
    logic [3:0] selected_slave;

    always_ff @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn)
            selected_slave <= 4'b0000;
        else if (HREADY) // Only update on valid transfer complete
            selected_slave <= slave_select;
    end

    // Output MUX
    always_comb begin
        case (1'b1)
            selected_slave[0]: begin
                HRDATA = HRDATA_S[0];
                HRESP  = HRESP_S[0];
                HREADY = HREADYOUT_S[0]; // Only this line affects global HREADY
            end
            selected_slave[1]: begin
                HRDATA = HRDATA_S[1];
                HRESP  = HRESP_S[1];
                HREADY = HREADYOUT_S[1];
            end
            selected_slave[2]: begin
                HRDATA = HRDATA_S[2];
                HRESP  = HRESP_S[2];
                HREADY = HREADYOUT_S[2];
            end
            selected_slave[3]: begin
                HRDATA = HRDATA_S[3];
                HRESP  = HRESP_S[3];
                HREADY = HREADYOUT_S[3];
            end
            default: begin
                HRDATA = 32'hDEADBEEF;
                HRESP  = 2'b00;
                HREADY = 1'b1; // default: no wait
            end
        endcase
    end

endmodule

