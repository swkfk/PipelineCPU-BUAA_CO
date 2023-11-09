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
    output [1:0] NpcSel,
    output [2:0] BType,
    output [1:0] InstrType,
    output [2:0] TuseRS,
    output [2:0] TuseRT
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

    assign BType = beq ? `Br_BEQ : 3'b000;
    assign InstrType = (add | sub | ori | lui | sll) ? `CalcType : 
                       (lw) ? `LoadType :
                       (beq | jr) ? `JumpType :
                       2'b0;
    assign TuseRS = (add | sub | ori | lui | lw | sw) ? 3'd1 :
                    (beq | jr) ? 3'd0 :
                    3'd3;
    assign TuseRT = (add | sub | sll) ? 3'd1 :
                    (beq) ? 3'd0 :
                    (sw)  ? 3'd2 :
                    3'd3;

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
