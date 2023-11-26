`timescale 1ns / 1ps
`include "Bridge_Consts.v"
`include "Exc_Consts.v"

module Bridge(
    // For Processor
    input  [31: 0] p_addr;
    input  [ 3: 0] p_byteen;
    input  [31: 0] p_wdata;
    output [31: 0] p_rdata;
    input  [31: 0] p_pc;
    // For DM
    output [31: 0] m_addr;
    input  [31: 0] m_rdata;
    output [31: 0] m_wdata;
    output [31: 0] m_byteen;
    output [31: 0] m_pc;
    // For TC0 & TC1
    output [31: 2] tc0_addr;
    output         tc0_we;
    output [31: 0] tc0_wdata;
    input  [31: 0] tc0_rdata;
    output [31: 2] tc1_addr;
    output         tc1_we;
    output [31: 0] tc1_wdata;
    input  [31: 0] tc1_rdata;
    // For Interrupt
    output [31: 0] int_addr;
    output [ 3: 0] int_byteen;
//    input [31:0] VAddr,
//    input [2:0]  AccessType,
//    input [31:0] WriteData,
//    input [31:0] DMData,
//    input [31:0] TC0Data,
//    input [31:0] TC1Data,
//    output [31:0] TC0AddrOut,
//    output [31:0] TC1AddrOut,
//    output [31:0] DMAddrOut,
//    output [3:0]  DMByteenOut,
//    output [31:0] IntAddrOut,
//    output [3:0]  IntByteenOut,
//    output [31:0] WriteDataOut,
//    output TC0We,
//    output TC1We,
//    output [31:0] CPUOut,
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
    assign p_rdata = _dm  ? m_rdata :
                     _tc0 ? tc0_rdata:
                     _tc1 ? tc1 _ rdata:
                     32'h0000_0000;


//    wire [31: 0] byteened_data;
//    wire [ 3: 0] byteen_out;    // |byteen_out == 0 when load
//    
//    wire load_byte = AccessType == `ByteSigned || AccessType == ByteUnsigned;
//    wire load_half = AccessType == `HalfSigned || AccessType == `HalfUnsigned;
//    wire load_word = AccessType == `WordRead;
//    wire load = load_byte || load_half || load_word;
//    wire store_byte = AccessType == `Byte;
//    wire store_half = AccessType == `Half;
//    wire store_word = AccessType == `Word;
//    wire store = store_byte || store_half || store_word;
//
//    BE u_be(
//        .data_w_in(WriteData),
//        .addr_low(VAddr[1:0]),
//        .write_type(AccessType),
//        .data_w_out(byteened_data),
//        .data_w_byteen(byteen_out)
//    );
//    
//    wire excWriteAlign = (store_word && |VAddr[1:0]) || (store_half && VAddr[0]);
//    wire excWriteBound = store &&
//                         !(
//                            (VAddr >= `DM_LOW_BOUND  && VAddr <= `DM_HIGH_BOUND)  ||
//                            (Vaddr >= `TC0_LOW_BOUND && VAddr <= `TC0_ALLOW_HIGH) ||
//                            (Vaddr >= `TC1_LOW_BOUND && VAddr <= `TC1_ALLOW_HIGH) ||
//                            (VAddr >= `RESPONSE_LOW  && VAddr <= `RESPONSE_HIGH)
//                          );
//    wire excLoadAlign  = (load_word  && |VAddr[1:0]) || (load_half  && VAddr[0]);
//    wire excLoadBound = load &&
//                        !(
//                           (VAddr >= `DM_LOW_BOUND  && VAddr <= `DM_HIGH_BOUND)  ||
//                           (Vaddr >= `TC0_LOW_BOUND && VAddr <= `TC0_HIGH_BOUND) ||
//                           (Vaddr >= `TC1_LOW_BOUND && VAddr <= `TC1_HIGH_BOUND) ||
//                           (VAddr >= `RESPONSE_LOW  && VAddr <= `RESPONSE_HIGH)
//                         );
//
//    wire ExcAdEL = excLoadAlign  || excLoadBound  || (load  && ExcOv);
//    wire ExcAdES = excWriteAlign || excWriteBound || (write && ExcOv);
//
//    // TODO: lb, lh, sb, sh to int_addr!!!
//    
//    assign DmAddrOut = (VAddr >= `DM_LOW_BOUND  && VAddr <= `DM_HIGH_BOUND) ? VAddr : 32'h0000_0000;
//    assign IntAddrOut = `RESPONSE_LOW;
//    assign TC0AddrOut = (Vaddr >= `TC0_LOW_BOUND && VAddr <= `TC0_HIGH_BOUND) ? VAddr : `TC0_LOW_BOUND;
//    assign TC1AddrOut = (Vaddr >= `TC1_LOW_BOUND && VAddr <= `TC1_HIGH_BOUND) ? VAddr : `TC1_LOW_BOUND;
//    
//    assign DmByteenOut  = (!ExcAdES && (VAddr >= `DM_LOW_BOUND  && VAddr <= `DM_HIGH_BOUND)) ? byteen_out : 4'b0;
//    assign IntByteenOut = (!ExcAdES && (VAddr >= `RESPONSE_LOW  && VAddr <= `RESPONSE_HIGH)) ? byteen_out : 4'b0;
//    assign TC0We = (!ExcAdES && (Vaddr >= `TC0_LOW_BOUND && VAddr <= `TC0_ALLOW_HIGH) && write);
//    assign TC1We = (!ExcAdES && (Vaddr >= `TC1_LOW_BOUND && VAddr <= `TC1_ALLOW_HIGH) && write);
//
//    assign WriteDataOut = 

endmodule
