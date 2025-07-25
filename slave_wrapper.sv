module ahb_slave_wrapper (
    input         HCLK,
    input         HRESETn,
    input  [31:0] HADDR,
    input  [1:0]  HTRANS,
    input         HWRITE,
    input  [2:0]  HSIZE,
    input  [2:0]  HBURST,
    input  [31:0] HWDATA,
    input         HSEL,
    input         HREADY,
    output [31:0] HRDATA,
    output        HREADYOUT,
    output [1:0]  HRESP
);

    // Internal control signals
    reg [31:0] addr_reg;
    reg        write_en, read_en;
    reg [31:0] write_data_reg;

    wire [31:0] read_data;
    wire        slave_ready;
    wire [1:0]  slave_resp;

    // Transaction phase
    wire trans_valid = HSEL && HREADY && (HTRANS[1] == 1'b1);

    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            addr_reg      <= 0;
            write_en      <= 0;
            read_en       <= 0;
            write_data_reg <= 0;
        end else if (trans_valid) begin
            addr_reg <= HADDR;
            write_data_reg <= HWDATA;
            write_en <= HWRITE;
            read_en  <= ~HWRITE;
        end else begin
            write_en <= 0;
            read_en  <= 0;
        end
    end

    my_slave slave_inst (
        .clk(HCLK),
        .resetn(HRESETn),
        .addr(addr_reg),
        .write_data(write_data_reg),
        .write_en(write_en),
        .read_en(read_en),
        .read_data(read_data),
        .ready(slave_ready),
        .resp(slave_resp)
    );

    // Output assignments
    assign HRDATA    = read_data;
    assign HREADYOUT = slave_ready;
    assign HRESP     = slave_resp;

endmodule

