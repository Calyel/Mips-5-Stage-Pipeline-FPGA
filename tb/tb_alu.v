`timescale 1ns / 1ps

module tb_alu;

    parameter DATA_WIDTH = 32;

    reg  [DATA_WIDTH-1:0] a;
    reg  [DATA_WIDTH-1:0] b;
    reg  [3:0]            alu_control;
    wire [DATA_WIDTH-1:0] result;
    wire                  zero;

    // Instanciação da ALU sob teste (DUT - Device Under Test)
    alu #(
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .a(a),
        .b(b),
        .alu_control(alu_control),
        .result(result),
        .zero(zero)
    );

    initial begin
        $display("=== INICIANDO TESTBENCH DA ALU ===");

        // Teste 1: Operação AND (0000) -> 0x0F0F & 0x00FF = 0x000F
        a = 32'h00000F0F; b = 32'h000000FF; alu_control = 4'b0000;
        #10;
        if (result == 32'h0000000F && zero == 0)
            $display("[PASS] AND: Resultado = %h, Zero = %b", result, zero);
        else
            $display("[FAIL] AND: Resultado = %h, Zero = %b", result, zero);

        // Teste 2: Operação OR (0001) -> 0xF000 | 0x000F = 0xF00F
        a = 32'h0000F000; b = 32'h0000000F; alu_control = 4'b0001;
        #10;
        if (result == 32'h0000F00F && zero == 0)
            $display("[PASS] OR: Resultado = %h, Zero = %b", result, zero);
        else
            $display("[FAIL] OR: Resultado = %h, Zero = %b", result, zero);

        // Teste 3: Operação ADD (0010) -> 15 + 25 = 40 (0x28)
        a = 32'd15; b = 32'd25; alu_control = 4'b0010;
        #10;
        if (result == 32'd40 && zero == 0)
            $display("[PASS] ADD: Resultado = %0d, Zero = %b", result, zero);
        else
            $display("[FAIL] ADD: Resultado = %0d, Zero = %b", result, zero);

        // Teste 4: Operação SUB (0110) com flag ZERO ativa -> 50 - 50 = 0
        a = 32'd50; b = 32'd50; alu_control = 4'b0110;
        #10;
        if (result == 32'd0 && zero == 1)
            $display("[PASS] SUB (Zero Flag): Resultado = %0d, Zero = %b", result, zero);
        else
            $display("[FAIL] SUB (Zero Flag): Esperado zero=1, obteve zero=%b", zero);

        // Teste 5: Operação SLT (0111) com operandos positivos -> 10 < 20 (Verdadeiro = 1)
        a = 32'd10; b = 32'd20; alu_control = 4'b0111;
        #10;
        if (result == 32'd1)
            $display("[PASS] SLT (10 < 20): Resultado = %0d", result);
        else
            $display("[FAIL] SLT: Esperado 1, obteve %0d", result);

        // Teste 6: Operação SLT com complemento a 2 -> -5 < 2 (Verdadeiro = 1)
        a = -32'd5; b = 32'd2; alu_control = 4'b0111;
        #10;
        if (result == 32'd1)
            $display("[PASS] SLT (-5 < 2): Resultado = %0d (Sinal correto)", result);
        else
            $display("[FAIL] SLT (-5 < 2): Esperado 1, obteve %0d", result);

        $display("=== FIM DO TESTBENCH DA ALU ===");
        $finish;
    end

endmodule