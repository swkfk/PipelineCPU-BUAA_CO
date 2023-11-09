`timescale 1ns / 1ps
`include "Constants.v"

module mips(
    input clk,
    input reset
    );

    wire [31:0] instruction;
    wire [31:0] pc, pc4;
    
    wire [31:0] DmAddr, DmRD, DmWD;
    
    IFU u_ifu(
        .clk(clk),
        .reset(reset),
        .npcOp(NpcSel),
        .imm16(imm16),
        .imm26(imm26),
        .regData(RegRD1),
        .zero(AluZero),
        .PC(pc),
        .PC4(pc4),
        .Instr(instruction)
    );
    
    /*** vvv D Stage Registers vvv ***/
    wire [31:0] instruction$D;
    wire [31:0] PC4$D;
    wire Stall$D, Clear$D;
    
    PReg u_instr$D (clk, Stall$D, Clear$D, instruction, instruction$D);
    PReg u_PC4$D   (clk, Stall$D, Clear$D, pc4, PC4$D);
    /*** ^^^ D Stage Registers ^^^ ***/
    
    wire [5:0]  opcode, func;
    wire [4:0]  rd, rt, rs, shamt;
    wire [15:0] imm16;
    wire [25:0] imm26;
    
    wire RegWriteEn, DmWriteEn, AluASel, AluBSel, ExtOp;
    wire [2:0]  AluOp;
    wire [1:0]  RegWriteSrc, RegWriteSel, NpcSel;
    
    Decd u_decd(
        .Instr(instruction$D),
        .opCode(opcode),
        .func(func),
        .rd(rd),
        .rt(rt),
        .rs(rs),
        .shamt(shamt),
        .imm16(imm16),
        .imm26(imm26)
    );
    
    Controller u_ctrl(
        .opCode(opcode),
        .func(func),
        .RegWriteEn(RegWriteEn),
        .RegWriteSrc(RegWriteSrc),
        .RegWriteSel(RegWriteSel),
        .AluASel(AluASel),
        .AluBSel(AluBSel),
        .AluOp(AluOp),
        .ExtOp(ExtOp),
        .DmWriteEn(DmWriteEn),
        .NpcSel(NpcSel)
    );
    
    MUX32_4 u_mux_regwrite_src(
        .Sel(RegWriteSrc),
        .DI_00(AluC),
        .DI_01(DmRD),
        .DI_10(pc4),
        .DO(RegWD)
    );
    
    wire [31:0] ext32, shamt32;
    
    EXT u_ext(
        .imm16(imm16),
        .ExtOp(ExtOp),
        .ext32(ext32)
    );
    
    EXT u_ext_shamt(
        .imm16({ 11'b0, shamt }),
        .ExtOp(`EXT_Zero),
        .ext32(shamt32)
    );
    
    assign RegRA1 = rs;
    assign RegRA2 = rt;
    
    MUX5_4 u_mux_regwrite_reg(
        .Sel(RegWriteSel),
        .DI_00(rt),
        .DI_01(rd),
        .DI_10(5'h1f),
        .DO(RegWA)
    );
    
    wire [31:0] RegRD1, RegRD2, RegWD;
    wire [4:0]  RegRA1, RegRA2, RegWA;
    
    GRF u_grf(
        .clk(clk),
        .reset(reset),
        .A1(RegRA1),
        .A2(RegRA2),
        .A3(RegWA),
        .WD(RegWD),
        .WrEn(RegWriteEn),
        .RD1(RegRD1),
        .RD2(RegRD2),
        .PC(pc)
    );
    
    /*** vvv E Stage Registers vvv ***/
    wire [31:0] V1$E, V2$E, E32$E, S32$E;  // S32: Shamt 32
    wire [4:0]  A2$E, A3$E;
    wire [31:0] PC4$E;
    // wire [15:0] I16$E;
    
    wire Stall$E, Clear$E;
    
    PReg u_v1$E  (clk, Stall$E, Clear$E, RegRD1, V1$E);
    PReg u_v2$E  (clk, Stall$E, Clear$E, RegRD2, V2$E);
    PReg u_e32$E (clk, Stall$E, Clear$E, ext32, E32$E);
    PReg u_s32$E (clk, Stall$E, Clear$E, shamt32, S32$E);
    PReg #(.Width(5)) u_a2$E (clk, Stall$E, Clear$E, RegRA2, A2$E);
    PReg #(.Width(5)) u_a3$E (clk, Stall$E, Clear$E, RegWA, A3$E);
    PReg u_pc4$E (clk, Stall$E, Clear$E, PC4$D, PC4$E);
    // PReg #(.Width(16)) u_i16$E (clk, Stall$E, Clear$E, imm16, I16$E);
    /*** ^^^ E Stage Registers ^^^ ***/

    wire        AluZero;
    wire [31:0] AluA, AluB, AluC;
    
    MUX32_2 u_mux_alu_a(
        .Sel(AluASel),
        .DI_0(RegRD1),
        .DI_1(shamt32),
        .DO(AluA)
    );
    
    MUX32_2 u_mux_alu_b(
        .Sel(AluBSel),
        .DI_0(RegRD2),
        .DI_1(ext32),
        .DO(AluB)
    );
    
    ALU u_alu(
        .A(AluA),
        .B(AluB),
        .AluOp(AluOp),
        .C(AluC),
        .Zero(AluZero)
    );
    
    /*** vvv M Stage Registers vvv ***/
    wire [31:0] AO$M, V2$M;
    wire [4:0]  A3$M, A2$M;
    wire [31:0] PC4$M;
    
    wire Stall$M, Clear$M;
    
    PReg u_ao$M (clk, Stall$M, Clear$M, AluC, AO$M);
    PReg #(.Width(5)) u_a3$M (clk, Stall$M, Clear$M, A3$E, A3$M);
    PReg u_v2$M (clk, Stall$M, Clear$M, V2$E, V2$M);
    PReg #(.Width(5)) u_a2$M (clk, Stall$M, Clear$M, A2$E, A2$M);
    PReg u_pc4$M (clk, Stall$M, Clear$M, PC4$E, PC4$M);
    /*** ^^^ M Stage Registers ^^^ ***/
    
    assign DmAddr = AluC;
    assign DmWD = RegRD2;
    
    DM u_dm(
        .clk(clk),
        .reset(reset),
        .WAddr(DmAddr),
        .WData(DmWD),
        .WrEn(DmWriteEn),
        .RD(DmRD),
        .PC(pc)
    );
    
    /*** vvv W Stage Registers vvv ***/
    wire [31:0] AO$W, DR$W;
    wire [4:0]  A3$W;
    wire [31:0] PC4$W;
    
    wire Stall$W, Clear$W;
    
    PReg u_ao$W  (clk, Stall$W, Clear$W, AO$M, AO$W);
    PReg #(.Width(5)) u_a3$W (clk, STall$W, Clear$W, A3$M, A3$W);
    PReg u_dr$W  (clk, Stall$W, Clear$W, DmRD, DR$W);
    PReg u_pc4$W (clk, Stall$W, Clear$W, PC4$M, PC4$W);
    /*** ^^^ W Stage Registers ^^^ ***/

endmodule
