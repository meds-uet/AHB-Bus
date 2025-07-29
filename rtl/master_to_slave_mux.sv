module master_to_slave_mux #(

    parameter integer NUM_MASTERS = 4,
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32

) (

    input  logic [1:0]                      Hmaster,   // Selected master index
    input  logic [DATA_WIDTH-1:0]           Haddr_M  [NUM_MASTERS],
    input  logic [1:0]                      Htrans_M [NUM_MASTERS],
    input  logic                            Hwrite_M [NUM_MASTERS],
    input  logic [2:0]                      Hsize_M  [NUM_MASTERS],
    input  logic [2:0]                      Hburst_M [NUM_MASTERS],
    input logic  [DATA_WIDTH/8-1:0]         Hstrob_M [NUM_MASTERS],
    input  logic [DATA_WIDTH-1:0]           Hwdata_M [NUM_MASTERS],

    output logic [DATA_WIDTH-1:0]           Haddr,
    output logic [1:0]                      Htrans,
    output logic                            Hwrite,
    output logic [2:0]                      Hsize,
    output logic [2:0]                      Hburst,
    output logic [DATA_WIDTH/8-1:0]         Hstrob,
    output logic [DATA_WIDTH-1:0]           Hwdata

);

    assign Haddr   = Haddr_M[Hmaster];
    assign Htrans  = Htrans_M[Hmaster];
    assign Hwrite  = Hwrite_M[Hmaster];
    assign Hsize   = Hsize_M[Hmaster];
    assign Hburst  = Hburst_M[Hmaster];
    assign Hstrob  = Hstrob_M[Hmaster];
    assign Hwdata  = Hwdata_M[Hmaster];

endmodule