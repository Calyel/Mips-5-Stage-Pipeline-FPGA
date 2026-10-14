# Processador MIPS com Pipeline de 5 Estágios

Projeto desenvolvido para a disciplina de Arquitetura de Sistemas Digitais da Universidade Federal do Amazonas - UFAM.

## Integrantes

- Calyel Junio de Andrade dos Santos
- Franklin Alex Ramos da Silva Junior

## Descrição

O projeto consiste na implementação de um processador MIPS de 32 bits utilizando pipeline de cinco estágios.

Os cinco estágios são:

- IF - Instruction Fetch
- ID - Instruction Decode
- EX - Execute
- MEM - Memory Access
- WB - Write Back

## Objetivo

Desenvolver um processador MIPS modular em Verilog HDL, com pipeline de cinco estágios e mecanismos para tratamento de hazards.

O processador será validado utilizando um algoritmo de ordenação implementado em Assembly MIPS.

## Plataforma

- Verilog HDL
- Arquitetura MIPS 32 bits
- FPGA DE2-115
- MARS MIPS Simulator
- GitHub
- Trello

## Programa de validação

O programa utilizado para testar o processador é baseado nos procedimentos:

- sort
- swap

As principais instruções utilizadas são:

- add
- addu
- addi
- sll
- slt
- slti
- lw
- sw
- beq
- bne
- j
- jal
- jr

## Estrutura do projeto

```text
assembly/   Código Assembly MIPS
memory/     Código binário da memória de programa
src/        Módulos principais em Verilog
pipeline/   Registradores do pipeline
testbench/  Arquivos de teste
docs/       Relatórios e documentação