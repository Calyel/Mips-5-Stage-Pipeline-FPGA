module instruction_memory #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter MEM_DEPTH  = 256
)(
    input  wire [ADDR_WIDTH-1:0] address,
    output wire [DATA_WIDTH-1:0] instruction
);

    reg [DATA_WIDTH-1:0] mem [0:MEM_DEPTH-1];

    initial begin
        // Programa de teste:
        // 0x00: addi $t0, $zero, 5  -> 20080005 (usando add com registradores se addi não existir)
        // Usando Tipo R padrão montado na primeira entrega:
        // PC 0: add  $t1, $zero, $zero -> 00004820
        // PC 4: add  $t2, $zero, $zero -> 00005020
        // PC 8: j 0x00000010 (Jump para o endereço 16 em bytes, target palavra 4) -> 08000004
        // PC 12: add $t3, $t1, $t2     -> 012A5820 (instrução ignorada pelo jump)
        // PC 16: add $t4, $zero, $zero -> 00006020 (alvo do jump)
        mem[0] = 32'h00004820; // add $t1, $zero, $zero
        mem[1] = 32'h00005020; // add $t2, $zero, $zero
        mem[2] = 32'h08000004; // j 0x10 (word address 4)
        mem[3] = 32'h012A5820; // add $t3, $t1, $t2 (deve ser pulada)
        mem[4] = 32'h00006020; // add $t4, $zero, $zero (endereço alcançado via jump)
    end

    // Alinhamento por palavra de 32 bits (descarta os 2 LSBs do PC)
    assign instruction = mem[address[ADDR_WIDTH-1:2]];

endmodule