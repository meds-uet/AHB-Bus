module decoder #(
    parameter NUM_SUBORD = 3,
    parameter ADDR_WIDTH = 32,

    parameter logic [ADDR_WIDTH-1:0] BASE_ADDR [0:NUM_SUBORD-1] = '{
        32'h0000_0000,
        32'hEEEE_0000,
        32'hFFFF_0000
    },

    parameter logic [ADDR_WIDTH-1:0] HIGH_ADDR [0:NUM_SUBORD-1] = '{
        32'hEEEE_0000,
        32'hFFFF_0000,
        32'hFFFF_FFFF
    }

) (
    input logic [ADDR_WIDTH-1:0] Haddr,

    output logic [NUM_SUBORD-1:0] Hsel
);

always_comb begin

    Hsel = 'b0;
    integer i;
    for (i = 0; i < NUM_SUBORD; i++) begin
            if ((Haddr >= BASE_ADDR[i]) && (Haddr < HIGH_ADDR[i]) && (Hready == 1'b1)) begin
                Hsel[i] = 1'b1;
            end
    end

end

endmodule