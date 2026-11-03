module mips_monociclo #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32
)(
    input  wire                   clk,
    input  wire                   rst,
    // Portas de saída de monitoramento/depuração para o FPGA e simulação
    output wire [ADDR_WIDTH-1:0]  out_pc,
    output wire [DATA_WIDTH-1:0]  out_alu_result,
    output wire [DATA_WIDTH-1:0]  out_instruction
);

    // =========================================================================
    // 1. Barramentos e Registradores do Program Counter (PC)
    // =========================================================================
    reg  [ADDR_WIDTH-1:0] pc;
    wire [ADDR_WIDTH-1:0] pc_next;
    wire [ADDR_WIDTH-1:0] pc_plus4;
    wire [ADDR_WIDTH-1:0] pc_branch;
    wire [ADDR_WIDTH-1:0] pc_jump;
    wire [ADDR_WIDTH-1:0] pc_branch_candidate;

    // =========================================================================
    // 2. Fatiamento da Instrução MIPS
    // =========================================================================
    wire [DATA_WIDTH-1:0] instruction;
    wire [5:0]  opcode      = instruction[31:26];
    wire [4:0]  rs          = instruction[25:21];
    wire [4:0]  rt          = instruction[20:16];
    wire [4:0]  rd          = instruction[15:11];
    wire [15:0] imm16       = instruction[15:0];
    wire [25:0] jump_target = instruction[25:0];

    // =========================================================================
    // 3. Sinais de Controle
    // =========================================================================
    wire       reg_dst, branch, mem_read, mem_to_reg, mem_write, alu_src, reg_write, jump;
    wire [1:0] alu_op;
    wire [3:0] alu_control;
    wire       alu_zero;

    // =========================================================================
    // 4. Barramentos Internos de Dados
    // =========================================================================
    wire [4:0]            write_reg;
    wire [DATA_WIDTH-1:0] read_data1, read_data2;
    wire [DATA_WIDTH-1:0] sign_ext_imm;
    wire [DATA_WIDTH-1:0] alu_src_b;
    wire [DATA_WIDTH-1:0] alu_result;
    wire [DATA_WIDTH-1:0] mem_read_data;
    wire [DATA_WIDTH-1:0] reg_write_data;

    // =========================================================================
    // 5. Lógica de Atualização do PC (Sequencial, Branch e Jump)
    // =========================================================================
    // PC + 4
    assign pc_plus4  = pc + 32'd4;

    // Endereço de Jump: { PC+4[31:28], target[25:0], 2'b00 }
    assign pc_jump   = {pc_plus4[31:28], jump_target, 2'b00};

    // Endereço de Branch: PC+4 + (offset estendido << 2)
    assign pc_branch = pc_plus4 + (sign_ext_imm << 2);

    // Mux de seleção entre PC+4 e PC_Branch
    assign pc_branch_candidate = (branch & alu_zero) ? pc_branch : pc_plus4;

    // Mux de seleção final com Jump
    assign pc_next = (jump) ? pc_jump : pc_branch_candidate;

    // Registrador de Estado do PC
    always @(posedge clk or posedge rst) begin
        if (rst)
            pc <= 32'h00000000;
        else
            pc <= pc_next;
    end

    // =========================================================================
    // 6. Instanciação dos Módulos Funcionais
    // =========================================================================

    // Memória de Instruções
    instruction_memory #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) imem (
        .address(pc),
        .instruction(instruction)
    );

    // Unidade de Controle Principal
    control_unit ctrl (
        .opcode(opcode),
        .reg_dst(reg_dst),
        .branch(branch),
        .mem_read(mem_read),
        .mem_to_reg(mem_to_reg),
        .alu_op(alu_op),
        .mem_write(mem_write),
        .alu_src(alu_src),
        .reg_write(reg_write),
        .jump(jump)
    );

    // Mux de seleção do registrador destino (rt ou rd)
    assign write_reg = (reg_dst) ? rd : rt;

    // Banco de Registradores
    register_file #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(5)
    ) rf (
        .clk(clk),
        .rst(rst),
        .reg_write(reg_write),
        .read_reg1(rs),
        .read_reg2(rt),
        .write_reg(write_reg),
        .write_data(reg_write_data),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    // Extensor de Sinal de 16 para 32 bits
    assign sign_ext_imm = {{16{imm16[15]}}, imm16};

    // Unidade de Controle da ALU
    alu_control_unit alu_ctrl (
        .alu_op(alu_op),
        .funct(instruction[5:0]),
        .alu_control(alu_control)
    );

    // Mux de seleção do segundo operando da ALU (Registrador ou Imediato)
    assign alu_src_b = (alu_src) ? sign_ext_imm : read_data2;

    // Unidade Lógica e Aritmética (ALU)
    alu #(
        .DATA_WIDTH(DATA_WIDTH)
    ) alu_unit (
        .a(read_data1),
        .b(alu_src_b),
        .alu_control(alu_control),
        .result(alu_result),
        .zero(alu_zero)
    );

    // Memória de Dados
    data_memory #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) dmem (
        .clk(clk),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .address(alu_result),
        .write_data(read_data2),
        .read_data(mem_read_data)
    );

    // Mux de Write-back (Dado da Memória vs Resultado da ALU)
    assign reg_write_data = (mem_to_reg) ? mem_read_data : alu_result;

    // =========================================================================
    // 7. Ligação das Portas de Saída para Depuração e Síntese
    // =========================================================================
    assign out_pc          = pc;
    assign out_alu_result  = alu_result;
    assign out_instruction = instruction;

endmodule