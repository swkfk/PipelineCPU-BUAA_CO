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
    output [3:0] AluOp,
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

    wire calc_rr = add | sub | _and | _or | slt | sltu;
    wire calc_ri = addi | andi | ori;  // | lui
    wire load    = lw | lh | lb;
    wire store   = sw | sh | sb;

    assign BType = beq ? `Br_BEQ :
                   bne ? `Br_BNE :
                   3'b000;
    assign InstrType = (calc_rr | calc_ri | lui | sll) ? `CalcType : 
                       (load) ? `LoadType :
                       (beq | jr | bne) ? `JumpType :
                       2'b0;
    assign TuseRS = (calc_ri | calc_rr | lui | load | store) ? 3'd1 :
                    (beq | jr | bne) ? 3'd0 :
                    3'd3;
    assign TuseRT = (calc_rr | sll) ? 3'd1 :
                    (beq | bne) ? 3'd0 :
                    (store)  ? 3'd2 :
                    3'd3;

    assign RegWriteEn = (calc_rr | calc_ri | lui | sll | load | jal);
    assign RegWriteSrc[0] = load;
    assign RegWriteSrc[1] = jal;
    assign RegWriteSel[0] = (calc_rr | sll);
    assign RegWriteSel[1] = jal;
    assign AluASel = sll;
    assign AluBSel = (calc_ri | load | store | lui);
    assign ExtOp = (load | store | addi);
    assign DmWriteEn = store;
    assign NpcSel[0] = (bne | beq | jr);
    assign NpcSel[1] = (jal | jr);

    assign AluOp[0] = (lui | sub | _and | sltu | andi);
    assign AluOp[1] = (lui | ori | _or | slt | sltu);
    assign AluOp[2] = (sll | _and | slt | sltu | andi);
    assign AluOp[3] = 1'b0;

endmodule
