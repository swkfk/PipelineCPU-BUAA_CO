`timescale 1ns / 1ps
`include "Constants.v"
`include "Exc_Consts.v"
`include "CP0_Consts.v"

module Processor(
    input clk,
    input reset,
    input [5:0] HWInt,
    input [31:0] i_inst_rdata,
    input [31:0] m_data_rdata,
    output [31:0] i_inst_addr,
    output [31:0] m_data_addr,
    output [31:0] m_data_wdata,
    output [3 :0] m_data_byteen,
    output [31:0] m_inst_addr,
    output w_grf_we,
    output [4:0] w_grf_addr,
    output [31:0] w_grf_wdata,
    output [31:0] w_inst_addr
);
    
    wire stall, req;
    
    StallCtrl u_stall(
        .Type$E(type$E),
        .Type$M(type$M),
        .A1$D(RegRA1),
        .A2$D(RegRA2),
        .A3$E(A3$E),
        .A3$M(A3$M),
        .WE$E(RegWriteEn$E),
        .WE$M(RegWriteEn$M),
        .TuseRS(TuseRS),
        .TuseRT(TuseRT),
        .stall(stall),
        .mdu_busy(MduBusy || MduStart$E),
        .hilo(MduHiLo),
        .eret$D(eret$D),
        .mt_epc$E(cop0_wr$E && rd$E == `RegEPC),
        .mt_epc$M(cop0_wr$M && rd$M == `RegEPC)
    );
    
    wire [31:0] EPC;
    wire eret$D;
    wire ExcAdEL$F;
    
    wire [ 4:0] ExcCode$F = ExcAdEL$F ? `EXC_AdEL : `EXC_None;

    wire [31:0] instruction = ExcAdEL$F ? 32'b0 : i_inst_rdata;
    wire [31:0] pc, pc8;
    
    assign i_inst_addr = pc;
    
    IFU u_ifu(
        .clk(clk),
        .reset(reset),
        .npcOp(NpcSel),
        .imm16(imm16),  // imm16 @D
        .imm26(imm26),  // imm26 @D
        .regData(RegRD1$FWD),  // RD1 @D
        .branch(b_jump),  // branch @D
        .PC(pc),
        .PC8(pc8),
        .En(!stall),
        
        .EPC(EPC),
        .req(req),
        .eret(eret$D),
        .ExcAdEL(ExcAdEL$F)
    );
    
    wire inst_in_bd$F;

    /*** vvv D Stage Registers vvv ***/
    wire [31:0] instruction$D;
    wire [31:0] PC$D, PC8$D;
    wire inst_in_bd$D;
    wire Stall$D = stall;
    wire Clear$D = reset || req;
    wire [ 4:0] ExcCode$F$D;
    
    PReg u_instr$D (clk, Stall$D, Clear$D, instruction, instruction$D);
    PRegPC u_PC$D    (clk, Stall$D, Clear$D, req, pc, PC$D);
    PReg u_PC8$D   (clk, Stall$D, Clear$D, pc8, PC8$D);
    PReg #(.Width(1)) u_bd$D (clk, Stall$D, Clear$D, inst_in_bd$F, inst_in_bd$D);
    PReg #(.Width(5)) u_exccode$D (clk, Stall$D, Clear$D, ExcCode$F, ExcCode$F$D);
    /*** ^^^ D Stage Registers ^^^ ***/
    
    wire [5:0]  opcode, func;
    wire [4:0]  rd, rt, rs, shamt;
    wire [15:0] imm16;
    wire [25:0] imm26;
    
    wire [1:0] type;
    wire [2:0] TuseRS, TuseRT;
    
    wire RegWriteEn, DmWriteEn, AluASel, AluBSel, ExtOp;
    wire [3:0]  AluOp;
    wire [1:0]  RegWriteSrc, RegWriteSel, NpcSel;
    
    Decd u_decd(
        .Instr(instruction$D),
        .opCode(opcode),
        .func(func),
        .rd_15_11(rd),
        .rt_20_16(rt),
        .rs_25_21(rs),
        .shamt(shamt),
        .imm16(imm16),
        .imm26(imm26)
    );
     
    wire [2:0] BrType, DmAcessType;
    wire [3:0] MDType;
    wire MduStart, MduBusy, MduHiLo;
    
    wire ExcRI$D, ExcSyscall$D, cop0_wr$D, FromCP0$D;
    wire AllowExcOv$D, AllowExcDm$D;
    
    wire [ 4:0] ExcCode$D = ExcCode$F$D != `EXC_None ? ExcCode$F$D :
                            ExcRI$D ? `EXC_RI :
                            ExcSyscall$D ? `EXC_Syscall : `EXC_None;
    
    Controller u_ctrl(
        .opCode(opcode),
        .func(func),
        .cop0_code(rs),
        .RegWriteEn(RegWriteEn),
        .RegWriteSrc(RegWriteSrc),
        .RegWriteSel(RegWriteSel),
        .AluASel(AluASel),
        .AluBSel(AluBSel),
        .AluOp(AluOp),
        .ExtOp(ExtOp),
        .DmWriteEn(DmWriteEn),
        .DmAcessType(DmAcessType),
        .NpcSel(NpcSel),
        .BType(BrType),
        .InstrType(type),
        .TuseRS(TuseRS),
        .TuseRT(TuseRT),
        .MduStart(MduStart),
        .MDUType(MDType),
        .ExcRI(ExcRI$D),
        .ExcSyscall(ExcSyscall$D),
        .isEret(eret$D),
        .CP0Wr(cop0_wr$D),
        .AllowExcOv(AllowExcOv$D),
        .AllowExcDm(AllowExcDm$D),
        .NeedBd(inst_in_bd$F),
        .FromCP0(FromCP0$D)
    );

    assign MduHiLo = MDType == `MDU_MFHI || MDType == `MDU_MFLO || MDType == `MDU_MTHI || MDType == `MDU_MTLO;
    
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
    
    wire [31:0] RegRD1, RegRD2;
    wire [31:0] RegRD1$FWD, RegRD2$FWD;
    wire [4:0]  RegRA1, RegRA2, RegWA;
    
    /*** vvv Forward: D Stage vvv ***/
    assign RegRD1$FWD = (RegRA1 == A3$E && A3$E && RegWriteEn$E && RegWriteSrc$E == `REGWr_PC4) ? PC8$E :
                        (RegRA1 == A3$M && A3$M && RegWriteEn$M && RegWriteSrc$M == `REGWr_Alu) ? AO$M :
                        (RegRA1 == A3$M && A3$M && RegWriteEn$M && RegWriteSrc$M == `REGWr_PC4) ? PC8$M :
                        (RegRA1 == A3$M && A3$M && RegWriteEn$M && RegWriteSrc$M == `REGWr_HiLo) ? MDO$M :
                        (RegRA1 == A3$W && A3$W && RegWriteEn$W) ? WD$_W :
                        RegRD1;
    assign RegRD2$FWD = (RegRA2 == A3$E && A3$E && RegWriteEn$E && RegWriteSrc$E == `REGWr_PC4) ? PC8$E :
                        (RegRA2 == A3$M && A3$M && RegWriteEn$M && RegWriteSrc$M == `REGWr_Alu) ? AO$M :
                        (RegRA2 == A3$M && A3$M && RegWriteEn$M && RegWriteSrc$M == `REGWr_PC4) ? PC8$M :
                        (RegRA2 == A3$M && A3$M && RegWriteEn$M && RegWriteSrc$M == `REGWr_HiLo) ? MDO$M :
                        (RegRA2 == A3$W && A3$W && RegWriteEn$W) ? WD$_W :
                        RegRD2;
    /*** ^^^ Forward: D Stage ^^^ ***/
    
    GRF u_grf(
        .clk(clk),
        .reset(reset),
        .A1(RegRA1),
        .A2(RegRA2),
        .A3(A3$W),  // Write back
        .WD(WD$_W),  // Write back
        .WrEn(RegWriteEn$W),  // Write back
        .RD1(RegRD1),
        .RD2(RegRD2)
    );
    
    assign w_grf_we = RegWriteEn$W;
    assign w_grf_addr = A3$W;
    assign w_grf_wdata = WD$_W;
    assign w_inst_addr = PC$W;
    
    wire b_jump;
    
    CMP u_cmp (.RD1(RegRD1$FWD), .RD2(RegRD2$FWD), .BType(BrType), .b_jump(b_jump));
    
    /*** vvv E Stage Registers vvv ***/
    wire [31:0] V1$E, V2$E, E32$E, S32$E;  // S32: Shamt 32
    wire [4:0]  A1$E, A2$E, A3$E, rd$E;
    wire [31:0] PC$E, PC8$E, MDO$E;
    
    wire AluASel$E, AluBSel$E, DmWriteEn$E, MduStart$E;
    wire [3:0] AluOp$E, MDType$E;
    wire [1:0] RegWriteSrc$E;
    // wire [15:0] I16$E;
    
    wire [ 4:0] ExcCode$D$E;
    wire inst_in_bd$E, eret$E, cop0_wr$E, FromCP0$E;
    
    wire AllowExcOv$E, AllowExcDm$E;
    
    wire [1:0] type$E;
    
    wire [2:0] DmAcessType$E;
    
    wire Stall$E = 1'b0;
    wire Clear$E = stall || reset || req;
    
    PReg u_v1$E  (clk, Stall$E, Clear$E, RegRD1$FWD, V1$E);
    PReg u_v2$E  (clk, Stall$E, Clear$E, RegRD2$FWD, V2$E);
    PReg u_e32$E (clk, Stall$E, Clear$E, ext32, E32$E);
    PReg u_s32$E (clk, Stall$E, Clear$E, shamt32, S32$E);
    PReg #(.Width(5)) u_a1$E (clk, Stall$E, Clear$E, RegRA1, A1$E);
    PReg #(.Width(5)) u_a2$E (clk, Stall$E, Clear$E, RegRA2, A2$E);
    PReg #(.Width(5)) u_a3$E (clk, Stall$E, Clear$E, RegWA, A3$E);
    PReg #(.Width(5)) u_rd$E (clk, Stall$E, Clear$E, rd, rd$E);
    PRegPC u_pc$E  (clk, Stall$E, reset || req, req, PC$D,  PC$E);  // Special Twice!!!
    PReg u_pc8$E (clk, Stall$E, Clear$E, PC8$D, PC8$E);
    // PReg #(.Width(16)) u_i16$E (clk, Stall$E, Clear$E, imm16, I16$E);
    PReg #(.Width(1)) u_aluasel$E (clk, Stall$E, Clear$E, AluASel, AluASel$E);
    PReg #(.Width(1)) u_alubsel$E (clk, Stall$E, Clear$E, AluBSel, AluBSel$E);
    PReg #(.Width(1)) u_mdu_start$E (clk, Stall$E, Clear$E, MduStart, MduStart$E);
    PReg #(.Width(4)) u_mdu_type$E (clk, Stall$E, Clear$E, MDType, MDType$E);
    PReg #(.Width(4)) u_aluop$E   (clk, Stall$E, Clear$E, AluOp, AluOp$E);
    PReg #(.Width(1)) u_dmwe$E (clk, Stall$E, Clear$E, DmWriteEn, DmWriteEn$E);
    PReg #(.Width(3)) u_dmtype$E (clk, Stall$E, Clear$E, DmAcessType, DmAcessType$E);
    PReg #(.Width(1)) u_rfwe$E (clk, Stall$E, Clear$E, RegWriteEn, RegWriteEn$E);
    PReg #(.Width(2)) u_rfws$E (clk, Stall$E, Clear$E, RegWriteSrc, RegWriteSrc$E);
    PReg #(.Width(2)) u_type$E (clk, Stall$E, Clear$E, type, type$E);
    PReg #(.Width(1)) u_allow_ov$E(clk, Stall$E, Clear$E, AllowExcOv$D, AllowExcOv$E);
    PReg #(.Width(1)) u_allow_dm$E(clk, Stall$E, Clear$E, AllowExcDm$D, AllowExcDm$E);
    PReg #(.Width(5)) u_exccode$E (clk, Stall$E, Clear$E, ExcCode$D, ExcCode$D$E);
    PReg #(.Width(1)) u_inst_bd$E (clk, Stall$E, reset || req, inst_in_bd$D, inst_in_bd$E);  // Specilal!!!
    PReg #(.Width(1)) u_eret$E (clk, Stall$E, Clear$E, eret$D, eret$E);
    PReg #(.Width(1)) u_cop0_wr$E (clk, Stall$E, Clear$E, cop0_wr$D, cop0_wr$E);
    PReg #(.Width(1)) u_from_cp0$E (clk, Stall$E, Clear$E, FromCP0$D, FromCP0$E);
    /*** ^^^ E Stage Registers ^^^ ***/

    wire        AluZero;
    wire [31:0] AluA, AluB, AluC, MDOut;
    
    /*** vvv Forward: E Stage vvv ***/
    wire [31:0] V1$E$FWD, V2$E$FWD;
    assign V1$E$FWD = (A1$E == A3$M && A3$M && RegWriteEn$M && RegWriteSrc$M == `REGWr_Alu) ? AO$M :
                      (A1$E == A3$M && A3$M && RegWriteEn$M && RegWriteSrc$M == `REGWr_PC4) ? PC8$M :
                      (A1$E == A3$M && A3$M && RegWriteEn$M && RegWriteSrc$M == `REGWr_HiLo) ? MDO$M :
                      (A1$E == A3$W && A3$W && RegWriteEn$W) ? WD$_W :
                      V1$E;
    assign V2$E$FWD = (A2$E == A3$M && A3$M && RegWriteEn$M && RegWriteSrc$M == `REGWr_Alu) ? AO$M :
                      (A2$E == A3$M && A3$M && RegWriteEn$M && RegWriteSrc$M == `REGWr_PC4) ? PC8$M :
                      (A2$E == A3$M && A3$M && RegWriteEn$M && RegWriteSrc$M == `REGWr_HiLo) ? MDO$M :
                      (A2$E == A3$W && A3$W && RegWriteEn$W) ? WD$_W :
                      V2$E;
    /*** ^^^ Forward: E Stage ^^^ ***/
    
    wire ExcOv$E, ExcDm$E, ExcAdEL$E, ExcAdES$E;
    
    MUX32_2 u_mux_alu_a(
        .Sel(AluASel$E),
        .DI_0(V1$E$FWD),
        .DI_1(S32$E),
        .DO(AluA)
    );
    
    MUX32_2 u_mux_alu_b(
        .Sel(AluBSel$E),
        .DI_0(V2$E$FWD),
        .DI_1(E32$E),
        .DO(AluB)
    );
    
    ALU u_alu(
        .A(AluA),
        .B(AluB),
        .AluOp(AluOp$E),
        .C(AluC),
        .Zero(AluZero),
        .AllowExcOv(AllowExcOv$E),
        .AllowExcDm(AllowExcDm$E),
        .ExcOv(ExcOv$E),
        .ExcDm(ExcDm$E)
    );
    
    MDU u_mdu(
        .clk(clk),
        .reset(reset),
        .start(MduStart$E),
        .req(req),
        .RS(V1$E$FWD),
        .RT(V2$E$FWD),
        .MDType(MDType$E),
        .busy(MduBusy),
        .MDOut(MDOut)
    );
    
    DmExcDetector u_dmexc(
        .ExcFromAlu(ExcDm$E),
        .DmAccessType(DmAcessType$E),
        .DmAddress(AluC),
        .ExcAdEL(ExcAdEL$E),
        .ExcAdES(ExcAdES$E)
    );
    
    wire [ 4:0] ExcCode$E = ExcCode$D$E != `EXC_None ? ExcCode$D$E:
                            ExcOv$E ? `EXC_Ov :
                            ExcAdEL$E ? `EXC_AdEL :
                            ExcAdES$E ? `EXC_AdES : `EXC_None;
    
    /*** vvv M Stage Registers vvv ***/
    wire [31:0] AO$M, V2$M;
    wire [4:0]  A3$M, A2$M, rd$M;
    wire [31:0] PC$M, PC8$M, MDO$M;
    
    wire DmWriteEn$M, RegWriteEn$M;
    wire [2:0] DmAccessType$M;
    wire [1:0] RegWriteSrc$M;
    wire [1:0] type$M;
    
    wire Stall$M = 1'b0;
    wire Clear$M = reset || req;
    
    wire [ 4:0] ExcCode$E$M;
    wire inst_in_bd$M, eret$M, FromCP0$M, cop0_wr$M;
    
    PReg u_ao$M (clk, Stall$M, Clear$M, AluC, AO$M);
    PReg #(.Width(5)) u_a3$M (clk, Stall$M, Clear$M, A3$E, A3$M);
    PReg u_v2$M (clk, Stall$M, Clear$M, V2$E$FWD, V2$M);
    PReg #(.Width(5)) u_a2$M (clk, Stall$M, Clear$M, A2$E, A2$M);
    PReg #(.Width(5)) u_rd$M (clk, Stall$M, Clear$M, rd$E, rd$M);
    PRegPC u_pc$M  (clk, Stall$M, Clear$M, req, PC$E,  PC$M);
    PReg u_pc8$M (clk, Stall$M, Clear$M, PC8$E, PC8$M);
    PReg u_mdo$M (clk, Stall$M, Clear$M, MDOut, MDO$M);
    PReg #(.Width(1)) u_dmwe$M (clk, Stall$M, Clear$M, DmWriteEn$E, DmWriteEn$M);
    PReg #(.Width(3)) u_dmtype$M (clk, Stall$M, Clear$M, DmAcessType$E, DmAccessType$M);
    PReg #(.Width(1)) u_rfwe$M (clk, Stall$M, Clear$M, RegWriteEn$E, RegWriteEn$M);
    PReg #(.Width(2)) u_rfws$M (clk, Stall$M, Clear$M, RegWriteSrc$E, RegWriteSrc$M);
    PReg #(.Width(2)) u_type$M (clk, Stall$M, Clear$M, type$E, type$M);
    PReg #(.Width(5)) u_exccode$M (clk, Stall$M, Clear$M, ExcCode$E, ExcCode$E$M);
    PReg #(.Width(1)) u_inst_bd$M (clk, Stall$M, Clear$M, inst_in_bd$E, inst_in_bd$M);
    PReg #(.Width(1)) u_eret$M (clk, Stall$M, Clear$M, eret$E, eret$M);
    PReg #(.Width(1)) u_cop0_wr$M (clk, Stall$M, Clear$M, cop0_wr$E, cop0_wr$M);
    PReg #(.Width(1)) u_from_cp0$M (clk, Stall$M, Clear$M, FromCP0$E, FromCP0$M);
    /*** ^^^ M Stage Registers ^^^ ***/
    
    wire [31:0] DmAddr, DmRD, DmWD, DmWD$FWD, COP0_Out;

    assign DmAddr = AO$M;
    assign DmWD = V2$M;
   
    assign DmWD$FWD = (A2$M == A3$W && A3$W && RegWriteEn$W) ? WD$_W : DmWD;
    
    CP0 u_cp0(
        .clk(clk),
        .rst(reset),
        .A1(rd$M),
        .A2(rd$M),
        .DIn(DmWD$FWD),
        .PC(PC$M),
        .ExcInBd(inst_in_bd$M),
        .ExcCode(ExcCode$E$M),
        .HWInt(HWInt),
        .We(cop0_wr$M),
        // .EXLSet(),
        .EXLClr(eret$M),
        .Req(req),
        .EPCout(EPC),
        .DOut(COP0_Out)
    );
    
    
    /*** vvv Data Memory vvv ***/
    
    BE u_be(
        .data_w_in(DmWD$FWD),
        .addr_low(DmAddr[1:0]),
        .write_type(DmAccessType$M),
        .data_w_out(m_data_wdata),
        .data_w_byteen(m_data_byteen),
        .req(req)
    );
    
    DmRDExt u_data_extender(
        .data_read_in(m_data_rdata),
        .read_type(DmAccessType$M),
        .addr_low(DmAddr[1:0]),
        .data_read_out(DmRD)
    );
    
    assign m_data_addr = DmAddr;
    assign m_inst_addr = PC$M;
    /*** ^^^ Data Memory ^^^ ***/
    
    /*** vvv W Stage Registers vvv ***/
    wire [31:0] AO$W, DR$W;
    wire [4:0]  A3$W;
    wire [31:0] PC$W, PC8$W, MDO$W, COP0$W;
    
    wire FromCP0$W;
    
    wire Stall$W = 1'b0;
    wire Clear$W = reset || req;
    
    wire RegWriteEn$W;
    wire [1:0] RegWriteSrc$W;
    
    PReg u_ao$W  (clk, Stall$W, Clear$W, AO$M, AO$W);
    PReg #(.Width(5)) u_a3$W (clk, Stall$W, Clear$W, A3$M, A3$W);
    PReg u_dr$W  (clk, Stall$W, Clear$W, DmRD, DR$W);
    PReg u_pc$W  (clk, Stall$W, Clear$W, PC$M,  PC$W);
    PReg u_pc8$W (clk, Stall$W, Clear$W, PC8$M, PC8$W);
    PReg u_mdo$W (clk, Stall$W, Clear$W, MDO$M, MDO$W);
    PReg #(.Width(1)) u_rfwe$W (clk, Stall$W, Clear$W, RegWriteEn$M, RegWriteEn$W);
    PReg #(.Width(2)) u_rfws$W (clk, Stall$W, Clear$W, RegWriteSrc$M, RegWriteSrc$W);
    PReg u_cop0  (clk, Stall$W, Clear$W, COP0_Out, COP0$W);
    PReg #(.Width(1)) u_from_cp0$W (clk, Stall$W, Clear$W, FromCP0$M, FromCP0$W);
    /*** ^^^ W Stage Registers ^^^ ***/

    wire [31:0] WD$_W, TMP_WD$_W;

    MUX32_4 u_mux_regwrite_src(
        .Sel(RegWriteSrc$W),
        .DI_00(AO$W),
        .DI_01(DR$W),
        .DI_10(PC8$W),
        .DI_11(MDO$W),
        .DO(TMP_WD$_W)
    );

    MUX32_2 u_mux_regwrite_level2_src(
        .Sel(FromCP0$W),
        .DI_0(TMP_WD$_W),
        .DI_1(COP0$W),
        .DO(WD$_W)
    );

endmodule
