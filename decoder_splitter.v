`timescale 1ns / 1ps

module Decd(
    input [31:0] Instr,
    output [31:26] opCode,
    output [5:0] func,
    output [15:11] rd_15_11,
    output [20:16] rt_20_16,
    output [25:21] rs_25_21,
    output [10:6] shamt,
    output [15:0] imm16,
    output [25:0] imm26
    );
    
    assign { opCode, rs_25_21, rt_20_16, rd_15_11, shamt, func } = Instr;
    assign imm16 = Instr[15:0];
    assign imm26 = Instr[25:0];


endmodule
