`timescale 1ns / 1ps
`include "Constants.v"

module IM(
    input [31:0] PC,
    output [31:0] Instr
    );

    reg [31:0] InstrMemory[4095:0];
    wire  [31:0] InsAddr;

    assign InsAddr = PC - `PC_START;
    assign Instr = InstrMemory[InsAddr[13:2]];

    initial begin
        $readmemh("code.txt", InstrMemory);
    end


endmodule
