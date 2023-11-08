`timescale 1ns / 1ps
`include "Constants.v"

module Controller(
    input [5:0] opCode,
    input [5:0] func,
    output RegWriteEn,
    output [1:0] RegWriteSrc,
    output [1:0] RegWriteSel,
    output AluASel,
    output AluBSel,
    output [2:0] AluOp,
    output ExtOp,
    output DmWriteEn,
    output [1:0] NpcSel
    );

    wire add, sub, ori, lw, sw, beq, lui, jal, jr, sll;
    wire special;
    
    assign special = ~(|opCode);
    
    assign add = (special && func == `ADD);
    assign sub = (special && func == `SUB);
    assign sll = (special && func == `SLL);
    assign ori = (opCode == `ORI);
    assign lui = (opCode == `LUI);
    assign beq = (opCode == `BEQ);
    assign lw  = (opCode == `LW);
    assign sw  = (opCode == `SW);
    assign jal = (opCode == `JAL);
    assign jr  = (special && func == `JR);

    assign RegWriteEn = (add | sub | sll | ori | lw | jal | lui);
    assign RegWriteSrc[0] = lw;
    assign RegWriteSrc[1] = jal;
    assign RegWriteSel[0] = (add | sub | sll);
    assign RegWriteSel[1] = jal;
    assign AluASel = sll;
    assign AluBSel = (ori | lui | lw | sw);
    assign ExtOp = (lw | sw);
    assign DmWriteEn = sw;
    assign NpcSel[0] = (beq | jr);
    assign NpcSel[1] = (jal | jr);

    assign AluOp[0] = (lui | beq | sub);
    assign AluOp[1] = (lui | ori);
    assign AluOp[2] = sll;

endmodule
