`timescale 1ns / 1ps
`include "Constants.v"

module IFU(
    input clk,
    input reset,
    input [1:0] npcOp,
    input [15:0] imm16,
    input [25:0] imm26,
    input [31:0] regData,
    input branch,
    output [31:0] PC,
    output [31:0] PC8,
    input En,
    
    input [31:0] EPC,
    input        req,
    input        eret,
    output       ExcAdEL
    );

    reg  [31:0] PC_R;
    wire [31:0] NPC_Final, NPC, PC4;

    always @(posedge clk) begin
        if (reset)
            PC_R <= `PC_START;
        else if (En)
            PC_R <= NPC_Final;
        else
            PC_R <= PC_R;
    end
    
    assign PC = eret ? EPC : PC_R;
    assign PC4 = PC + 32'h4;
    assign PC8 = PC + 32'h8;
    
    assign ExcAdEL = !eret && ((|PC[1:0]) || (PC < 32'h0000_0000) || (PC > 32'h0000_6ffc));

    MUX32_4 u_mux_32_4(
        .Sel(npcOp),
        .DI_00(PC4),
        .DI_01(branch ? PC + {{14{imm16[15]}}, imm16, 2'b00} : PC4),
        .DI_10({PC[31:28], imm26, 2'b00}),
        .DI_11(regData),
        .DO(NPC)
    );
    
    assign NPC_Final = req  ? 32'h0000_4180 : 
                       eret ? EPC + 4:
                       NPC;

endmodule
