module slave_to_master (
    input  logic         Hclk,
    input  logic         Hresetn,
    input  logic         global_Hreadyin,      // Optional: from memory system
    input  logic [3:0]   slave_select,         // One-hot signal from address decoder
    input  logic [31:0]  Hrdata_S [4],         // From slaves
    input  logic [1:0]   Hresp_S  [4],
    input  logic         Hreadyout_S [4],

    output logic [31:0]  Hrdata,
    output logic [1:0]   Hresp,
    output logic         Hready                // Global Hready for master
);

    // Register selected slave (for pipelined response)
    logic [3:0] selected_slave;

    always_ff @(posedge Hclk or negedge Hresetn) begin
        if (!Hresetn)
            selected_slave <= 4'b0000;
        else if (Hready) // Only update on valid transfer complete
            selected_slave <= slave_select;
    end

    // Output MUX
    always_comb begin
        case (1'b1)
            selected_slave[0]: begin
                Hrdata = Hrdata_S[0];
                Hresp  = Hresp_S[0];
                Hready = Hreadyout_S[0]; // Only this line affects global Hready
            end
            selected_slave[1]: begin
                Hrdata = Hrdata_S[1];
                Hresp  = Hresp_S[1];
                Hready = Hreadyout_S[1];
            end
            selected_slave[2]: begin
                Hrdata = Hrdata_S[2];
                Hresp  = Hresp_S[2];
                Hready = Hreadyout_S[2];
            end
            selected_slave[3]: begin
                Hrdata = Hrdata_S[3];
                Hresp  = Hresp_S[3];
                Hready = Hreadyout_S[3];
            end
            default: begin
                Hrdata = 32'hDEADBEEF;
                Hresp  = 2'b00;
                Hready = 1'b1; // default: no wait
            end
        endcase
    end

endmodule

