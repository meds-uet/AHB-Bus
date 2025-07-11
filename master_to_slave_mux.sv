module master_to_slave_mux (
    input  logic [1:0]   HMASTER,   // Selected master index
    input  logic [31:0]  HADDR_M [4],
    input  logic [1:0]   HTRANS_M [4],
    input  logic         HWRITE_M [4],
    input  logic [2:0]   HSIZE_M  [4],
    input  logic [2:0]   HBURST_M [4],
    input  logic [3:0]   HPROT_M  [4],
    input  logic [31:0]  HWDATA_M [4],

    output logic [31:0]  HADDR,
    output logic [1:0]   HTRANS,
    output logic         HWRITE,
    output logic [2:0]   HSIZE,
    output logic [2:0]   HBURST,
    output logic [3:0]   HPROT,
    output logic [31:0]  HWDATA
);

    assign HADDR   = HADDR_M[HMASTER];
    assign HTRANS  = HTRANS_M[HMASTER];
    assign HWRITE  = HWRITE_M[HMASTER];
    assign HSIZE   = HSIZE_M[HMASTER];
    assign HBURST  = HBURST_M[HMASTER];
    assign HPROT   = HPROT_M[HMASTER];
    assign HWDATA  = HWDATA_M[HMASTER];

endmodule

