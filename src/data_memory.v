module data_memory #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter MEM_DEPTH  = 256
)(
    input  wire                  clk,
    input  wire                  mem_read,
    input  wire                  mem_write,
    input  wire [ADDR_WIDTH-1:0] address,
    input  wire [DATA_WIDTH-1:0] write_data,
    output wire [DATA_WIDTH-1:0] read_data
);

    reg [DATA_WIDTH-1:0] mem [0:MEM_DEPTH-1];

    assign read_data = (mem_read) ? mem[address[ADDR_WIDTH-1:2]] : {DATA_WIDTH{1'b0}};

    always @(posedge clk) begin
        if (mem_write) begin
            mem[address[ADDR_WIDTH-1:2]] <= write_data;
        end
    end

endmodule