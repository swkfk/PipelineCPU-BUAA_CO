`timescale 1ns / 1ps

module mips(
    input clk,                    // 时钟信号
    input reset,                  // 同步复位信号
    input interrupt,              // 外部中断信号
    output [31:0] macroscopic_pc, // 宏观 PC

    output [31:0] i_inst_addr,    // IM 读取地址（取指 PC）
    input  [31:0] i_inst_rdata,   // IM 读取数据

    output [31:0] m_data_addr,    // DM 读写地址
    input  [31:0] m_data_rdata,   // DM 读取数据
    output [31:0] m_data_wdata,   // DM 待写入数据
    output [3 :0] m_data_byteen,  // DM 字节使能信号

    output [31:0] m_int_addr,     // 中断发生器待写入地址
    output [3 :0] m_int_byteen,   // 中断发生器字节使能信号

    output [31:0] m_inst_addr,    // M 级 PC

    output w_grf_we,              // GRF 写使能信号
    output [4 :0] w_grf_addr,     // GRF 待写入寄存器编号
    output [31:0] w_grf_wdata,    // GRF 待写入数据

    output [31:0] w_inst_addr     // W 级 PC
);

    // processor <-> bridge
    wire [31: 0] pb_addr, pb_wdata, pb_rdata, pb_pc;
    wire [ 3: 0] pb_byteen;
    
    // memory <-> bridge
    wire [31: 0] mb_addr, mb_wdata, mb_rdata, mb_pc;
    wire [ 3: 0] mb_byteen;
    
    // tc <-> bridge
    wire [31: 0] tb0_wdata, tb0_rdata, tb1_wdata, tb1_rdata;
    wire [31: 2] tb0_addr, tb1_addr;
    wire         tb0_we, tb1_we;
    
    // int <-> bridge
    wire [31: 0] ib_addr;
    wire [ 3: 0] ib_byteen;
    
    wire tc0_irq, tc1_irq;
    wire [5:0] HWInt = {3'b0, interrupt, tc1_irq, tc0_irq};

    assign macroscopic_pc = pb_pc;  // M_PC
    assign m_data_addr = mb_addr;
    assign m_data_rdata = mb_rdata;
    assign m_data_wdata = mb_wdata;
    assign m_data_byteen = mb_byteen;
    
    assign m_int_addr = ib_addr;
    assign m_int_byteen = ib_byteen;
    
    assign m_inst_addr = mb_pc;

    Processor u_processor(
        .clk  (clk),
        .reset(reset),
        .HWInt(HWInt),
        
        .i_inst_rdata(i_inst_rdata),
        .i_inst_addr (i_inst_addr),
        
        .m_data_rdata (pb_rdata),
        .m_data_addr  (pb_addr),
        .m_data_wdata (pb_wdata),
        .m_inst_addr  (pb_pc),
        .m_data_byteen(pb_byteen),
        
        .w_grf_we   (w_grf_we),
        .w_grf_addr (w_grf_addr),
        .w_grf_wdata(w_grf_wdata),
        .w_inst_addr(w_inst_addr)
    );
    
    Bridge u_bridge(
        .p_addr  (pb_addr),
        .p_byteen(pb_byteen),
        .p_wdata (pb_wdata),
        .p_rdata (pb_rdata),
        .p_pc    (pb_pc),
        
        .m_addr  (mb_addr),
        .m_rdata (mb_rdata),
        .m_wdata (mb_wdata),
        .m_byteen(mb_byteen),
        .m_pc    (mb_pc),
        
        .tc0_addr (tb0_addr),
        .tc0_we   (tb0_we),
        .tc0_wdata(tb0_wdata),
        .tc0_rdata(tb0_rdata),
        .tc1_addr (tb1_addr),
        .tc1_we   (tb1_we),
        .tc1_wdata(tb1_wdata),
        .tc1_rdata(tb1_rdata),
        
        .int_addr  (ib_addr),
        .int_byteen(ib_byteen)
    );
    
    TC u_tc0(
        .clk  (clk),
        .reset(reset),
        .Addr (tb0_addr),
        .WE   (tb0_we),
        .Din  (tb0_wdata),
        .Dout (tb0_rdata),
        .IRQ  (tc0_irq)
    );
    
    TC u_tc1(
        .clk  (clk),
        .reset(reset),
        .Addr (tb1_addr),
        .WE   (tb1_we),
        .Din  (tb1_wdata),
        .Dout (tb1_rdata),
        .IRQ  (tc1_irq)
    );

endmodule
