`timescale 1ns / 1ps

module MUX32_2(
    input Sel,
    input [31:0] DI_0,
    input [31:0] DI_1,
    output [31:0] DO
    );
    
    assign DO = (Sel == 1'b0 ? DI_0 : DI_1);

endmodule
