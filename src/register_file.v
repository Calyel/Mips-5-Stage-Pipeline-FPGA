module register_file #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 5
)(
    input  wire                  clk,
    input  wire                  rst,
    input  wire                  reg_write,
    input  wire [ADDR_WIDTH-1:0] read_reg1,
    input  wire [ADDR_WIDTH-1:0] read_reg2,
    input  wire [ADDR_WIDTH-1:0] write_reg,
    input  wire [DATA_WIDTH-1:0] write_data,
    output wire [DATA_WIDTH-1:0] read_data1,
    output wire [DATA_WIDTH-1:0] read_data2
);

    reg [DATA_WIDTH-1:0] registers [0:31];
    integer k;

    // Leitura assíncrona: registrador 0 sempre retorna 0
    assign read_data1 = (read_reg1 == 5'd0) ? {DATA_WIDTH{1'b0}} : registers[read_reg1];
    assign read_data2 = (read_reg2 == 5'd0) ? {DATA_WIDTH{1'b0}} : registers[read_reg2];

    // Escrita síncrona na subida de clock com reset síncrono
    always @(posedge clk) begin
        if (rst) begin
            for (k = 0; k < 32; k = k + 1)
                registers[k] <= {DATA_WIDTH{1'b0}};
        end else if (reg_write && (write_reg != 5'd0)) begin
            registers[write_reg] <= write_data;
        end
    end

endmodule