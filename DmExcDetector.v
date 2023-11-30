`timescale 1ns / 1ps
`include "Constants.v"
`include "Bridge_Consts.v"

module DmExcDetector(
    input ExcFromAlu,
    input [2:0] DmAccessType,
    input [31:0] DmAddress,
    output ExcAdEL,
    output ExcAdES
    );

    wire ByteAligned = 1'b1;
    wire HalfAligned = ~DmAddress[0];
    wire WordAligned = ~|DmAddress[1:0];

    wire load = DmAccessType == `WordRead || 
                DmAccessType == `ByteSigned || 
                DmAccessType == `ByteUnsigned || 
                DmAccessType == `HalfSigned || 
                DmAccessType == `HalfUnsigned;
    wire store = DmAccessType == `Byte ||
                 DmAccessType == `Half ||
                 DmAccessType == `Word;
    
    wire Byte = DmAccessType == `Byte ||
                DmAccessType == `ByteSigned ||
                DmAccessType == `ByteUnsigned;
    wire Half = DmAccessType == `Half ||
                DmAccessType == `HalfSigned ||
                DmAccessType == `HalfUnsigned;
    wire Word = DmAccessType == `Word ||
                DmAccessType == `WordRead;

    wire TarDm  = DmAddress >= `DM_LOW_BOUND  && DmAddress <= `DM_HIGH_BOUND;
    wire TarTC0 = DmAddress >= `TC0_LOW_BOUND && DmAddress <= `TC0_HIGH_BOUND;
    wire TarTC1 = DmAddress >= `TC1_LOW_BOUND && DmAddress <= `TC1_HIGH_BOUND;
    wire TarInt = DmAddress >= `RESPONSE_LOW  && DmAddress <= `RESPONSE_HIGH;
    wire TarTC0Clock = TarTC0 && DmAddress > `TC0_ALLOW_HIGH;
    wire TarTC1Clock = TarTC1 && DmAddress > `TC1_ALLOW_HIGH;

    wire ExcOutOfBound = !(TarDm || TarTC0 || TarTC1 || TarInt);
    wire ExcAligned = (Byte && !ByteAligned) || (Half && !HalfAligned) || (Word && !WordAligned);
    wire ExcTimerAligned = (Half || Byte) && (TarTC0 || TarTC1);
    wire ExcTimerStoreClock = (TarTC0Clock || TarTC1Clock);

    assign ExcAdEL = load && (ExcFromAlu || ExcAligned || ExcTimerAligned || ExcOutOfBound);
    assign ExcAdES = store && (ExcFromAlu || ExcAligned || ExcTimerAligned || ExcOutOfBound || ExcTimerStoreClock);

endmodule
