`timescale 1ns / 1ps
`include "Bridge_Consts.v"
`include "Exc_Consts.v"

module Bridge(
    // For Processor
    input  [31: 0] p_addr,
    input  [ 3: 0] p_byteen,
    input  [31: 0] p_wdata,
    output [31: 0] p_rdata,
    input  [31: 0] p_pc,
    // For DM
    output [31: 0] m_addr,
    input  [31: 0] m_rdata,
    output [31: 0] m_wdata,
    output [31: 0] m_byteen,
    output [31: 0] m_pc,
    // For TC0 & TC1
    output [31: 2] tc0_addr,
    output         tc0_we,
    output [31: 0] tc0_wdata,
    input  [31: 0] tc0_rdata,
    output [31: 2] tc1_addr,
    output         tc1_we,
    output [31: 0] tc1_wdata,
    input  [31: 0] tc1_rdata,
    // For Interrupt
    output [31: 0] int_addr,
    output [ 3: 0] int_byteen
    );
    
    wire _dm  = p_addr >= `DM_LOW_BOUND  && p_addr <= `DM_HIGH_BOUND;
    wire _tc0 = p_addr >= `TC0_LOW_BOUND && p_addr <= `TC0_HIGH_BOUND;
    wire _tc1 = p_addr >= `TC1_LOW_BOUND && p_addr <= `TC1_HIGH_BOUND;
    wire _int = p_addr == `RESPONSE_LOW;
    
    assign m_addr   = p_addr;
    assign m_wdata  = p_wdata;
    assign m_byteen = _dm ? p_byteen : 4'b0000;
    assign m_pc     = p_pc;
    
    assign tc0_addr  = p_addr[31: 2];
    assign tc0_we    = _tc0 && |p_byteen;
    assign tc0_wdata = p_wdata;
    
    assign tc1_addr  = p_addr[31: 2];
    assign tc1_we    = _tc1 && |p_byteen;
    assign tc1_wdata = p_wdata;
    
    assign int_addr   = p_addr;
    assign int_byteen = _dm ? p_byteen : 4'b0000;
    
    // Read Data from outers to the processor
    assign p_rdata = _dm  ? m_rdata   :
                     _tc0 ? tc0_rdata :
                     _tc1 ? tc1_rdata :
                     32'h0000_0000;

endmodule
