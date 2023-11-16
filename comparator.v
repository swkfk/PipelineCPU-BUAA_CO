`timescale 1ns / 1ps
`include "Constants.v"

module CMP(
    input [31:0] RD1,
    input [31:0] RD2,
    input [2:0] BType,
    output b_jump
    );
    
    wire eq = RD1 == RD2;
    wire ne = !eq;

    assign b_jump = 
        (BType == `Br_BEQ && eq) || (BType == `Br_BNE && ne);

endmodule
