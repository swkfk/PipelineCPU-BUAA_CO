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

    wire add, sub, _and, _or, slt, sltu, lui;
    wire addi, andi, ori;
    wire lb, lh, lw, sb, sh, sw;
    wire mult, multu, div, divu, mfhi, mflo, mthi, mtlo;
    wire beq, bne, jal, jr;
    
    wire special;
    
    assign special = ~(|opCode);
    
    assign add = (special && func == `ADD);
    assign sub = (special && func == `SUB);
    assign _and = (special && func == `AND);
    assign _or =  (special && func == `OR);
    assign slt = (special && func == `SLT);
    assign sltu = (special && func == `SLTU);
    assign lui = (opCode == `LUI);
    
    assign addi = (opCode == `ADDI);
    assign andi = (opCode == `ANDI);
    assign ori = (opCode == `ORI);
    
    assign lb = (opCode == `LB);
    assign lh  = (opCode == `LH);
    assign lw  = (opCode == `LW);
    assign sb = (opCode == `SB);
    assign sh  = (opCode == `SH);
    assign sw  = (opCode == `SW);
    
    assign sll = (special && func == `SLL);

    assign mult = (special && func == `MULT);
    assign multu = (special && func == `MULTU);
    assign div = (special && func == `DIV);
    assign divu = (special && func == `DIVU);
    assign mfhi = (special && func == `MFHI);
    assign mflo = (special && func == `MFLO);
    assign mthi = (special && func == `MTHI);
    assign mtlo = (special && func == `MTLO);

    assign beq = (opCode == `BEQ);
    assign bne = (opCode == `BNE);
    assign jal = (opCode == `JAL);
    assign jr  = (special && func == `JR);

    assign BType = beq ? `Br_BEQ :
                   bne ? `Br_BNE :
                   3'b000;
    assign InstrType = (add | sub | lui | sll | _and | _or | slt | sltu | addi | andi | ori) ? `CalcType : 
                       (lw | lh | lb) ? `LoadType :
                       (beq | jr | bne) ? `JumpType :
                       2'b0;
    assign TuseRS = (add | sub | ori | lui | _and | _or | slt | sltu | addi | andi | lw | lh | lb | sw | sh | sb) ? 3'd1 :
                    (beq | jr | bne) ? 3'd0 :
                    3'd3;
    assign TuseRT = (add | sub | sll | _and | _or | slt | sltu) ? 3'd1 :
                    (beq | bne) ? 3'd0 :
                    (sw | sh | sb)  ? 3'd2 :
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
