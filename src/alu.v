module alu #(
    parameter DATA_WIDTH = 32
)(
    input  wire [DATA_WIDTH-1:0] a,
    input  wire [DATA_WIDTH-1:0] b,
    input  wire [3:0]            alu_control,
    output reg  [DATA_WIDTH-1:0] result,
    output wire                  zero
);

    always @(*) begin
        case (alu_control)
            4'b0000: result = a & b;                       // AND
            4'b0001: result = a | b;                       // OR
            4'b0010: result = a + b;                       // ADD
            4'b0110: result = a - b;                       // SUB
            4'b0111: result = ($signed(a) < $signed(b)) ? {{(DATA_WIDTH-1){1'b0}}, 1'b1} : {DATA_WIDTH{1'b0}}; // SLT
            default: result = {DATA_WIDTH{1'b0}};
        endcase
    end

    assign zero = (result == {DATA_WIDTH{1'b0}}) ? 1'b1 : 1'b0;

endmodule