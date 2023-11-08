`timescale 1ns / 1ps
`include "Constants.v"

module mips(
    input clk,
    input reset
    );

    wire [31:0] instruction;
    wire [31:0] pc, pc4;
    
    wire [5:0]  opcode;
    wire [5:0]  func;
    wire [4:0]  rd_15_11;
    wire [4:0]  rt_20_16;
    wire [4:0]  rs_25_21;
    wire [4:0]  shamt;
    wire [15:0] imm16;
    wire [25:0] imm26;
    
    wire RegWriteEn, DmWriteEn, AluASel, AluBSel, ExtOp;
    wire [2:0]  AluOp;
    wire [1:0]  RegWriteSrc, RegWriteSel, NpcSel;
    
    wire [31:0] RegRD1, RegRD2, RegWD;
    wire [4:0]  RegRA1, RegRA2, RegWA;
    
    wire [31:0] DmAddr, DmRD, DmWD;
    
    wire        AluZero;
    wire [31:0] AluA, AluB, AluC;
    
    wire [31:0] ext32, shamt32;
    
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
    
    Decd u_decd(
        .Instr(instruction),
        .opCode(opcode),
        .func(func),
        .rd_15_11(rd_15_11),
        .rt_20_16(rt_20_16),
        .rs_25_21(rs_25_21),
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
    
    assign RegRA1 = rs_25_21;
    assign RegRA2 = rt_20_16;
    
    MUX5_4 u_mux_regwrite_reg(
        .Sel(RegWriteSel),
        .DI_00(rt_20_16),
        .DI_01(rd_15_11),
        .DI_10(5'h1f),
        .DO(RegWA)
    );
    
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

endmodule
