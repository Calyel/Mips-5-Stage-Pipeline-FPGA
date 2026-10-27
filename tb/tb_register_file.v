`timescale 1ns / 1ps

module tb_register_file;

    parameter DATA_WIDTH = 32;
    parameter ADDR_WIDTH = 5;

    reg                   clk;
    reg                   rst;
    reg                   reg_write;
    reg  [ADDR_WIDTH-1:0] read_reg1;
    reg  [ADDR_WIDTH-1:0] read_reg2;
    reg  [ADDR_WIDTH-1:0] write_reg;
    reg  [DATA_WIDTH-1:0] write_data;
    wire [DATA_WIDTH-1:0] read_data1;
    wire [DATA_WIDTH-1:0] read_data2;

    // Instanciação do Banco de Registradores sob teste (DUT)
    register_file #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) dut (
        .clk(clk),
        .rst(rst),
        .reg_write(reg_write),
        .read_reg1(read_reg1),
        .read_reg2(read_reg2),
        .write_reg(write_reg),
        .write_data(write_data),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    // Geração de Clock (período de 10 ns -> 100 MHz)
    always #5 clk = ~clk;

    initial begin
        $display("=== INICIANDO TESTBENCH DO BANCO DE REGISTRADORES ===");
        clk = 0;
        rst = 1;
        reg_write = 0;
        write_reg = 0;
        write_data = 0;
        read_reg1 = 0;
        read_reg2 = 0;

        // 1. Aplicação do Reset
        #15;
        rst = 0;
        #10;

        // 2. Escrita no registrador 1 ($at) com valor 0xAAAA_1111
        @(posedge clk);
        write_reg = 5'd1;
        write_data = 32'hAAAA_1111;
        reg_write = 1;

        // 3. Escrita no registrador 2 ($v0) com valor 0xBBBB_2222
        @(posedge clk);
        write_reg = 5'd2;
        write_data = 32'hBBBB_2222;
        reg_write = 1;

        // 4. Teste crítico: Tentativa de escrita no Registrador 0 ($zero)
        @(posedge clk);
        write_reg = 5'd0;
        write_data = 32'hFFFF_FFFF; // Não pode ser gravado!
        reg_write = 1;

        // 5. Desabilita escrita e testa leitura simultânea de duas portas
        @(posedge clk);
        reg_write = 0;
        read_reg1 = 5'd1; // Deve ler 0xAAAA_1111
        read_reg2 = 5'd2; // Deve ler 0xBBBB_2222
        #5;

        if (read_data1 == 32'hAAAA_1111 && read_data2 == 32'hBBBB_2222)
            $display("[PASS] Leitura Portas 1 e 2: Reg1=%h, Reg2=%h", read_data1, read_data2);
        else
            $display("[FAIL] Leitura Portas 1 e 2: Erro nos dados armazenados!");

        // 6. Verificação de integridade do Registrador $zero
        read_reg1 = 5'd0;
        #5;
        if (read_data1 == 32'h0000_0000)
            $display("[PASS] Imunidade do $zero: Registrador 0 manteve valor zero constante.");
        else
            $display("[FAIL] Imunidade do $zero: Registrador 0 foi corrompido para %h!", read_data1);

        // 7. Teste de tentativa de escrita com RegWrite desativado
        @(posedge clk);
        write_reg = 5'd1;
        write_data = 32'hDEAD_BEEF;
        reg_write = 0; // Escrita bloqueada
        @(posedge clk);
        #5;
        read_reg1 = 5'd1;
        #5;
        if (read_data1 == 32'hAAAA_1111)
            $display("[PASS] RegWrite Inativo: O valor anterior de Reg1 foi preservado.");
        else
            $display("[FAIL] RegWrite Inativo: Escrita não autorizada ocorreu!");

        $display("=== FIM DO TESTBENCH DO BANCO DE REGISTRADORES ===");
        $finish;
    end

endmodule