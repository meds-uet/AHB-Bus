module master_to_slave_mux (
    input  logic [1:0]   Hmaster,   // Selected master index
    input  logic [31:0]  Haddr_M [4],
    input  logic [1:0]   Htrans_M [4],
    input  logic         Hwrite_M [4],
    input  logic [2:0]   Hsize_M  [4],
    input  logic [2:0]   Hburst_M [4],
    input  logic [3:0]   Hprot_M  [4],
    input  logic [31:0]  Hwdata_M [4],

    output logic [31:0]  Haddr,
    output logic [1:0]   Htrans,
    output logic         Hwrite,
    output logic [2:0]   Hsize,
    output logic [2:0]   Hburst,
    output logic [3:0]   Hprot,
    output logic [31:0]  Hwdata
);

    assign Haddr   = Haddr_M[Hmaster];
    assign Htrans  = Htrans_M[Hmaster];
    assign Hwrite  = Hwrite_M[Hmaster];
    assign Hsize   = Hsize_M[Hmaster];
    assign Hburst  = Hburst_M[Hmaster];
    assign Hprot   = Hprot_M[Hmaster];
    assign Hwdata  = Hwdata_M[Hmaster];

endmodule

