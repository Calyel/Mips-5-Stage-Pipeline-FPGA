module control_unit (
    input  wire [5:0] opcode,
    output reg        reg_dst,
    output reg        branch,
    output reg        mem_read,
    output reg        mem_to_reg,
    output reg  [1:0] alu_op,
    output reg        mem_write,
    output reg        alu_src,
    output reg        reg_write,
    output reg        jump
);

    always @(*) begin
        reg_dst    = 1'b0;
        branch     = 1'b0;
        mem_read   = 1'b0;
        mem_to_reg = 1'b0;
        alu_op     = 2'b00;
        mem_write  = 1'b0;
        alu_src    = 1'b0;
        reg_write  = 1'b0;
        jump       = 1'b0;

        case (opcode)
            6'b000000: begin // Instruções Tipo R (add, sub, and, or, slt)
                reg_dst    = 1'b1;
                reg_write  = 1'b1;
                alu_op     = 2'b10;
            end
            6'b100011: begin // lw
                alu_src    = 1'b1;
                mem_to_reg = 1'b1;
                reg_write  = 1'b1;
                mem_read   = 1'b1;
                alu_op     = 2'b00;
            end
            6'b101011: begin // sw
                alu_src    = 1'b1;
                mem_write  = 1'b1;
                alu_op     = 2'b00;
            end
            6'b000100: begin // beq
                branch     = 1'b1;
                alu_op     = 2'b01;
            end
            6'b000010: begin // j (Jump incondicional)
                jump       = 1'b1;
            end
            default: begin
                // Mantém sinais zerados
            end
        endcase
    end

endmodule